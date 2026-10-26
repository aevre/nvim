-- Noice
---@type LazyPluginSpec
return {
	"folke/noice.nvim",
	lazy = false,
	enabled = false,

	opts = {
		notify = {
			enabled = true,
		},
		lsp = {
			progress = {
				enabled = false,
			},
			signature = { enabled = false },
			override = {
				["vim.lsp.util.convert_input_to_markdown_lines"] = true,
				["vim.lsp.util.stylize_markdown"] = true,
			},
			hover = {
				enabled = false,
			},
		},
		routes = {
			enabled = false,
		},
		popupmenu = {
			backend = "cmp",
		},
		presets = {
			bottom_search = true,
			command_palette = true,
			long_message_to_split = true,
			-- inc_rename = true,
			-- lsp_doc_border = true,
		},
		keys = {
			{ "<leader>sn", "" },

			{
				"<S-Enter>",
				function()
					require("noice").redirect(vim.fn.getcmdline())
				end,
				mode = "c",
				desc = "Redirect Cmdline",
			},

			{
				"<leader>snl",
				function()
					require("noice").cmd("last")
				end,
				mode = "n",
				desc = "Noice Last Message",
			},

			{
				"<leader>snh",
				function()
					require("noice").cmd("history")
				end,
				mode = "n",
				desc = "Noice History",
			},

			{
				"<leader>sna",
				function()
					require("noice").cmd("all")
				end,
				mode = "n",
				desc = "Noice All",
			},

			{
				"<leader>snd",
				function()
					require("noice").cmd("dismiss")
				end,
				mode = "n",
				desc = "Dismiss All",
			},

			{
				"<leader>snt",
				function()
					require("noice").cmd("pick")
				end,
				mode = "n",
				desc = "Noice Picker (Telescope/FzfLua)",
			},

			{
				"<C-f>",
				function()
					if not require("noice.lsp").scroll(4) then
						return "<C-f>"
					end
				end,
				mode = { "i", "n", "s" },
				silent = true,
				expr = true,
				desc = "Scroll Forward",
			},

			{
				"<C-b>",
				function()
					if not require("noice.lsp").scroll(-4) then
						return "<C-b>"
					end
				end,
				mode = { "i", "n", "s" },
				silent = true,
				expr = true,
				desc = "Scroll Backward",
			},
		},
	},
}
