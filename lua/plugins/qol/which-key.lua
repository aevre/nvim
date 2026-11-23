return {
	"folke/which-key.nvim",
	event = "VeryLazy",
	opts = {
		preset = "helix",
		icons = {
			breadcrumb = "", -- symbol used in the command line area that shows your active key combo
			separator = "→", -- symbol used between a key and it's label
			group = "", -- symbol prepended to a group
			-- set icon mappings to true if you have a Nerd Font
			mappings = false,
			-- If you are using a Nerd Font: set icons.keys to an empty table which will use the
			-- default which-key.nvim defined Nerd Font icons, otherwise define a string table
			keys = {
				Up = "<Up>",
				Down = "<Down>",
				Left = "<Left>",
				Right = "<Right>",
				C = "C-",
				M = "M-",
				D = "D-",
				S = "S-",
				CR = "<CR>",
				Esc = "<Esc> ",
				ScrollWheelDown = "<ScrollWheelDown>",
				ScrollWheelUp = "<ScrollWheelUp>",
				NL = "<NL>",
				BS = "<BS>",
				Space = "<Spc>",
				Tab = "<Tab> ",
				F1 = "<F1>",
				F2 = "<F2>",
				F3 = "<F3>",
				F4 = "<F4>",
				F5 = "<F5>",
				F6 = "<F6>",
				F7 = "<F7>",
				F8 = "<F8>",
				F9 = "<F9>",
				F10 = "<F10>",
				F11 = "<F11>",
				F12 = "<F12>",
			},
		},
		spec = {
			{ "<leader>a", group = "ai", mode = { "n", "x" } },
			{ "<leader>b", group = "buffer" },
			{ "<leader>c", group = "code", mode = { "n", "x" } },
			{ "<leader>cp", group = "code preview", mode = { "n", "x" } },
			{ "<leader>d", group = "debug", mode = { "n", "x" } },
			{ "<leader>e", group = "files" },
			{ "<leader>f", group = "find" },
			{ "<leader>g", group = "git" },
			{ "<leader>l", group = "lsp" },
			{ "<leader>o", group = "overseer" },
			{ "<leader>O", group = "org" },
			{ "<leader>t", group = "terminal" },
			{ "<leader>u", group = "ui" },
			{ "<leader>w", group = "window" },
			{ "<leader>x", group = "other" },
			{ "<leader>p", group = "pack" },
			{ "<leader>q", group = "session" },
			{ "<leader>s", group = "search" },
			{ "<leader><tab>", group = "tab" },
		},
	},
	keys = {
		{
			"<leader>?",
			function()
				require("which-key").show({ global = false })
			end,
			desc = "Buffer Local Keymaps (which-key)",
		},
	},
}
