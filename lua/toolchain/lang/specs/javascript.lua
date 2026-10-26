---@type LanguageSpec
return {
	debug = { "js-debug" },
	filetypes = { "javascript", "javascriptreact" },
	formatters = { "prettier", "biome", "oxfmt" },
	linters = { "eslint", "oxlint" },
	lint_filetypes = { "javascript" },
	lsp = { "vtsls", "biome", "oxlint", "cssmodules-language-server", "oxfmt" },
	treesitter = { "javascript" },
}
