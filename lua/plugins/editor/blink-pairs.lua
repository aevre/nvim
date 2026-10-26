---@type LazyPluginSpec
return {
	"saghen/blink.pairs",
	event = "BufEdit",
	version = "*",
	dependencies = "saghen/blink.lib",
	build = function()
		require("blink.pairs").download():pwait()
	end,

	---@type blink.pairs.Config
	opts = {
		mappings = {
			enabled = true,
			cmdline = true,
			disabled_filetypes = {},
			pairs = {},
			wrap = {
				-- move closing pair via motion
				["<C-b>"] = "motion",
				-- move opening pair via motion
				["<C-S-b>"] = "motion_reverse",
				-- set to 'treesitter' or 'treesitter_reverse' to use treesitter instead of motions
				-- set to nil, '' or false to disable the mapping
				-- normal_mode = {} <- for normal mode mappings, only supports 'motion' and 'motion_reverse'
			},
		},
		highlights = {
			enabled = true,
			cmdline = true,
			groups = {
				"BlinkPairsRed",
				"BlinkPairsYellow",
				"BlinkPairsBlue",
				"BlinkPairsOrange",
				"BlinkPairsGreen",
				"BlinkPairsPurple",
				"BlinkPairsCyan",
			},
			unmatched_group = "BlinkPairsUnmatched",

			matchparen = {
				enabled = true,
				cmdline = false,
				include_surrounding = false,
				group = "BlinkPairsMatchParen",
				priority = 250,
			},
		},
		debug = false,
	},
}
