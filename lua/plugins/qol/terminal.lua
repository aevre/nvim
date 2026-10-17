---@type LazyPluginSpec
return {
	"https://codeberg.org/aevre/terminal.nvim",
	name = "terminal.nvim",
	dir = vim.fn.expand("~/Projects/lib/terminal.nvim"),
	lazy = false,
	dependencies = { "win.nvim" },
	config = function(_, opts)
		require("terminal").setup(opts)
	end,
	opts = {},
}
