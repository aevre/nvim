---@type LazyPluginSpec
return {
	"aevre/session.nvim",
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
		{
			"<leader>qd",
			function()
				require("session").delete_select()
			end,
			desc = "Delete Session",
		},
		{
			"<leader>qD",
			"<cmd>SessionDelete<cr>",
			desc = "Delete Current Session",
		},
		{
			"<leader>qr",
			function()
				local session = require("session")
				local active = session.active()
				if not active then
					vim.notify("No active session", vim.log.levels.WARN)
					return
				end
				vim.ui.input({ prompt = "New session name: ", default = active.name }, function(name)
					if name and name ~= "" then
						local path, err = session.rename(name)
						if not path then
							vim.notify("session.nvim: " .. tostring(err), vim.log.levels.ERROR)
						end
					end
				end)
			end,
			desc = "Rename Current Session",
		},
		{
			"<leader>qR",
			function()
				require("session").rename_select()
			end,
			desc = "Select Session to Rename",
		},
	},
}
