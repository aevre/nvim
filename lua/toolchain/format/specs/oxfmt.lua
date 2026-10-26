---@param ctx { filename: string }
---@param names string[]
---@return boolean
local function has_any_config(ctx, names)
	return #vim.fs.find(names, {
		path = vim.fs.dirname(ctx.filename),
		upward = true,
		stop = vim.uv.os_homedir(),
	}) > 0
end

local configs = {
	".oxfmtrc.json",
	".oxfmtrc.jsonc",
	"oxfmt.json",
	"oxfmt.jsonc",
}

local prettier_configs = {
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

local biome_configs = { "biome.json", "biome.jsonc" }

---@type FormatSpec
return {
	formatter = {
		---@param _ conform.FormatterConfig
		---@param ctx { filename: string }
		---@return boolean
		condition = function(_, ctx)
			if has_any_config(ctx, configs) then
				return true
			end
			return not (has_any_config(ctx, prettier_configs) or has_any_config(ctx, biome_configs))
		end,
	},
}
