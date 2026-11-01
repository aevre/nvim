---@type LazyPluginSpec
return {
	"aevre/notify.nvim",
	name = "notify.nvim",
	dir = vim.env.NVIM_PLUGIN_MODE == "dev" and vim.fn.expand("~/Projects/lib/notify.nvim") or nil,
	lazy = false,
	dependencies = { "win.nvim", "animate.nvim" },
	---@type notify.Options
	opts = {
		timeout = 2000,
		max_width = 0.5,
		min_width = 40,
		max_height = 0.6,
		margin = { top = 1, right = 1, bottom = 0 },
		padding = 1,
		gap = 0,
		border = "rounded",
		top_down = true,
		max_history = 200,
		max_queue = 5,
		animate = true,
		stages = "fade_in_slide_out",
		animation = { duration = { step = 0.25, total = 240 }, easing = "outQuad", fps = 60 },
		style = "default",
		icons = {},
		lsp_progress = true,
		debug = true,
		merge_duplicates = 500,
		routes = {
			{
				match = {
					exact = { "notify" },
					message = {
						[[\v^\[nvim-treesitter/install/.+\]: (Downloading .+|Compiling parser|Installing parser|Language installed)$]],
					},
				},
				to = "treesitter-progress",
			},
			{ match = { exact = { "notify" }, message = { [[\vsaved .*]] } }, to = "fidget" },
			-- Route write confirmations and change summaries to Fidget; Vim regex, case-insensitive.
			{ match = { exact = { "notify" }, message = { [[\v\c(written|已写入)]] } }, to = "fidget" },
			{
				match = {
					exact = { "notify" },
					message = {
						[[\v^\d+ (行(发生改变|被去掉|被加入)；before #|(lines? (changed|removed|added|less)|fewer lines|more lines|changes?); (before|after) #)]],
					},
				},
				to = "fidget",
			},
			-- Keep other vim.notify() messages in the regular notification backend.
			{ match = { exact = { "notify" } }, to = "notify" },
			{ match = { prefix = { "msg.show." } }, to = "notify" },
		},
		fidget = {
			max_queue = 5,
			margin_left = 1,
			margin_right = 1,
			margin_bottom = 1,
			timeout = 3000,
			spinner_frames = { "⠋", "⠙", "⠹", "⠸", "⠼", "⠴", "⠦", "⠧", "⠇", "⠏" },
			spinner_interval = 200,
		},
	},
	config = function(_, opts)
		local notify = require("notify")
		notify.setup(opts)
		notify.unsubscribe("treesitter-install-progress")
		notify.subscribe(
			"treesitter-install-progress",
			{
				exact = { "notify" },
				message = {
					[[\v^\[nvim-treesitter/install/.+\]: (Downloading .+|Compiling parser|Installing parser|Language installed)$]],
				},
			},
			vim.log.levels.INFO,
			function(event)
				local parser, status = event.content:match("^%[nvim%-treesitter/install/([^%]]+)%]: (.+)$")
				local token = "treesitter-install:" .. parser
				if status == "Language installed" then
					notify.fidget.finish(token, status)
				else
					notify.fidget.send("Treesitter: " .. parser, status, { token = token, spinner = true })
				end
			end
		)
	end,
}
