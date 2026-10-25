---@type LazyPluginSpec
return {
	"aevre/scroll.nvim",
	name = "scroll.nvim",
	dir = vim.env.NVIM_PLUGIN_MODE == "dev" and vim.fn.expand("~/Projects/lib/scroll.nvim") or nil,
	event = "UIEnter",
	dependencies = { "animate.nvim" },
	opts = {
		enabled = true,
		animate = {
			duration = { step = 10, total = 200 },
			easing = "linear",
		},
		animate_repeat = {
			delay = 100,
			duration = { step = 5, total = 50 },
			easing = "linear",
		},
		filter = function(buf)
			return vim.g.core_scroll ~= false and vim.b[buf].core_scroll ~= false and vim.bo[buf].buftype ~= "terminal"
		end,
		debug = false,
	},
}
