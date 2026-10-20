local M = {}

M.url = "https://github.com/ibhagwan/fzf-lua"

---@param palette theme.Palette
---@param opts theme.Options
---@return table<string, vim.api.keyset.highlight|string>
function M.get(palette, opts)
	opts = opts or {}
	local float_bg = opts.transparent and "NONE" or (palette.float and palette.float.bg or palette.bg_dim)
	local primary = palette.primary or palette.blue
	local primary_bright = palette.primary_bright or primary
	local border_fg = palette.border_highlight or palette.border or palette.fg_gutter

	return {
		FzfLuaNormal = { fg = palette.fg, bg = float_bg },
		FzfLuaBorder = { fg = border_fg, bg = float_bg },
		FzfLuaTitle = { fg = primary_bright, bg = float_bg, bold = true },
		FzfLuaPreviewTitle = { fg = border_fg, bg = float_bg, bold = true },
		FzfLuaBackdrop = { bg = palette.bg_deep or palette.bg },
		FzfLuaCursor = "IncSearch",
		FzfLuaFzfCursorLine = { fg = palette.fg, bg = palette.bg_search or palette.selection, bold = true },
		FzfLuaFzfPointer = { fg = primary_bright, bold = true },
		FzfLuaFzfSeparator = { fg = palette.peach or palette.yellow, bg = float_bg },
		FzfLuaFzfNormal = { fg = palette.fg },
		FzfLuaFilePart = { fg = palette.fg, bold = true },
		FzfLuaDirPart = { fg = palette.fg_muted or palette.comment },
		FzfLuaPath = "Directory",
		FzfLuaFzfMatch = { fg = palette.red, bold = true },
		FzfLuaHeaderBind = { fg = palette.purple or primary_bright, bold = true },
		FzfLuaHeaderText = { fg = palette.fg_muted or palette.comment },
		FzfLuaHelpNormal = { fg = palette.fg, bg = float_bg },
	}
end

return M
