---@type LazyPluginSpec
return {
	"folke/snacks.nvim",
	priority = 1000,
	enabled = false,
	lazy = false,

	opts = {
		picker = {
			enabled = false,
		},
		image = {
			enabled = not vim.g.neovide and true or false,
		},
		bigfile = {
			enabled = true,
			size = 10 * 1024 * 1024,
			line_length = 2000,
		},
		indent = {
			enabled = false,
			animate = {
				enabled = true,
			},
			indent = {
				only_scope = true,
			},
			scope = {
				enabled = true,
				underline = false,
			},
			chunk = {
				enabled = true,
			},
		},
		input = { enabled = false },
		notifier = { enabled = true },
		scope = { enabled = false },
		scroll = { enabled = false },
		words = { enabled = false },
		dashboard = {
			enabled = false,
			preset = {
				header = [[



         ▀████▀▄▄              ▄█
           █▀    ▀▀▄▄▄▄▄    ▄▄▀▀█
  ▄        █          ▀▀▀▀▄  ▄▀
 ▄▀ ▀▄      ▀▄              ▀▄▀
▄▀    █     █▀   ▄█▀▄      ▄█
▀▄     ▀▄  █     ▀██▀     ██▄█
 ▀▄    ▄▀ █   ▄██▄   ▄  ▄  ▀▀ █
  █  ▄▀  █    ▀██▀    ▀▀ ▀▀  ▄▀
 █   █  █      ▄▄           ▄▀
]],
				keys = {
					{ icon = " ", key = "f", desc = "Find File", action = ":lua Snacks.dashboard.pick('files')" },
					{
						icon = " ",
						key = "g",
						desc = "Find Text",
						action = ":lua Snacks.dashboard.pick('live_grep')",
					},
					{
						icon = " ",
						key = "r",
						desc = "Recent Files",
						action = ":lua Snacks.dashboard.pick('oldfiles')",
					},
					{
						icon = " ",
						key = "c",
						desc = "Config",
						action = ":lua Snacks.dashboard.pick('files', {cwd = vim.fn.stdpath('config')})",
					},
					{ icon = " ", key = "s", desc = "Restore Session", section = "session" },
					{ icon = "󰒲 ", key = "L", desc = "Lazy", action = ":Lazy" },
					{
						icon = " ",
						key = "S",
						desc = "Select Session",
						action = ":lua require('persistence').select()",
					},
					{ icon = " ", key = "q", desc = "Quit", action = ":qa" },
				},
			},
			sections = {
				{ section = "header" },
				{ section = "keys", gap = 0.5 },
				{ section = "startup" },
			},
		},
	},
	-- keys = {
	-- 	{ "<leader>,", "<cmd>lua Snacks.picker.buffers()<cr>", desc = "Buffers" },
	-- 	{ "<leader>/", "<cmd>lua Snacks.picker.grep()<cr>", desc = "Grep" },
	-- 	{ "<leader>:", "<cmd>lua Snacks.picker.command_history()<cr>", desc = "Command History" },
	-- 	{ "<leader><space>", "<cmd>lua Snacks.picker.files()<cr>", desc = "Find Files" },
	-- 	{ "<leader>n", "<cmd>lua Snacks.picker.notifications()<cr>", desc = "Notification History" },
	--
	-- 	-- find
	-- 	{ "<leader>fb", "<cmd>lua Snacks.picker.buffers()<cr>", desc = "Buffers" },
	-- 	{
	-- 		"<leader>fB",
	-- 		"<cmd>lua Snacks.picker.buffers({ hidden = true, nofile = true })<cr>",
	-- 		desc = "Buffers (all)",
	-- 	},
	-- 	{
	-- 		"<leader>fc",
	-- 		"<cmd>lua Snacks.picker.pick('files', { cwd = vim.fn.stdpath('config') })<cr>",
	-- 		desc = "Find Config File",
	-- 	},
	-- 	{ "<leader>ff", "<cmd>lua Snacks.picker.files()<cr>", desc = "Find Files (Root Dir)" },
	-- 	{ "<leader>fg", "<cmd>lua Snacks.picker.git_files()<cr>", desc = "Find Files (git-files)" },
	-- 	{ "<leader>fr", "<cmd>lua Snacks.picker.pick('oldfiles')<cr>", desc = "Recent" },
	-- 	{ "<leader>fR", "<cmd>lua Snacks.picker.recent({ filter = { cwd = true }})<cr>", desc = "Recent (cwd)" },
	-- 	{ "<leader>fp", "<cmd>lua Snacks.picker.projects()<cr>", desc = "Projects" },
	--
	-- 	-- git
	-- 	{ "<leader>gb", "<cmd>lua Snacks.picker.git_branches()<cr>", desc = "Git Branches" },
	-- 	{ "<leader>gi", "<cmd>lua Snacks.picker.gh_issue()<cr>", desc = "GitHub Issues (open)" },
	-- 	{ "<leader>gI", "<cmd>lua Snacks.picker.gh_issue({ state = 'all' })<cr>", desc = "GitHub Issues (all)" },
	-- 	{ "<leader>gp", "<cmd>lua Snacks.picker.gh_pr()<cr>", desc = "GitHub Pull Requests (open)" },
	-- 	{ "<leader>gP", "<cmd>lua Snacks.picker.gh_pr({ state = 'all' })<cr>", desc = "GitHub Pull Requests (all)" },
	-- 	{ "<leader>gf", "<cmd>lua Snacks.picker.git_log_file()", desc = "Git Log File" },
	--
	-- 	{ "<leader>gd", "<cmd>lua Snacks.picker.git_diff()<cr>", desc = "Git Diff (hunks)" },
	-- 	{
	-- 		"<leader>gD",
	-- 		"<cmd>lua Snacks.picker.git_diff({ base = 'origin', group = true })<cr>",
	-- 		desc = "Git Diff (origin)",
	-- 	},
	-- 	{ "<leader>gs", "<cmd>lua Snacks.picker.git_status()<cr>", desc = "Git Status" },
	-- 	{ "<leader>gS", "<cmd>lua Snacks.picker.git_stash()<cr>", desc = "Git Stash" },
	--
	-- 	-- grep
	-- 	{ "<leader>sb", "<cmd>lua Snacks.picker.lines()<cr>", desc = "Buffer Lines" },
	-- 	{ "<leader>sB", "<cmd>lua Snacks.picker.grep_buffers()<cr>", desc = "Grep Open Buffers" },
	-- 	{ "<leader>sg", "<cmd>lua Snacks.picker.pick('live_grep')<cr>", desc = "Grep" },
	-- 	{ "<leader>sG", "<cmd>lua Snacks.picker.pick('live_grep', { root = false })<cr>", desc = "Grep (Root Dir)" },
	--
	-- 	{
	-- 		"<leader>sw",
	-- 		"<cmd>lua Snacks.picker.pick('grep_word')<cr>",
	-- 		desc = "Visual selection or word",
	-- 		mode = { "n", "x" },
	-- 	},
	-- 	{
	-- 		"<leader>sW",
	-- 		"<cmd>lua Snacks.picker.pick('grep_word', { root = false })<cr>",
	-- 		desc = "Visual selection or word (Root Dir)",
	-- 		mode = { "n", "x" },
	-- 	},
	--
	-- 	-- search
	-- 	{ '<leader>s"', "<cmd>lua Snacks.picker.registers()<cr>", desc = "Registers" },
	-- 	{ "<leader>s/", "<cmd>lua Snacks.picker.search_history()<cr>", desc = "Search History" },
	-- 	{ "<leader>sa", "<cmd>lua Snacks.picker.autocmds()<cr>", desc = "Autocmds" },
	-- 	{ "<leader>sc", "<cmd>lua Snacks.picker.command_history()<cr>", desc = "Command History" },
	-- 	{ "<leader>sC", "<cmd>lua Snacks.picker.commands()<cr>", desc = "Commands" },
	-- 	{ "<leader>sd", "<cmd>lua Snacks.picker.diagnostics()<cr>", desc = "Diagnostics" },
	-- 	{ "<leader>sD", "<cmd>lua Snacks.picker.diagnostics_buffer()<cr>", desc = "Buffer Diagnostics" },
	-- 	{ "<leader>sh", "<cmd>lua Snacks.picker.help()<cr>", desc = "Help Pages" },
	-- 	{ "<leader>sH", "<cmd>lua Snacks.picker.highlights()<cr>", desc = "Highlights" },
	-- 	{ "<leader>si", "<cmd>lua Snacks.picker.icons()<cr>", desc = "Icons" },
	-- 	{ "<leader>sj", "<cmd>lua Snacks.picker.jumps()<cr>", desc = "Jumps" },
	-- 	{ "<leader>sk", "<cmd>lua Snacks.picker.keymaps()<cr>", desc = "Keymaps" },
	-- 	{ "<leader>sl", "<cmd>lua Snacks.picker.loclist()<cr>", desc = "Location List" },
	-- 	{ "<leader>sM", "<cmd>lua Snacks.picker.man()<cr>", desc = "Man Pages" },
	-- 	{ "<leader>sm", "<cmd>lua Snacks.picker.marks()<cr>", desc = "Marks" },
	-- 	{ "<leader>sR", "<cmd>lua Snacks.picker.resume()<cr>", desc = "Resume" },
	-- 	{ "<leader>sq", "<cmd>lua Snacks.picker.qflist()<cr>", desc = "Quickfix List" },
	-- 	{ "<leader>su", "<cmd>lua Snacks.picker.undo()<cr>", desc = "Undotree" },
	-- 	{ "<leader>st", "<cmd>lua Snacks.picker.todo_comments()<cr>", desc = "Todo" },
	--
	-- 	-- ui
	-- 	{ "<leader>uC", "<cmd>lua Snacks.picker.colorschemes()<cr>", desc = "Colorschemes" },
	-- },
}
