local M = {}

---@param palette theme.Palette
---@param opts theme.Options
---@return table<string, vim.api.keyset.highlight|string>
function M.get(palette, opts)
	opts = opts or {}
	local bg = opts.transparent and "NONE" or (palette.bg or "NONE")
	local border = palette.border_highlight or palette.border or palette.fg_gutter

	return {
		CmdlineNormal = { fg = palette.fg, bg = bg },
		CmdlineBorder = { fg = border, bg = bg },
		CmdlineTitle = { fg = palette.primary_bright or palette.primary, bg = bg, bold = true },
		CmdlinePum = { link = "Pmenu" },
	}
end

return M
