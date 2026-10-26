-- Code Completion
return {
	---@type LazyPluginSpec
	{
		"saghen/blink.cmp",
		event = { "InsertEnter", "CmdlineEnter" },
		dependencies = {
			"milanglacier/minuet-ai.nvim",
			"niuiic/blink-cmp-rg.nvim",
			"saghen/blink.lib",
		},
		-- version = "1.*",
		build = function()
			require("blink.cmp").build():pwait()
		end,

		---@module 'blink.cmp'
		---@type blink.cmp.Config
		opts = {
			appearance = { nerd_font_variant = "mono" },
			cmdline = {
				enabled = true,
				completion = {
					menu = { auto_show = true },
					list = { selection = { preselect = false, auto_insert = true } },
				},
			},
			completion = {
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
				list = { selection = { preselect = false, auto_insert = true } },
				documentation = { auto_show = true, auto_show_delay_ms = 500, window = { border = "rounded" } },
				trigger = {
					show_on_keyword = true,
					show_on_insert_on_trigger_character = true,
					prefetch_on_insert = false,
				},
				accept = { dot_repeat = true, auto_brackets = { enabled = true } },
			},
			signature = {
				enabled = true,
				-- trigger = { show_on_insert = true },
				window = { border = "rounded", treesitter_highlighting = true, show_documentation = true },
			},
			snippets = { preset = "luasnip" },
			sources = {
				default = { "lsp", "snippets", "path", "buffer", "ripgrep", "minuet" },
				providers = {
					minuet = {
						name = "minuet",
						module = "minuet.blink",
						async = true,
						timeout_ms = 3000,
						score_offset = 50,
					},
					ripgrep = {
						name = "Ripgrep",
						module = "blink-cmp-rg",
						opts = {
							prefix_min_len = 3,
							get_command = function(_, prefix)
								return {
									"rg",
									"--no-config",
									"--json",
									"--word-regexp",
									"--ignore-case",
									"--",
									prefix .. "[\\w_-]+",
									vim.fs.root(0, ".git") or vim.fn.getcwd(),
								}
							end,
							get_prefix = function(context)
								return context.line:sub(1, context.cursor[2]):match("[%w_-]+$") or ""
							end,
						},
						max_items = 3,
						score_offset = -20,
					},
				},
			},
			fuzzy = {
				implementation = "prefer_rust",
				max_typos = function(k)
					return math.floor(#k / 4)
				end,
				frecency = {
					enabled = true,
					path = vim.fn.stdpath("state") .. "/blink/cmp/frecency.dat",
				},
				use_proximity = true,
				sorts = {
					"score",
					"exact",
					"sort_text",
				},
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
        ['<A-1>'] = { function(cmp) cmp.accept({ index = 1 }) end },
        ['<A-2>'] = { function(cmp) cmp.accept({ index = 2 }) end },
        ['<A-3>'] = { function(cmp) cmp.accept({ index = 3 }) end },
        ['<A-4>'] = { function(cmp) cmp.accept({ index = 4 }) end },
        ['<A-5>'] = { function(cmp) cmp.accept({ index = 5 }) end },
        ['<A-6>'] = { function(cmp) cmp.accept({ index = 6 }) end },
        ['<A-7>'] = { function(cmp) cmp.accept({ index = 7 }) end },
        ['<A-8>'] = { function(cmp) cmp.accept({ index = 8 }) end },
        ['<A-9>'] = { function(cmp) cmp.accept({ index = 9 }) end },
        ['<A-0>'] = { function(cmp) cmp.accept({ index = 10 }) end },
        ['<A-y>'] = { function() require('minuet').make_blink_map() end},
				-- stylua: ignore start
			},
		},
	},

	-- Completion Icon and Highlighting
	---@type LazyPluginSpec
	{
		"saghen/blink.cmp",
		opts = function(_, opts)
			local mini_icons = require("mini.icons")
			local colorful_menu = require("colorful-menu")

			opts.completion.menu.draw.components = vim.tbl_extend("force", opts.completion.menu.draw.components or {}, {
				kind_icon = {
					ellipsis = false,
					text = function(ctx)
						local icon, _, _ = mini_icons.get("lsp", ctx.kind)
						return icon .. (ctx.icon_gap or "")
					end,
					highlight = function(ctx)
						local _, hl, _ = mini_icons.get("lsp", ctx.kind)
						return hl
					end,
				},
				label = {
					width = { max = 20 },
					text = function(ctx)
						return colorful_menu.blink_components_text(ctx)
					end,
					highlight = function(ctx)
						return colorful_menu.blink_components_highlight(ctx)
					end,
				},
				kind = {
					highlight = function(ctx)
						if vim.tbl_contains({ "Path" }, ctx.source_name) then
							local type = ctx.item.data.type
							if ctx.item.data.type == "link" then
								type = "directory"
							end
							local mini_icon, mini_hl = require("mini.icons").get("default", type)
							if mini_icon then
								return mini_hl
							end
						end
						return ctx.kind_hl
					end,
				},

				label_description = {
					width = { max = 20 },
					text = function(ctx)
						return ctx.label_description
					end,
					highlight = "BlinkCmpLabelDescription",
				},
			})
		end,
	},
}
