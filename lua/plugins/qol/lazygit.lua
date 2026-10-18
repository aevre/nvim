---@type LazyPluginSpec
return {
	"https://codeberg.org/aevre/lazygit.nvim",
	name = "lazygit.nvim",
	dir = vim.env.NVIM_PLUGIN_MODE == "dev" and vim.fn.expand("~/Projects/lib/lazygit.nvim") or nil,
	lazy = false,
	dependencies = { "terminal.nvim" },
	config = function(_, opts)
		require("lazygit").setup(opts)
	end,
	opts = {},
}
