local SYSTEM_PROMPT = [[
Generate one high-quality Git commit message from the staged diff.

Follow Conventional Commits exactly:
- Header format: `type(scope)!: subject` or `type: subject`.
- Allowed types: feat, fix, refactor, perf, docs, test, build, ci,
  chore, style, revert.
- Use a scope only when the diff clearly belongs to one stable component.
  Keep it short, lowercase, and omit it when uncertain.
- Use `!` only for a breaking API, behavior, data, or configuration change.

Header rules:
- Write in English and use the imperative mood.
- Start the subject with a lowercase word.
- Describe the primary intent, not filenames or implementation mechanics.
- Be specific; avoid vague words such as update, changes, tweaks, or fixes.
- Do not end with a period.
- Keep the entire header at most 72 characters.

Body rules:
- Omit the body when the header fully explains the change.
- Otherwise add a blank line followed by 1-4 concise `- ` bullets.
- Explain material behavior, rationale, or constraints not clear from the
  header. Do not list every file or restate the header.
- Keep every body line at most 72 characters, including `- `.
  Wrap a long bullet onto an indented continuation line.

Footer rules:
- Add `BREAKING CHANGE: ...` only when the diff proves a breaking change.
- Put it after the body (if any), separated by a blank line; nothing follows it.
- Keep each footer line at most 100 characters, including the
  `BREAKING CHANGE: ` prefix. Wrap longer explanations onto indented
  continuation lines; do not repeat the prefix.
- Keep all bullets in the body, before the footer.

Choose the type from the primary intent of the staged diff. Summarize mixed
changes as one cohesive commit; do not invent issue IDs, behavior, tests, or
motivation not present in the diff. Base every claim strictly on the staged
diff.

Return only the raw commit message without Markdown fences or explanation.
]]

local function format_message(message)
	local lines = vim.split(vim.trim(message), "\n", { plain = true })
	local formatted, footer = {}, false
	for index, line in ipairs(lines) do
		line = line:gsub("\r$", "")
		local limit = index == 1 and 72 or footer and 100 or 72
		if line:match("^BREAKING CHANGE: ") then
			footer, limit = true, 100
		end
		local prefix = line:match("^(%s*%- )") or "  "
		while #line > limit do
			if index == 1 then
				return nil, "commit header exceeds 72 characters; shorten it"
			end
			local before = line:sub(1, limit + 1)
			local break_at = before:match("^.*()%s")
			if not break_at or break_at <= #prefix then
				return nil, ("commit line %d has a word longer than %d characters; shorten it"):format(index, limit)
			end
			table.insert(formatted, line:sub(1, break_at - 1))
			line = "  " .. line:sub(break_at + 1):gsub("^%s+", "")
		end
		table.insert(formatted, line)
	end
	return table.concat(formatted, "\n")
end

---@param output luma.ResultWindow
local function commit(output)
	local commit_message, err = format_message(output:get_text())
	if not commit_message then
		vim.notify("luma: " .. err, vim.log.levels.ERROR)
		return
	end
	vim.system({ "git", "commit", "-F", "-" }, { text = true, stdin = commit_message }, function(result)
		vim.schedule(function()
			if result.code ~= 0 then
				vim.notify("luma: " .. vim.trim(result.stderr), vim.log.levels.ERROR)
				return
			end
			output:destroy()
			vim.notify(vim.trim(result.stdout), vim.log.levels.INFO)
			local ok, lazygit = pcall(require, "lazygit")
			if ok then
				lazygit.open()
			end
		end)
	end)
end

---@param _ string
---@param output luma.ResultWindow
local function configure_output(_, output)
	output:set_title(" c commit staged changes · y copy message ")
	vim.keymap.set("n", "c", function()
		commit(output)
	end, { buffer = output.buf, desc = "Commit staged changes using the generated message" })
	vim.keymap.set("n", "y", function()
		local message, err = format_message(output:get_text())
		if not message then
			vim.notify("luma: " .. err, vim.log.levels.ERROR)
			return
		end
		vim.fn.setreg("+", message)
		vim.notify("luma: commit message copied")
	end, { buffer = output.buf, desc = "Copy the generated commit message to the clipboard" })
end

---@param ctx luma.ToolContext
return function(ctx)
	vim.system({ "git", "diff", "--no-ext-diff", "--staged" }, { text = true }, function(result)
		vim.schedule(function()
			if result.code ~= 0 then
				vim.notify("luma: " .. vim.trim(result.stderr or "git diff failed"), vim.log.levels.ERROR)
				return
			end
			if vim.trim(result.stdout or "") == "" then
				vim.notify("luma: no staged changes", vim.log.levels.WARN)
				return
			end

			ctx.generate({
				title = " Commit message… ",
				system = SYSTEM_PROMPT,
				user = result.stdout,
				loading = "正在生成提交信息",
				editable = true,
				on_done = configure_output,
			})
		end)
	end)
end
