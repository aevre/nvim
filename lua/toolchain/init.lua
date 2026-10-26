---@class ToolchainFormat
---@field get_formatter_configs fun(): table<string, conform.FormatterConfigOverride>

---@class ToolchainLint
---@field get_linter_configs fun(): table<string, LintLinter>

---@class ToolchainMason
---@field extra_packages string[] Mason packages installed for every recognized filetype.
---@field get_packages fun(filetype: string): string[]

---@class Toolchain
---@field lang ToolchainLanguage
---@field format ToolchainFormat
---@field lint ToolchainLint
---@field mason ToolchainMason
local M = {}

M.lang = require("toolchain.lang")
M.format = require("toolchain.format")
M.lint = require("toolchain.lint")
M.mason = require("toolchain.mason")

---Register language-driven services such as lazy LSP activation.
function M.setup()
	M.lang.setup()
end

---@return table<string, string[]> formatters Formatter names keyed by filetype.
function M.get_formatters()
	return M.lang.get_formatters()
end

---@return table<string, conform.FormatterConfigOverride> configs Formatter overrides keyed by formatter name.
function M.get_formatter_configs()
	return M.format.get_formatter_configs()
end

---@return table<string, string[]> linters Linter names keyed by filetype.
function M.get_linters()
	return M.lang.get_linters()
end

---@return table<string, LintLinter> configs Linter overrides keyed by linter name.
function M.get_linter_configs()
	return M.lint.get_linter_configs()
end

---@param opts? ToolchainDebugSetupOptions
function M.setup_debug(opts)
	require("toolchain.debug").setup(opts)
end

---@return ToolchainTreesitter
function M.get_treesitter()
	return M.lang.get_treesitter()
end

---@param filetype string
---@return LanguageSpec?
function M.get_language_by_filetype(filetype)
	return M.lang.get_by_filetype(filetype)
end

---@param filetype string
---@return string[] packages Mason package names required by the filetype.
function M.get_mason_packages(filetype)
	return M.mason.get_packages(filetype)
end

---@cast M Toolchain

return M
