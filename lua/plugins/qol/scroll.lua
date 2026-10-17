---@type LazyPluginSpec
return {
	"https://codeberg.org/aevre/scroll.nvim",
	name = "scroll.nvim",
	dir = vim.fn.expand("~/Projects/lib/scroll.nvim"),
	event = "UIEnter",
	dependencies = { "animate.nvim" },
	config = function(_, opts)
		require("scroll").setup(opts)
	end,
	opts = {
		enabled = true,
	},
}
