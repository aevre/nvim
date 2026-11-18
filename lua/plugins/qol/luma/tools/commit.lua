local SYSTEM_PROMPT = [[
Generate a Conventional Commit message from the staged diff.

Requirements:
- Use `type: concise description` for the first line.
- Add concise bullet points only when they provide useful detail.
- Keep every line at most 72 characters.
- Base the message strictly on the staged diff.
- Return only the commit message.
]]

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

local function configure_output(message, output)
	output:set_title(" Review generated message · c commit staged changes · y copy message ")
	vim.keymap.set("n", "c", function()
		commit(message, output)
	end, { buffer = output.buf, desc = "Commit staged changes using the generated message" })
	vim.keymap.set("n", "y", function()
		vim.fn.setreg("+", message)
		vim.notify("luma: commit message copied")
	end, { buffer = output.buf, desc = "Copy the generated commit message to the clipboard" })
end

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
