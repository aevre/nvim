---@type LazyPluginSpec
return {
	"goolord/alpha-nvim",
	dependencies = { "nvim-mini/mini.icons" },
	event = "VimEnter",
	-- enabled = false,
	opts = function()
		local dashboard = require("alpha.themes.dashboard")

		local logo = [[

         ▀████▀▄▄              ▄█
           █▀    ▀▀▄▄▄▄▄    ▄▄▀▀█
  ▄        █          ▀▀▀▀▄  ▄▀
 ▄▀ ▀▄      ▀▄              ▀▄▀
▄▀    █     █▀   ▄█▀▄      ▄█
▀▄     ▀▄  █     ▀██▀     ██▄█
 ▀▄    ▄▀ █   ▄██▄   ▄  ▄  ▀▀ █
  █  ▄▀  █    ▀██▀    ▀▀ ▀▀  ▄▀
 █   █  █      ▄▄           ▄▀
]]

		dashboard.section.header.val = vim.split(logo, "\n")

    -- stylua: ignore
    dashboard.section.buttons.val = {
      dashboard.button("f", "  Find File",        "<cmd>lua Fzflua.files()<cr>"),
      dashboard.button("g", "  Find Text",        "<cmd>lua Fzflua.live_grep_native()<cr>"),
      dashboard.button("r", "  Recent Files",     "<cmd>lua Fzflua.oldfiles()<cr>"),
      dashboard.button("c", "  Config",           "<cmd>lua Fzflua.files({ cwd = vim.fn.stdpath('config') })<cr>"),
      dashboard.button("s", "  Restore Session",  "<cmd>lua require('session').load()<cr>"),
      dashboard.button("S", "󰙰  Select Session",   "<cmd>lua require('session').select()<cr>"),
      dashboard.button("L", "󰒲  Lazy",             "<cmd>Lazy<cr>"),
      dashboard.button("q", "  Quit",             "<cmd>qa<cr>"),
    }

		dashboard.section.buttons.opts.spacing = 0

		for _, button in ipairs(dashboard.section.buttons.val) do
			button.opts.hl = "AlphaButtons"
			button.opts.hl_shortcut = "AlphaShortcut"
		end

		dashboard.section.header.opts.hl = "AlphaHeader"
		dashboard.section.buttons.opts.hl = "AlphaButtons"
		dashboard.section.footer.opts.hl = "AlphaFooter"

		dashboard.opts.layout[1].val = 8
		dashboard.opts.layout[3].val = 2

		return dashboard
	end,

	config = function(_, dashboard)
		-- Close Lazy and reopen it after Alpha is ready.
		if vim.o.filetype == "lazy" then
			vim.cmd.close()

			vim.api.nvim_create_autocmd("User", {
				pattern = "AlphaReady",
				once = true,
				callback = function()
					require("lazy").show()
				end,
			})
		end

		require("alpha").setup(dashboard.opts)

		vim.api.nvim_create_autocmd("User", {
			pattern = "AlphaReady",
			callback = function()
				vim.opt.laststatus = 0

				vim.api.nvim_create_autocmd("BufUnload", {
					buffer = 0,
					once = true,
					callback = function()
						vim.opt.laststatus = 3
					end,
				})
			end,
		})

		vim.schedule(function()
			local stats = require("lazy").stats()
			local ms = math.floor(stats.startuptime * 100 + 0.5) / 100

			dashboard.section.footer.val =
				string.format("⚡ Neovim loaded %d/%d plugins in %.2fms", stats.loaded, stats.count, ms)

			pcall(vim.cmd.AlphaRedraw)
		end)
	end,
}
