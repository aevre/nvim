---@class FormatSpec
---@field formatter conform.FormatterConfigOverride Formatter fields merged into Conform's built-in definition.

local M = {}
---@type table<string, FormatSpec>
local specs = require("toolchain.specs").load("format", function(spec)
	return type(spec.formatter) == "table"
end)

---Return copies so plugin setup cannot mutate the cached specifications.
---@return table<string, conform.FormatterConfigOverride>
function M.get_formatter_configs()
	local result = {}
	for name, spec in pairs(specs) do
		result[name] = vim.deepcopy(spec.formatter)
	end
	return result
end

return M
