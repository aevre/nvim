---@type LazyPluginSpec
return {
	"https://codeberg.org/aevre/notify.nvim",
	name = "notify.nvim",
	dir = vim.env.NVIM_PLUGIN_MODE == "dev" and vim.fn.expand("~/Projects/lib/notify.nvim") or nil,
	lazy = false,
	dependencies = { "win.nvim", "animate.nvim" },
	config = function(_, opts)
		require("notify").setup(opts)
	end,
	opts = {
		timeout = 1500,
		max_width = 0.4,
		min_width = 40,
		max_height = 0.6,
		gap = 0,
		margin = { top = 1, right = 1, bottom = 0 },
		lsp_progress = { throttle = 80, margin_bottom = 1, margin_right = 1 },
	},
}
