local SYSTEM_PROMPT =
	"Write a Bash script for the requested task. Return only the script without Markdown fences. Do not execute it."

---@param script string
---@param output luma.Window
local function run(script, output)
	vim.system({ "bash", "-c", script }, { text = true }, function(result)
		vim.schedule(function()
			local text = result.stdout or ""
			if result.stderr and result.stderr ~= "" then
				text = text .. (text ~= "" and "\n" or "") .. result.stderr
			end
			if output:buf_valid() then
				vim.bo[output.buf].modifiable = true
				vim.api.nvim_buf_set_lines(output.buf, 0, -1, false, vim.split(text, "\n", { plain = true }))
				vim.bo[output.buf].modifiable = false
				output:set_title((" Bash exit %d "):format(result.code))
			end
		end)
	end)
end

---@param script string
---@param output luma.Window
local function configure_output(script, output)
	output:set_title(" Review generated script · r execute with Bash · y copy script ")
	vim.keymap.set("n", "r", function()
		run(script, output)
	end, { buffer = output.buf, desc = "Execute the generated script with Bash" })
	vim.keymap.set("n", "y", function()
		vim.fn.setreg("+", script)
		vim.notify("luma: Bash script copied")
	end, { buffer = output.buf, desc = "Copy the generated Bash script to the clipboard" })
end

---@param ctx luma.ToolContext
return function(ctx)
	local request = ctx.has_range and ctx.source(true) or vim.fn.input("Bash task: ")
	if not request or request == "" then
		return
	end

	ctx.generate({
		title = " Bash script… ",
		system = SYSTEM_PROMPT,
		user = request,
		loading = "正在生成脚本",
		on_done = configure_output,
	})
end
