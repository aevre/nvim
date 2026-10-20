---@type LazyPluginSpec
return {
	"https://codeberg.org/aevre/session.nvim",
	name = "session.nvim",
	dir = vim.env.NVIM_PLUGIN_MODE == "dev" and vim.fn.expand("~/Projects/lib/session.nvim") or nil,
	event = "BufReadPre",
	opts = {
		autosave = true,
		autosave_on_switch = false,
		auto_restore = false,
	},
	keys = {
		{
			"<leader>qs",
			function()
				require("session").load()
			end,
			desc = "Restore Session",
		},
		{
			"<leader>qS",
			function()
				require("session").select()
			end,
			desc = "Select Session",
		},
		{
			"<leader>ql",
			function()
				require("session").last()
			end,
			desc = "Restore Last Session",
		},
		{
			"<leader>qw",
			"<cmd>SessionSave<cr>",
			desc = "Save Session",
		},
	},
}
