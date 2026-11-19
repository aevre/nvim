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
							return vim.bo.omnifunc ~= ""
						end,
						opts = {
							complete_func = function()
								return vim.bo.omnifunc
							end,
						},
					},
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
        ['<A-y>'] = { function(cmp)
          require('minuet').change_preset('openrouter')
          return cmp.show({ providers = { 'minuet' } })
        end },
        ['<A-o>'] = { function(cmp)
          require('minuet').change_preset('ollama')
          return cmp.show({ providers = { 'minuet' } })
        end },
				-- stylua: ignore end
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
			local kind_icons = {
				Array = "󰅪",
				Boolean = "󰨙",
				Class = "󰠱",
				Color = "󰏘",
				Constant = "󰏿",
				Constructor = "",
				Enum = "",
				EnumMember = "",
				Event = "",
				Field = "󰜢",
				File = "󰈙",
				Folder = "󰉋",
				Function = "󰊕",
				Interface = "",
				Key = "󰌋",
				Keyword = "󰌋",
				Method = "󰡱",
				Module = "󰏗",
				Namespace = "󰏗",
				Null = "󰟢",
				Number = "󰎠",
				Object = "󰅩",
				Operator = "󰆕",
				Package = "󰏗",
				Property = "󰜢",
				Reference = "󰈇",
				Snippet = "󰲋",
				String = "󰉿",
				Struct = "󰙅",
				Text = "󰉿",
				TypeParameter = "󰊄",
				Unit = "󰑭",
				Value = "󰎠",
				Variable = "󰫧",
				minuet = "󰚩",
			}

			opts.completion.menu.draw.components = vim.tbl_extend("force", opts.completion.menu.draw.components or {}, {
				kind_icon = {
					ellipsis = false,
					text = function(ctx)
						local kind = ctx.source_name == "minuet" and "minuet" or ctx.kind
						local icon = kind_icons[kind]
						if not icon then
							icon = mini_icons.get("lsp", kind)
						end
						return (icon or "") .. (ctx.icon_gap or "")
					end,
					highlight = function(ctx)
						local kind = ctx.source_name == "minuet" and "minuet" or ctx.kind
						local _, hl, _ = mini_icons.get("lsp", kind)
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
							local path_type = ctx.item.data.type
							local category = (path_type == "directory" or path_type == "link") and "directory" or "file"
							local mini_icon, mini_hl = mini_icons.get("default", category)
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
