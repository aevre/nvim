local configs = {
	".eslintrc.js",
	".eslintrc.cjs",
	".eslintrc.json",
	".eslintrc.yaml",
	".eslintrc.yml",
	"eslint.config.js",
	"eslint.config.mjs",
	"eslint.config.cjs",
}

---@type LintSpec
return {
	linter = {
		condition = function(ctx)
			return #vim.fs.find(configs, {
				path = ctx.dirname,
				upward = true,
				stop = vim.uv.os_homedir(),
			}) > 0
		end,
	},
}
