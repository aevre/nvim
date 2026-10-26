local M = {}

-- Keep discovery deterministic and report the source of malformed specifications.
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
