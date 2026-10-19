local common = require("plugins.ui.heirline.components.common")

local function size()
	local bytes = vim.api.nvim_buf_get_offset(0, vim.api.nvim_buf_line_count(0))
	if bytes < 1024 then
		return bytes .. " B"
	end

	local units = { "KiB", "MiB", "GiB", "TiB" }
	local unit = 0
	while bytes >= 1024 and unit < #units do
		bytes = bytes / 1024
		unit = unit + 1
	end
	return string.format("%.1f %s", bytes, units[unit])
end

return {
	common.FileIcon,
	{
		provider = function()
			return size() .. " "
		end,
		hl = function(self)
			return { fg = self.palette.fg_muted or self.palette.fg_gutter }
		end,
	},
	update = { "BufEnter", "TextChanged", "TextChangedI" },
}
