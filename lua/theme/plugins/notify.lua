local M = {}

M.url = "https://codeberg.org/aevre/notify.nvim"

---@param foreground string
---@param alpha number
---@param background string
---@return string 十六进制混合色
local function blend(foreground, alpha, background)
	local function rgb(c)
		c = (c or "#000000"):lower()
		return { tonumber(c:sub(2, 3), 16) or 0, tonumber(c:sub(4, 5), 16) or 0, tonumber(c:sub(6, 7), 16) or 0 }
	end

	local bg = rgb(background)
	local fg = rgb(foreground)

	local function channel(i)
		local val = alpha * fg[i] + (1 - alpha) * bg[i]
		return math.floor(math.min(math.max(0, val), 255) + 0.5)
	end

	return string.format("#%02x%02x%02x", channel(1), channel(2), channel(3))
end

---@param palette theme.Palette
---@param opts theme.Options
---@return table<string, vim.api.keyset.highlight|string>
function M.get(palette, opts)
	opts = opts or {}
	local bg_base = palette.bg or "#000000"
	local bg_color = opts.transparent and "NONE" or bg_base
	local diag = palette.diag or {}

	local err_color = diag.error or palette.red or "#ff5555"
	local warn_color = diag.warn or palette.yellow or palette.orange or "#ffb86c"
	local info_color = diag.info or palette.primary or palette.blue or "#8be9fd"
	local debug_color = palette.comment or palette.fg_muted or "#6272a4"
	local trace_color = palette.purple or "#bd93f9"

	return {
		NotifyBackground = { fg = palette.fg, bg = bg_color },

		NotifyDEBUGBody = { fg = palette.fg, bg = bg_color },
		NotifyDEBUGBorder = { fg = blend(debug_color, 0.3, bg_base), bg = bg_color },
		NotifyDEBUGIcon = { fg = debug_color },
		NotifyDEBUGTitle = { fg = debug_color, bold = true },
		NotifyDEBUGSeparator = { fg = blend(debug_color, 0.45, bg_base) },
		NotifyDEBUGMessage = { fg = palette.fg },

		NotifyERRORBody = { fg = palette.fg, bg = bg_color },
		NotifyERRORBorder = { fg = blend(err_color, 0.3, bg_base), bg = bg_color },
		NotifyERRORIcon = { fg = err_color },
		NotifyERRORTitle = { fg = err_color, bold = true },
		NotifyERRORSeparator = { fg = blend(err_color, 0.45, bg_base) },
		NotifyERRORMessage = { fg = palette.fg },

		NotifyINFOBody = { fg = palette.fg, bg = bg_color },
		NotifyINFOBorder = { fg = blend(info_color, 0.3, bg_base), bg = bg_color },
		NotifyINFOIcon = { fg = info_color },
		NotifyINFOTitle = { fg = info_color, bold = true },
		NotifyINFOSeparator = { fg = blend(info_color, 0.45, bg_base) },
		NotifyINFOMessage = { fg = palette.fg },

		NotifyTRACEBody = { fg = palette.fg, bg = bg_color },
		NotifyTRACEBorder = { fg = blend(trace_color, 0.3, bg_base), bg = bg_color },
		NotifyTRACEIcon = { fg = trace_color },
		NotifyTRACETitle = { fg = trace_color, bold = true },
		NotifyTRACESeparator = { fg = blend(trace_color, 0.45, bg_base) },
		NotifyTRACEMessage = { fg = palette.fg },

		NotifyWARNBody = { fg = palette.fg, bg = bg_color },
		NotifyWARNBorder = { fg = blend(warn_color, 0.3, bg_base), bg = bg_color },
		NotifyWARNIcon = { fg = warn_color },
		NotifyWARNTitle = { fg = warn_color, bold = true },
		NotifyWARNSeparator = { fg = blend(warn_color, 0.45, bg_base) },
		NotifyWARNMessage = { fg = palette.fg },

		NotifyFidgetBackground = { bg = bg_color },
		NotifyFidgetLevel = { fg = info_color, bold = true },

		NotifyProgress = { fg = palette.fg, bg = bg_color },
		NotifyProgressSpinner = "Constant",
		NotifyProgressTitle = "NonText",
		NotifyProgressTask = "NonText",
		NotifyProgressMessage = { fg = palette.fg_muted or palette.comment or palette.fg },
		NotifyProgressPercentage = { fg = info_color, bold = true },
	}
end

return M
