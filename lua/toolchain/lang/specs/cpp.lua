---@type LanguageSpec
return {
	debug = { { adapter = "gdb", configurations = { require("toolchain.debug.ctest").configuration() } } },
	filetypes = {
		"cpp",
	},
	formatters = {
		"clang_format",
	},
	lsp = {
		"clangd",
	},
	treesitter = {
		"cpp",
	},
}
