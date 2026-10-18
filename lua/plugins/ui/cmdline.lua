---@type LazyPluginSpec
return {
	"https://codeberg.org/aevre/cmdline.nvim",
	-- enabled = false,
	name = "cmdline.nvim",
	dir = vim.env.NVIM_PLUGIN_MODE == "dev" and vim.fn.expand("~/Projects/lib/cmdline.nvim") or nil,
	lazy = false,
	opts = {
		cmdline = {
			enabled = true,
			view = "cmdline_popup",
			opts = {
				presets = {
					cmdline_popup = { position = "top", title = "Command", icon = "󰘳" },
					lua = { position = "top", title = "Lua", icon = "" },
					filter = { position = "top", title = "Filter", icon = "󰈲" },
					input = { position = "top", title = "Input", icon = "󰌌" },
					rename = { position = "top", title = "Rename", icon = "󰏫" },
					mini = { position = "mini", border = "none" },
				},
				width = { value = "60%", min = 40, max = 100 },
				border = "rounded",
			},
			format = {
				cmdline = { pattern = "^:", view = "cmdline_popup", icon = "󰘳" },
				filter = { pattern = "^:%s*!", view = "filter", icon = "󰈲" },
				lua = { pattern = { "^:%s*lua%s+", "^:%s*lua%s*=%s*", "^:%s*=%s*" }, view = "lua", icon = "" },
				input = { view = "input", icon = "󰌌" },
				rename = { view = "rename", icon = "󰏫" },
			},
		},
		messages = {
			enabled = true,
			view = "notify",
			view_error = "notify",
			view_warn = "notify",
			view_history = "messages",
			view_search = "notify",
		},
		popupmenu = {
			enabled = true,
			backend = "nui",
			kind_icons = {},
		},
	},
}
