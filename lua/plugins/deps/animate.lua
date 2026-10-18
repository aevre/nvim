---@type LazyPluginSpec
return {
	"https://codeberg.org/aevre/animate.nvim",
	name = "animate.nvim",
	dir = vim.env.NVIM_PLUGIN_MODE == "dev" and vim.fn.expand("~/Projects/lib/animate.nvim") or nil,
	lazy = false,
	opts = {
		duration = 20,
		easing = "linear",
		fps = 120,
	},
}
