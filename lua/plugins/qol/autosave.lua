---@type LazyPluginSpec
return {
	"aevre/autosave.nvim",
	name = "autosave.nvim",
	dir = vim.env.NVIM_PLUGIN_MODE == "dev" and vim.fn.expand("~/Projects/lib/autosave.nvim") or nil,
	event = { "BufReadPost", "BufNewFile", "BufWritePre" },
	---@type autosave.Config
	opts = {
		notify = false,
		delay = 1000,
		filter = function(buf)
			return vim.bo[buf].filetype ~= "oil"
		end,
	},
}
