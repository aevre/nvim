-- Code Completion
return {
	---@type LazyPluginSpec
	{
		"saghen/blink.cmp",
		event = { "InsertEnter", "CmdlineEnter" },
		dependencies = {
			"milanglacier/minuet-ai.nvim",
			"niuiic/blink-cmp-rg.nvim",
			"rafamadriz/friendly-snippets",
			"saghen/blink.lib",
			"nvim-mini/mini.icons",
			"xzbdmw/colorful-menu.nvim",
		},
		-- version = "1.*",
		build = function()
			require("blink.cmp").build():pwait()
		end,

		---@module 'blink.cmp'
		---@type blink.cmp.Config
		opts = {
			cmdline = {
				completion = {
					menu = { auto_show = true },
					list = { selection = { preselect = false } },
				},
			},
			completion = {
				trigger = { prefetch_on_insert = false },
				menu = {
					scrollbar = false,
					border = "rounded",
					draw = {
						padding = 0,
						treesitter = { "lsp" },
						columns = {
							{ "kind_icon" },
							{ "label", "label_description", gap = 1 },
							{ "kind" },
							{ "source_name" },
						},
					},
				},
				keyword = { range = "full" },
				list = { selection = { preselect = false } },
				documentation = { auto_show = true, auto_show_delay_ms = 500, window = { border = "rounded" } },
			},
			signature = {
				enabled = true,
				window = { border = "rounded", show_documentation = true },
			},
			sources = {
				default = {
					"complete_func",
					"omnifunc",
					"lsp",
					"snippets",
					"path",
					"buffer",
					"ripgrep",
					"minuet",
				},
				providers = {
					complete_func = {
						name = "CompleteFunc",
						module = "blink.cmp.sources.complete_func",
						enabled = function()
							return vim.bo.completefunc ~= ""
						end,
						opts = {
							complete_func = function()
								return vim.bo.completefunc
							end,
						},
					},
					omnifunc = {
						name = "OmniFunc",
						module = "blink.cmp.sources.complete_func",
						enabled = function()
							return vim.bo.omnifunc ~= "v:lua.vim.lsp.omnifunc"
						end,
						opts = {
							complete_func = function()
								return vim.bo.omnifunc
							end,
						},
					},
				},
			},
			fuzzy = {
				implementation = "prefer_rust",
				sorts = { "exact", "score", "sort_text" },
			},
			keymap = {
				preset = "none",
        -- stylua: ignore start
        ['<S-space>'] = { 'show', 'show_documentation', 'hide_documentation' },
        ['<C-h>'] = { 'hide', 'show' },
        ['<cr>'] = { 'accept', 'fallback' },
        ['<S-Tab>'] = { 'select_prev', 'snippet_backward', 'fallback' },
        ['<Tab>'] = {'select_next', 'snippet_forward', 'fallback'},
        ['<C-b>'] = { 'scroll_documentation_up', 'fallback' },
        ['<C-f>'] = { 'scroll_documentation_down', 'fallback' },
        ['<A-1>'] = { function(cmp) return cmp.accept({ index = 1 }) end },
        ['<A-2>'] = { function(cmp) return cmp.accept({ index = 2 }) end },
        ['<A-3>'] = { function(cmp) return cmp.accept({ index = 3 }) end },
        ['<A-4>'] = { function(cmp) return cmp.accept({ index = 4 }) end },
        ['<A-5>'] = { function(cmp) return cmp.accept({ index = 5 }) end },
        ['<A-6>'] = { function(cmp) return cmp.accept({ index = 6 }) end },
        ['<A-7>'] = { function(cmp) return cmp.accept({ index = 7 }) end },
        ['<A-8>'] = { function(cmp) return cmp.accept({ index = 8 }) end },
        ['<A-9>'] = { function(cmp) return cmp.accept({ index = 9 }) end },
        ['<A-0>'] = { function(cmp) return cmp.accept({ index = 10 }) end },
				-- stylua: ignore end
			},
		},
	},
}
