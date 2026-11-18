local M = {}

---@param palette theme.Palette
---@param opts theme.Options
---@return table<string, vim.api.keyset.highlight|string>
function M.get(palette, opts)
	opts = opts or {}
	local diag = palette.diag or {}
	local float = palette.float or {}
	local float_bg = opts.transparent and "NONE" or (float.bg or palette.bg_dim)
	local border = palette.border_highlight or palette.border or palette.fg_gutter
	return {
		LumaNormal = { fg = float.fg or palette.fg, bg = float_bg },
		LumaNormalNC = { fg = float.fg or palette.fg, bg = float_bg },
		LumaBorder = { fg = border, bg = float_bg },
		LumaTitle = { fg = palette.primary_bright or palette.primary, bg = float_bg, bold = true },
		LumaFooter = { fg = palette.fg_muted or palette.comment, bg = float_bg },
		LumaSeparator = { fg = palette.border or palette.fg_gutter, bg = float_bg },
		LumaUser = { fg = palette.primary or palette.blue, bold = true },
		LumaAssistant = { fg = palette.green or palette.fg, bold = true },
		LumaError = { fg = diag.error or palette.red, bold = true },
		LumaLoading = { fg = palette.primary_bright or palette.primary or palette.blue, bg = float_bg, bold = true },
		LumaLoadingBorder = { fg = border, bg = float_bg },
		LumaResultBorder = { fg = diag.ok or palette.green or border, bg = float_bg },
	}
end

return M
