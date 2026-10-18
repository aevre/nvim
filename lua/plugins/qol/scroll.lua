---@type LazyPluginSpec
return {
	"https://codeberg.org/aevre/scroll.nvim",
	name = "scroll.nvim",
	dir = vim.env.NVIM_PLUGIN_MODE == "dev" and vim.fn.expand("~/Projects/lib/scroll.nvim") or nil,
	event = "UIEnter",
	dependencies = { "animate.nvim" },
	config = function(_, opts)
		require("scroll").setup(opts)
	end,
	opts = {
		enabled = true,
	},
}
