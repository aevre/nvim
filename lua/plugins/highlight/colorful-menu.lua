-- Auto Completion Menu Highlight
---@type LazyPluginSpec[]
return {
	{
		"xzbdmw/colorful-menu.nvim",
		lazy = true,
		---@type ColorfulMenuConfig
		opts = {},
	},
	{
		"saghen/blink.cmp",
		optional = true,
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
