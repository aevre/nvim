local libraries = vim.fn.glob(vim.fn.stdpath("data") .. "/lazy/*/lua", false, true)
vim.list_extend(libraries, {
	"${3rd}/luv/library",
	vim.env.VIMRUNTIME,
})

---@type vim.lsp.Config
return {
	cmd = { "lua-language-server" },
	filetypes = { "lua" },
	root_markers = { ".luarc.json", ".luarc.jsonc", ".git", "init.lua" },
	settings = {
		Lua = {
			runtime = { pathStrict = true },
			workspace = {
				checkThirdParty = false,
				library = libraries,
			},
		},
	},
	workspace_required = false,
}
