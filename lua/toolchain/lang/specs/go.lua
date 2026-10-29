---@type LanguageSpec
return {
	debug = { "delve" },
	formatters = { "goimports", "gofumpt" },
	linters = { "golangcilint" },
	lsp = { "gopls" },
	filetypes = {
		"go",
	},
	treesitter = { "go", "gomod", "gowork", "gotmpl" },
	treesitter_filetypes = { "gomod", "gosum", "gowork", "gotmpl" },
}
