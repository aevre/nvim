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
- Keep every body line at most 72 characters.
- Add `BREAKING CHANGE: ...` after a blank line only when the diff proves a
  breaking change.

Choose the type from the primary intent of the staged diff. Summarize mixed
changes as one cohesive commit; do not invent issue IDs, behavior, tests, or
motivation not present in the diff. Base every claim strictly on the staged
diff.

Return only the raw commit message without Markdown fences or explanation.
]]

---@param message string
---@param output luma.Window
local function commit(message, output)
	vim.system({ "git", "commit", "-F", "-" }, { text = true, stdin = message }, function(result)
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

---@param message string
---@param output luma.Window
local function configure_output(message, output)
	output:set_title(" c commit staged changes · y copy message ")
	vim.keymap.set("n", "c", function()
		commit(message, output)
	end, { buffer = output.buf, desc = "Commit staged changes using the generated message" })
	vim.keymap.set("n", "y", function()
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
				on_done = configure_output,
			})
		end)
	end)
end
