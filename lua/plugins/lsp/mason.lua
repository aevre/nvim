---@type LazyPluginSpec[]
return {
	-- Mason
	{
		"mason-org/mason.nvim",
		cmd = "Mason",

		---@type MasonSettings
		opts = {
			ui = {
				icons = {
					package_installed = "✓",
					package_pending = "➜",
					package_uninstalled = "✗",
				},
			},
			keymaps = {
				toggle_package_expand = "l",
				toggle_package_install_log = "l",
			},
		},
		keys = {
			{ "<leader>cm", "<cmd>Mason<cr>", desc = "Mason" },
		},
	},

	-- Mason-lspconfig
	{
		"mason-org/mason-lspconfig.nvim",
		dependencies = { "mason-org/mason.nvim" },
		event = "VeryLazy",

		---@type MasonLspconfigSettings
		opts = {
			automatic_enable = false,
		},
		config = function()
			local mr = require("mason-registry")

			local function install(filetype)
				local pending = 0
				local function ready()
					if pending > 0 then
						return
					end
					vim.schedule(function()
						require("toolchain").lang.enable_for_open_buffers()
						vim.api.nvim_exec_autocmds("User", { pattern = "ToolchainReady" })
					end)
				end

				for _, tool in ipairs(require("toolchain").get_mason_packages(filetype)) do
					if mr.has_package(tool) then
						local package = mr.get_package(tool)
						if not package:is_installed() and not package:is_installing() then
							pending = pending + 1
							vim.notify(("Installing %s…"):format(tool), vim.log.levels.INFO, { title = "Mason" })
							package:install(nil, function()
								pending = pending - 1
								ready()
							end)
						end
					else
						vim.notify(("Mason package not found: %s"):format(tool), vim.log.levels.WARN)
					end
				end
				ready()
			end

			local function install_buffer(bufnr)
				if vim.bo[bufnr].buftype == "" and vim.api.nvim_buf_get_name(bufnr) ~= "" then
					install(vim.bo[bufnr].filetype)
				end
			end

			mr.refresh(function()
				vim.api.nvim_create_autocmd("FileType", {
					group = vim.api.nvim_create_augroup("MasonInstallByFiletype", { clear = true }),
					callback = function(event)
						install_buffer(event.buf)
					end,
				})
				for _, bufnr in ipairs(vim.api.nvim_list_bufs()) do
					if vim.api.nvim_buf_is_loaded(bufnr) then
						install_buffer(bufnr)
					end
				end
			end)
		end,
	},
}
