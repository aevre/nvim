---@type LanguageSpec
return {
	debug = { "js-debug" },
	filetypes = { "typescript", "typescriptreact" },
	formatters = { "prettier", "biome", "oxfmt" },
	linters = { "eslint", "oxlint" },
	lint_filetypes = { "typescript" },
	lsp = { "vtsls", "biome", "oxlint", "oxfmt" },
	treesitter = { "typescript", "tsx" },
}
