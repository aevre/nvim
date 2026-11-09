---@type LazyPluginSpec
return {
	"danymat/neogen",
	cmd = "Neogen",
	opts = {
		snippet_engine = "nvim",
	},
	keys = {
		{
			"<leader>cn",
			function()
				require("neogen").generate()
			end,
			desc = "Generate Annotations (Neogen)",
		},
	},
}
