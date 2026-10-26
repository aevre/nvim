local configs = {
	".prettierrc",
	".prettierrc.json",
	".prettierrc.js",
	".prettierrc.yaml",
	".prettierrc.yml",
	".prettierrc.toml",
	"prettier.config.js",
	"prettier.config.cjs",
	"prettier.config.mjs",
}

---@type FormatSpec
return {
	formatter = {
		condition = function(_, ctx)
			return #vim.fs.find(configs, {
				path = vim.fs.dirname(ctx.filename),
				upward = true,
				stop = vim.uv.os_homedir(),
			}) > 0
		end,
	},
}
