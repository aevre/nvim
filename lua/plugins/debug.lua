---@type LazyPluginSpec
return {
	"mfussenegger/nvim-dap",
	cmd = { "DapContinue", "DapNew", "DapToggleBreakpoint", "DapTerminate", "DapShowLog" },
	dependencies = {
		{
			"igorlfs/nvim-dap-view",
			opts = { auto_toggle = true, winbar = { default_section = "repl" } },
		},
	},
	config = function()
		require("toolchain").setup_debug()
	end,
	keys = {
		{
			"<leader>dc",
			function()
				require("dap").continue()
			end,
			desc = "Continue / Start",
		},
		{
			"<leader>dp",
			function()
				require("dap").pause()
			end,
			desc = "Pause",
		},
		{
			"<leader>dr",
			function()
				require("dap").restart()
			end,
			desc = "Restart",
		},
		{
			"<leader>dt",
			function()
				require("dap").terminate()
			end,
			desc = "Terminate",
		},
		{
			"<leader>db",
			function()
				require("dap").toggle_breakpoint()
			end,
			desc = "Toggle Breakpoint",
		},
		{
			"<leader>dB",
			function()
				local condition = require("toolchain.debug.context").input("Breakpoint condition: ")
				if condition ~= require("dap").ABORT then
					require("dap").set_breakpoint(condition)
				end
			end,
			desc = "Conditional Breakpoint",
		},
		{
			"<leader>di",
			function()
				require("dap").step_into()
			end,
			desc = "Step Into",
		},
		{
			"<leader>do",
			function()
				require("dap").step_over()
			end,
			desc = "Step Over",
		},
		{
			"<leader>dO",
			function()
				require("dap").step_out()
			end,
			desc = "Step Out",
		},
		{
			"<leader>dg",
			function()
				require("dap").run_to_cursor()
			end,
			desc = "Run to Cursor",
		},
		{
			"<leader>du",
			function()
				require("dap-view").toggle(true)
			end,
			desc = "Toggle Debug UI",
		},
		{
			"<leader>de",
			function()
				require("dap").repl.toggle()
			end,
			desc = "Debug REPL",
		},
	},
}
