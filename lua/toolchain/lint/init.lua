---@class LintLinter
---@field condition? fun(ctx: { filename: string, dirname: string }): boolean

---@class LintSpec
---@field linter LintLinter

local M = {}
local specs = require("toolchain.specs").load("lint", function(spec)
	return type(spec.linter) == "table"
end)

function M.get_linter_configs()
	local result = {}
	for name, spec in pairs(specs) do
		result[name] = vim.deepcopy(spec.linter)
	end
	return result
end

return M
