---@type LazyPluginSpec
return {
	"https://codeberg.org/aevre/win.nvim",
	name = "win.nvim",
	dir = vim.env.NVIM_PLUGIN_MODE == "dev" and vim.fn.expand("~/Projects/lib/win.nvim") or nil,
	lazy = true,
}
