---@type LazyPluginSpec
return {
	name = "builtin",
	dir = vim.fn.stdpath("config"),
	lazy = false,
	priority = 1000,
	main = "builtin",
	opts = {},
}
