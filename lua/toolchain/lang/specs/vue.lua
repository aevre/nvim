---@type LanguageSpec
return {
	debug = {
		{
			adapter = "js-debug",
			defaults = false,
			configurations = {
				{
					name = "Attach Nuxt/Node server",
					type = "pwa-node",
					request = "attach",
					address = "127.0.0.1",
					port = function()
						return require("toolchain.debug.context").port("9229")
					end,
					cwd = function()
						return require("toolchain.debug.context").root({ "package.json", ".git" })
					end,
					sourceMaps = true,
					skipFiles = { "<node_internals>/**" },
				},
			},
		},
	},
	filetypes = { "vue" },
	formatters = {
		"prettier",
		"biome",
		"oxfmt",
	},
	linters = {
		"eslint",
		"oxlint",
	},
	lsp = {
		"vue_ls",
		"vtsls",
		"stylelint-language-server",
		"tailwindcss",
		"biome",
		"oxfmt",
	},
	treesitter = {
		"vue",
		"css",
		"scss",
	},
}
