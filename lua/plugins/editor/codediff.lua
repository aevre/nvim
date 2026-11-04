---@type LazyPluginSpec
return {
	"dlyongemallo/diffview-plus.nvim",
	version = "*",
	cmd = {
		"DiffviewOpen",
		"DiffviewToggle",
		"DiffviewFileHistory",
		"DiffviewDiffFiles",
		"DiffviewLog",
	},
	opts = {},
	keys = {
		{ "<leader>cD", "<cmd>DiffviewToggle<cr>", desc = "Code Diff" },
	},
}
