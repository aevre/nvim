---@type LazyPluginSpec
return {
	"https://codeberg.org/aevre/animate.nvim",
	name = "animate.nvim",
	dir = vim.fn.expand("~/Projects/lib/animate.nvim"),
	lazy = false,
	config = function(_, opts)
		require("animate").setup(opts)
	end,
	opts = {},
}
