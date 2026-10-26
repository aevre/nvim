---@class FormatSpec
---@field formatter conform.FormatterConfigOverride

local M = {}
local specs = require("toolchain.specs").load("format", function(spec)
	return type(spec.formatter) == "table"
end)

function M.get_formatter_configs()
	local result = {}
	for name, spec in pairs(specs) do
		result[name] = vim.deepcopy(spec.formatter)
	end
	return result
end

return M
