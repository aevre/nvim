---@type LazyPluginSpec
return {
	"https://codeberg.org/aevre/lazygit.nvim",
	name = "lazygit.nvim",
	dir = vim.fn.expand("~/Projects/lib/lazygit.nvim"),
	lazy = false,
	dependencies = { "terminal.nvim" },
	config = function(_, opts)
		require("lazygit").setup(opts)
	end,
	opts = {},
}
