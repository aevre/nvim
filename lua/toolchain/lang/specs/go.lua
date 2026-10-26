---@type LanguageSpec
return {
	debug = { "delve" },
	filetypes = {
		"go",
	},
	formatters = { "goimports", "gofumpt" },
	linters = { "golangcilint" },
	lsp = { "gopls" },
	treesitter = { "go" },
}
