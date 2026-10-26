---@type LanguageSpec
return {
	debug = { { adapter = "gdb", configurations = { require("toolchain.debug.ctest").configuration() } } },
	filetypes = {
		"c",
	},
	formatters = {
		"clang_format",
	},
	lsp = {
		"clangd",
	},
	treesitter = {
		"c",
	},
}
