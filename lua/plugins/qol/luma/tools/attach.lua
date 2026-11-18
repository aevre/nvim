return function(ctx)
	if not ctx.has_range then
		vim.notify("luma: attach requires a visual selection", vim.log.levels.ERROR)
		return
	end
	local text = ctx.visual()
	if text then
		require("luma.session").attach(text)
	end
end
