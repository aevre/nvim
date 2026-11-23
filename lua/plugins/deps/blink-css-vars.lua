---@type LazyPluginSpec[]
return {
	{
		"aevre/blink-css-vars.nvim",
		name = "blink-css-vars.nvim",
		dir = vim.env.NVIM_PLUGIN_MODE == "dev" and vim.fn.expand("~/Projects/lib/blink-css-vars.nvim") or nil,
		lazy = true,
	},
	{
		"saghen/blink.cmp",
		optional = true,
		opts = {
			sources = {
				default = { "css_vars" },
				providers = {
					css_vars = {
						name = "CSS Vars",
						module = "blink-css-vars.blink",
					},
				},
			},
		},
	},
}
