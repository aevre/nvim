---@type LazyPluginSpec
return {
	"ibhagwan/fzf-lua",
	dependencies = { "nvim-mini/mini.icons" },
	lazy = false,

	---@module "fzf-lua"
	---@type fzf-lua.Config | { }
	opts = {
		ui_select = {},
		winopts = {
			row = 0.50,
			col = 0.50,
			preview = {
				wrap = true,
				scrollbar = "float",
			},
		},
		files = { prompt = "> ", cwd_prompt = false },
	},

	defaults = {
		prompt = "> ",
	},

	fzf_opts = {
		-- options are sent as `<left>=<right>`
		-- set to `false` to remove a flag
		-- set to `true` for a no-value flag
		-- for raw args use `fzf_args` instead
		["--ansi"] = true,
		["--info"] = "inline-right", -- fzf < v0.42 = "inline"
		["--height"] = "100%",
		["--layout"] = "reverse",
		["--border"] = "none",
		["--highlight-line"] = true, -- fzf >= v0.53
	},

	keymap = {
		-- Below are the default binds, setting any value in these tables will override
		-- the defaults, to inherit from the defaults change [1] from `false` to `true`
		builtin = {
			-- neovim `:tmap` mappings for the fzf win
			-- true,        -- uncomment to inherit all the below in your custom config
			["<Esc>"] = "clear-query",
			["q"] = "hide",
			["<F1>"] = "toggle-help",
			["<F2>"] = "toggle-fullscreen",
			-- Only valid with the 'builtin' previewer
			["<F3>"] = "toggle-preview-wrap",
			["<F4>"] = "toggle-preview",
			-- Rotate preview clockwise/counter-clockwise
			["<F5>"] = "toggle-preview-cw",
			-- Preview toggle behavior default/extend
			["<F6>"] = "toggle-preview-behavior",
			-- `ts-ctx` binds require `nvim-treesitter-context`
			["<F7>"] = "toggle-preview-ts-ctx",
			["<F8>"] = "preview-ts-ctx-dec",
			["<F9>"] = "preview-ts-ctx-inc",
			["<S-Left>"] = "preview-reset",
			["<S-Down>"] = "preview-page-down",
			["<S-Up>"] = "preview-page-up",
			-- ['<M-S-down>'] = 'preview-down',
			-- ['<M-S-up>'] = 'preview-up',
		},
		fzf = {
			-- fzf '--bind=' options
			-- true,        -- uncomment to inherit all the below in your custom config
			["esc"] = "unbind",
			["ctrl-z"] = "abort",
			["ctrl-d"] = "half-page-down",
			["ctrl-u"] = "half-page-up",
			["ctrl-a"] = "beginning-of-line",
			["ctrl-e"] = "end-of-line",
			["ctrl-n"] = "first",
			["ctrl-p"] = "last",
			-- Only valid with fzf previewers (bat/cat/git/etc)
			["shift-up"] = "preview-page-up",
			["shift-down"] = "preview-page-down",
		},
	},

	keys = {
		{
			"<leader>,",
			function()
				FzfLua.buffers()
			end,
			desc = "Buffers",
		},

		{
			"<leader>/",
			function()
				FzfLua.live_grep()
			end,
			desc = "Grep",
		},

		{
			"<leader>:",
			function()
				FzfLua.command_history()
			end,
			desc = "Command History",
		},

		{
			"<leader><space>",
			function()
				FzfLua.files()
			end,
			desc = "Find Files",
		},

		{
			"<leader>n",
			function()
				require("notify").picker()
			end,
			desc = "Notification History",
		},

		{
			"<leader>fn",
			function()
				require("notify").picker({ kind = "fidget" })
			end,
			desc = "Fidget History",
		},

		{
			"<leader>cL",
			function()
				require("sources.language").picker()
			end,
			desc = "Language Config",
		},

		-- find
		{
			"<leader>fb",
			function()
				FzfLua.buffers()
			end,
			desc = "Buffers",
		},

		{
			"<leader>fB",
			function()
				FzfLua.buffers({
					show_unloaded = true,
				})
			end,
			desc = "Buffers (all)",
		},

		{
			"<leader>fc",
			function()
				FzfLua.files({
					cwd = vim.fn.stdpath("config"),
				})
			end,
			desc = "Find Config File",
		},

		{
			"<leader>ff",
			function()
				FzfLua.files()
			end,
			desc = "Find Files",
		},

		{
			"<leader>fr",
			function()
				FzfLua.oldfiles()
			end,
			desc = "Recent",
		},

		{
			"<leader>fR",
			function()
				FzfLua.oldfiles({
					cwd_only = true,
				})
			end,
			desc = "Recent (cwd)",
		},

		{
			"<leader>fz",
			function()
				FzfLua.zoxide()
			end,
			desc = "Zoxide",
		},

		-- git
		{
			"<leader>fg",
			function()
				FzfLua.git_files()
			end,
			desc = "Git Files",
		},

		{
			"<leader>gb",
			function()
				FzfLua.git_branches()
			end,
			desc = "Git Branches",
		},

		{
			"<leader>gi",
			function()
				FzfLua.fzf_exec("gh issue list --state open", {
					prompt = "GitHub Issues> ",
				})
			end,
			desc = "GitHub Issues (open)",
		},

		{
			"<leader>gI",
			function()
				FzfLua.fzf_exec("gh issue list --state all", {
					prompt = "GitHub Issues> ",
				})
			end,
			desc = "GitHub Issues (all)",
		},

		{
			"<leader>gp",
			function()
				FzfLua.fzf_exec("gh pr list --state open", {
					prompt = "GitHub PRs> ",
				})
			end,
			desc = "GitHub PRs (open)",
		},

		{
			"<leader>gP",
			function()
				FzfLua.fzf_exec("gh pr list --state all", {
					prompt = "GitHub PRs> ",
				})
			end,
			desc = "GitHub PRs (all)",
		},

		{
			"<leader>gf",
			function()
				FzfLua.git_bcommits()
			end,
			desc = "Git Log File",
		},

		{
			"<leader>gd",
			function()
				FzfLua.git_diff()
			end,
			desc = "Git Diff (hunks)",
		},

		{
			"<leader>gD",
			function()
				FzfLua.git_diff({
					base = "origin",
				})
			end,
			desc = "Git Diff (origin)",
		},

		{
			"<leader>gs",
			function()
				FzfLua.git_status()
			end,
			desc = "Git Status",
		},

		{
			"<leader>gS",
			function()
				FzfLua.git_stash()
			end,
			desc = "Git Stash",
		},

		-- search
		{
			'<leader>s"',
			function()
				FzfLua.registers()
			end,
			desc = "Registers",
		},

		{
			"<leader>sb",
			function()
				FzfLua.lines()
			end,
			desc = "Buffer Lines",
		},
		{
			"<leader>sB",
			function()
				FzfLua.grep_project()
			end,
			desc = "Buffer Lines",
		},
		{
			"<leader>sG",
			function()
				FzfLua.live_grep()
			end,
			desc = "Grep",
		},
		{
			"<leader>sg",
			function()
				FzfLua.live_grep_native()
			end,
			desc = "Grep Glob",
		},

		{
			"<leader>sw",
			function()
				FzfLua.grep_cword()
			end,
			desc = "Visual selection or word",
			mode = { "n", "x" },
		},

		{
			"<leader>sW",
			function()
				FzfLua.grep_cWORD()
			end,
			desc = "Visual selection or word",
			mode = { "n", "x" },
		},

		{
			"<leader>s/",
			function()
				FzfLua.search_history()
			end,
			desc = "Search History",
		},

		{
			"<leader>sa",
			function()
				FzfLua.autocmds()
			end,
			desc = "Autocmds",
		},

		{
			"<leader>sc",
			function()
				FzfLua.command_history()
			end,
			desc = "Command History",
		},

		{
			"<leader>sC",
			function()
				FzfLua.commands()
			end,
			desc = "Commands",
		},

		{
			"<leader>sd",
			function()
				FzfLua.diagnostics_workspace()
			end,
			desc = "Diagnostics",
		},

		{
			"<leader>sD",
			function()
				FzfLua.diagnostics_document()
			end,
			desc = "Buffer Diagnostics",
		},

		{
			"<leader>sh",
			function()
				FzfLua.help_tags()
			end,
			desc = "Help Pages",
		},
		{
			"<leader>sH",
			function()
				FzfLua.highlights()
			end,
			desc = "Highlights",
		},

		{
			"<leader>sj",
			function()
				FzfLua.jumps()
			end,
			desc = "Jumps",
		},

		{
			"<leader>sk",
			function()
				FzfLua.keymaps()
			end,
			desc = "Keymaps",
		},

		{
			"<leader>sl",
			function()
				FzfLua.loclist()
			end,
			desc = "Location List",
		},

		{
			"<leader>si",
			function()
				require("sources.icon").picker()
			end,
			desc = "Select Icons",
		},

		{
			"<leader>sM",
			function()
				FzfLua.manpages()
			end,
			desc = "Man Pages",
		},

		{
			"<leader>sm",
			function()
				FzfLua.marks()
			end,
			desc = "Marks",
		},

		{
			"<leader>sR",
			function()
				FzfLua.resume()
			end,
			desc = "Resume",
		},

		{
			"<leader>sq",
			function()
				FzfLua.quickfix()
			end,
			desc = "Quickfix List",
		},

		{
			"<leader>su",
			function()
				FzfLua.undotree()
			end,
			desc = "Undotree",
		},

		{
			"<leader>st",
			function()
				FzfLua.live_grep({
					search = "TODO|FIXME|NOTE|WARN",
				})
			end,
			desc = "Todo",
		},

		-- ui
		{
			"<leader>uC",
			function()
				FzfLua.colorschemes()
			end,
			desc = "Colorschemes",
		},
	},
}
