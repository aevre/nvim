local M = {}

M.url = "https://github.com/rcarriga/nvim-notify"

---@param palette theme.Palette
---@param opts theme.Options
---@return table<string, vim.api.keyset.highlight|string>
function M.get(palette, opts)
	opts = opts or {}
	local float = palette.float or {}
	local bg = opts.transparent and "NONE" or (float.bg or palette.bg_dim)
	local border = palette.border_highlight or palette.border or palette.fg_gutter
	local diag = palette.diag or {}
	local colors = {
		DEBUG = palette.comment or palette.fg_muted or palette.fg,
		ERROR = diag.error or palette.red,
		INFO = diag.info or palette.primary or palette.blue,
		TRACE = palette.purple or palette.magenta,
		WARN = diag.warn or palette.yellow or palette.orange,
	}

	local groups = {
		NotifyBackground = { bg = bg },
	}
	for level, color in pairs(colors) do
		groups["Notify" .. level .. "Border"] = { fg = color, bg = bg }
		groups["Notify" .. level .. "Icon"] = { fg = color }
		groups["Notify" .. level .. "Title"] = { fg = color, bg = bg, bold = true }
		groups["Notify" .. level .. "Body"] = { fg = palette.fg, bg = bg }
	end

	return groups
end

return M
