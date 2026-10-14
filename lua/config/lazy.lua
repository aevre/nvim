local M = {}

function M.setup(extra_plugins)
	local plugin_spec = {
		{ import = "plugins" },
		{ import = "plugins.coding" },
		{ import = "plugins.colorschemes" },
		{ import = "plugins.deps" },
		{ import = "plugins.editor" },
		{ import = "plugins.highlight" },
		{ import = "plugins.lsp" },
		{ import = "plugins.qol" },
		{ import = "plugins.ui" },
	}

	---@type LazyConfig
	local opts = {
		defaults = {
			version = nil,
		},
		spec = vim.list_extend(plugin_spec, extra_plugins or {}),
		dev = {
			path = function(plugin)
				local dir = vim.env.NVIM_DEV_DIR or ""
				return vim.fs.joinpath(dir, plugin.name)
			end,
			patterns = { "." },
			fallback = true,
		},
		install = { colorscheme = nil },
		checker = { enabled = true },
		ui = {
			border = "rounded",
		},
		git = {
			log = { "-4" },
		},
	}

	require("lazy").setup(opts)
	Utils.keymap.add({ { "<leader>L", "<cmd>Lazy<cr>", desc = "Lazy" } })
end

return M
