local M = {}

---@param palette theme.Palette
---@param opts theme.Options
---@return table<string, vim.api.keyset.highlight|string>
function M.get(palette, opts)
	opts = opts or {}
	local float = palette.float or {}
	local float_bg = opts.transparent and "NONE" or (float.bg or palette.bg_dim)
	local diag = palette.diag or {}

	local notify_error = diag.error or palette.red
	local notify_warn = diag.warn or palette.yellow
	local notify_info = diag.info or palette.primary
	local notify_debug = diag.hint or palette.green
	local notify_trace = palette.purple
	local notify_success = palette.green_bright or palette.green

	return {
		BuiltinNotifyErrorBorder = { fg = notify_error, bg = float_bg, bold = true },
		BuiltinNotifyWarnBorder = { fg = notify_warn, bg = float_bg, bold = true },
		BuiltinNotifyInfoBorder = { fg = notify_info, bg = float_bg, bold = true },
		BuiltinNotifyDebugBorder = { fg = notify_debug, bg = float_bg, bold = true },
		BuiltinNotifyTraceBorder = { fg = notify_trace, bg = float_bg, bold = true },
		BuiltinNotifySuccessBorder = { fg = notify_success, bg = float_bg, bold = true },
	}
end

return M
