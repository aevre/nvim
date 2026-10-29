---@class LintContext
---@field filename string Absolute path of the file being linted.
---@field dirname string Parent directory of `filename`.

---@class LintLinter
---@field condition? fun(ctx: LintContext): boolean Optional project availability predicate.

---@class LintSpec
---@field linter LintLinter Fields merged into nvim-lint's built-in linter definition.
---@field events? string[] Autocmd events that trigger this linter.

local M = {}
---@type table<string, LintSpec>
local specs = require("toolchain.specs").load("lint", function(spec)
	return type(spec.linter) == "table"
end)

---Return copies so plugin setup cannot mutate the cached specifications.
---@return table<string, LintLinter>
function M.get_linter_configs()
	local result = {}
	for name, spec in pairs(specs) do
		result[name] = vim.deepcopy(spec.linter)
	end
	return result
end

function M.get_events()
	local result = {}
	for name, spec in pairs(specs) do
		for _, event in ipairs(spec.events or {}) do
			result[event] = result[event] or {}
			result[event][#result[event] + 1] = name
		end
	end
	return result
end

return M
