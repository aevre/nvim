---@type LazyPluginSpec
return {
	"https://codeberg.org/aevre/lazygit.nvim",
	name = "lazygit.nvim",
	dir = vim.env.NVIM_PLUGIN_MODE == "dev" and vim.fn.expand("~/Projects/lib/lazygit.nvim") or nil,
	lazy = false,
	dependencies = { "terminal.nvim" },
	opts = {
		configure = true,
		config = {
			os = { editPreset = "nvim-remote" },
			gui = { nerdFontsVersion = "3" },
		},
		theme_path = vim.fs.normalize(vim.fn.stdpath("cache") .. "/lazygit-theme.yml"),
		theme = {
			[241] = { fg = "Special" },
			activeBorderColor = { fg = "MatchParen", bold = true },
			cherryPickedCommitBgColor = { fg = "Identifier" },
			cherryPickedCommitFgColor = { fg = "Function" },
			defaultFgColor = { fg = "Normal" },
			inactiveBorderColor = { fg = "FloatBorder" },
			optionsTextColor = { fg = "Function" },
			searchingActiveBorderColor = { fg = "MatchParen", bold = true },
			selectedLineBgColor = { bg = "Visual" },
			unstagedChangesColor = { fg = "DiagnosticError" },
		},
		win = {},
	},
}
