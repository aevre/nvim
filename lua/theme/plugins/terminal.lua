local M = {}

---@param palette theme.Palette
---@param opts theme.Options
---@return table<string, vim.api.keyset.highlight|string>
function M.get(palette, opts)
	opts = opts or {}
	local float = palette.float or {}
	local float_bg = opts.transparent and "NONE" or (float.bg or palette.bg_dim)
	local border = palette.border_highlight or palette.border or palette.fg_gutter
	local primary = palette.primary_bright or palette.primary or palette.blue

	return {
		TerminalNormal = { fg = palette.fg, bg = float_bg },
		TerminalNormalNC = { fg = palette.fg, bg = float_bg },
		TerminalBorder = { fg = border, bg = float_bg },
		TerminalTitle = { fg = primary, bg = float_bg, bold = true },
		TerminalWinBar = { fg = primary, bg = float_bg, bold = true },
		TerminalWinBarNC = { fg = palette.fg_muted or palette.comment, bg = float_bg },
	}
end

return M
