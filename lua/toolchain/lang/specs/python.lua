---@type LanguageSpec
return {
	debug = { "debugpy" },
	filetypes = { "python" },
	formatters = { "ruff_format", "isort", "yapf" },
	lsp = { "pyright", "ruff" },
	treesitter = { "python" },
}
