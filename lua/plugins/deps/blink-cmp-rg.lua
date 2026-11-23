---@type LazyPluginSpec[]
return {
	{
		"niuiic/blink-cmp-rg.nvim",
		lazy = true,
	},
	{
		"saghen/blink.cmp",
		optional = true,
		opts = {
			sources = {
				providers = {
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
		},
	},
}
