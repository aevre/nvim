local M = {}

---Load and validate every Lua specification in a toolchain category.
---Files are sorted before loading so aggregation order and validation failures are deterministic.
---@generic T
---@param kind "lang"|"format"|"lint"|"debug" Specification directory name.
---@param validate fun(spec: unknown): boolean Category-specific structural validator.
---@return table<string, T> specs Specifications keyed by filename without extension.
function M.load(kind, validate)
	local result = {}
	local dir = vim.fs.joinpath(vim.fn.stdpath("config"), "lua", "toolchain", kind, "specs")
	local names = {}
	for name, entry_type in vim.fs.dir(dir) do
		if entry_type == "file" and name:sub(-4) == ".lua" then
			names[#names + 1] = name:sub(1, -5)
		end
	end
	table.sort(names)
	for _, name in ipairs(names) do
		local ok, spec = pcall(require, "toolchain." .. kind .. ".specs." .. name)
		assert(ok, ("Invalid %s specification %s: %s"):format(kind, name, tostring(spec)))
		assert(type(spec) == "table" and validate(spec), ("Invalid %s specification: %s.lua"):format(kind, name))
		result[name] = spec
	end
	return result
end

return M
