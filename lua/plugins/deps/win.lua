---@type LazyPluginSpec
return {
	"aevre/win.nvim",
	name = "win.nvim",
	dir = vim.env.NVIM_PLUGIN_MODE == "dev" and vim.fn.expand("~/Projects/lib/win.nvim") or nil,
	lazy = true,
	opts = {
		show = true,
		fixbuf = true,
		relative = "editor",
		position = "float",
		minimal = true,
		wo = {
			winhighlight = "Normal:AevreWinNormal,NormalNC:AevreWinNormalNC,WinBar:AevreWinWinBar,WinBarNC:AevreWinWinBarNC,FloatTitle:AevreWinTitle,FloatFooter:AevreWinFooter,WinSeparator:AevreWinWinSeparator",
		},
		bo = {},
		title_pos = "center",
		keys = { q = "close" },
		footer_pos = "center",
		footer_keys = false,
	},
}
