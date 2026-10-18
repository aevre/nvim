---@type LazyPluginSpec
return {
	"https://codeberg.org/aevre/animate.nvim",
	name = "animate.nvim",
	dir = vim.env.NVIM_PLUGIN_MODE == "dev" and vim.fn.expand("~/Projects/lib/animate.nvim") or nil,
	lazy = false,
	config = function(_, opts)
		require("animate").setup(opts)
	end,
	opts = {},
}
