local M = {}

M.lang = require("toolchain.lang")
M.format = require("toolchain.format")
M.lint = require("toolchain.lint")
M.mason = require("toolchain.mason")

function M.setup()
	M.lang.setup()
end

function M.get_formatters()
	return M.lang.get_formatters()
end

function M.get_formatter_configs()
	return M.format.get_formatter_configs()
end

function M.get_linters()
	return M.lang.get_linters()
end

function M.get_linter_configs()
	return M.lint.get_linter_configs()
end

function M.setup_debug(opts)
	require("toolchain.debug").setup(opts)
end

function M.get_treesitter()
	return M.lang.get_treesitter()
end

---@param filetype string
---@return LanguageSpec?
function M.get_language_by_filetype(filetype)
	return M.lang.get_by_filetype(filetype)
end

---@param filetype string
function M.get_mason_packages(filetype)
	return M.mason.get_packages(filetype)
end

return M
