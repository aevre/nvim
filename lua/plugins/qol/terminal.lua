---@type LazyPluginSpec
return {
	"https://codeberg.org/aevre/terminal.nvim",
	name = "terminal.nvim",
	dir = vim.env.NVIM_PLUGIN_MODE == "dev" and vim.fn.expand("~/Projects/lib/terminal.nvim") or nil,
	lazy = false,
	dependencies = { "win.nvim" },
	opts = {
		win = {
			style = "terminal",
			wo = {
				winhighlight = table.concat({
					"Normal:TerminalNormal",
					"NormalNC:TerminalNormalNC",
					"FloatBorder:TerminalBorder",
					"FloatTitle:TerminalTitle",
					"WinBar:TerminalWinBar",
					"WinBarNC:TerminalWinBarNC",
				}, ","),
			},
		},
	},
}
