local SYSTEM_PROMPT =
	"Rewrite the supplied text. Return only the replacement text without Markdown fences or explanation."

---@param ctx luma.ToolContext
return function(ctx)
	if not ctx.has_range then
		vim.notify("luma: rewrite requires a visual selection", vim.log.levels.ERROR)
		return
	end

	local text, range = ctx.visual()
	if not text or type(range) ~= "table" then
		return
	end
	---@cast range luma.RewriteRange

	local instruction = vim.fn.input("Rewrite instruction: ")
	if instruction == "" then
		return
	end

	range.changedtick = vim.api.nvim_buf_get_changedtick(range.bufnr)
	ctx.generate({
		title = " Rewriting… ",
		system = SYSTEM_PROMPT,
		user = instruction .. "\n\n<selection>\n" .. text .. "\n</selection>",
		loading = "正在改写",
		on_done = function(result, output)
			output:destroy()
			require("luma.diff").show(text, result, range)
		end,
	})
end
