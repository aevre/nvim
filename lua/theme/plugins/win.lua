local M = {}

---@param palette theme.Palette
---@param opts theme.Options
---@return table<string, vim.api.keyset.highlight|string>
function M.get(palette, opts)
	opts = opts or {}
	local float = palette.float or {}
	local float_bg = opts.transparent and "NONE" or (float.bg or palette.bg_dim)
	local border = palette.border_highlight or palette.border or palette.fg_gutter
	return {
		AevreWinBackdrop = { bg = "#000000" },
		AevreWinFooter = "FloatFooter",
		AevreWinActiveBorder = { fg = border, bg = float_bg },
		AevreWinFooterDesc = "DiagnosticInfo",
		AevreWinFooterKey = "DiagnosticVirtualTextInfo",
		AevreWinNormal = "NormalFloat",
		AevreWinNormalNC = "NormalFloat",
		AevreWinTitle = "FloatTitle",
		AevreWinWinBar = "Title",
		AevreWinWinBarNC = "Title",
		AevreWinWinKey = "Keyword",
		AevreWinWinKeySep = "NonText",
		AevreWinWinKeyDesc = "Function",
		AevreWinWinSeparator = "WinSeparator",
	}
end

return M
