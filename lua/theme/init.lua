local M = {}

local config_path = vim.fn.stdpath("config")
local palette_path = config_path .. "/palette.json"

---@alias theme.Variant "dark"|"light"|"auto"

---@class theme.Options
---@field variant theme.Variant
---@field transparent boolean
---@field json boolean
M.opts = {
	json = false,
	variant = "auto",
	transparent = false,
}

---@return "dark" | "light"
function M.get_variant()
	if M.opts.variant == "auto" then
		return vim.o.background
	end
	return M.opts.variant
end

---@return theme.Palettes|theme.Palette|nil
local function read_json()
	if not M.opts.json then
		return nil
	end
	local file = io.open(palette_path, "r")
	if not file then
		return nil
	end

	local content = file:read("a")
	file:close()

	local ok, data = pcall(vim.json.decode, content)
	if not ok or type(data) ~= "table" then
		return nil
	end
	return data
end

---@param palettes theme.Palettes
---@param variant "dark" | "light"
---@return theme.Palette
local function resolve_palette(palettes, variant)
	local json = read_json()

	if not json then
		return palettes[variant]
	end

	local has_variants = type(json.dark) == "table" or type(json.light) == "table"

	if has_variants then
		local override = json[variant]

		if type(override) ~= "table" then
			return palettes[variant]
		end
		return vim.tbl_deep_extend("force", palettes[variant], override)
	end
	return vim.tbl_deep_extend("force", palettes[variant], json)
end

---@return theme.Palette
local function load_palette()
	local palettes = require("theme.palette")
	local variant = M.get_variant()
	return resolve_palette(palettes, variant)
end

function M.get_palette()
	return load_palette()
end

local neovide_transparent_opacity = tonumber(vim.g.neovide_opacity) or 1

local function transparent_path()
	return vim.fn.stdpath("data") .. "/transparent"
end

local function is_transparent()
	return vim.uv.fs_stat(transparent_path()) ~= nil
end

local function sync_transparent()
	local transparent = is_transparent()
	M.opts.transparent = transparent and not vim.g.neovide
	if vim.g.neovide then
		vim.g.neovide_opacity = transparent and neovide_transparent_opacity or 1
	end
	M.apply()
end

function M.setup(options)
	M.opts = vim.tbl_deep_extend("force", M.opts, options or {})
	sync_transparent()
end

function M.toggle_transparent()
	local path = transparent_path()
	if is_transparent() then
		os.remove(path)
	else
		local file = io.open(path, "w")
		if file then
			file:close()
		end
	end

	sync_transparent()
end

function M.apply()
	local palette = load_palette()
	require("theme.highlights").setup(palette, M.opts.transparent)
	local groups = require("theme.plugins").setup(palette, M.opts)

	for name, opts in pairs(groups) do
		vim.api.nvim_set_hl(0, name, opts)
	end

	vim.api.nvim_exec_autocmds("User", {
		pattern = "ThemeApply",
	})
end

vim.api.nvim_create_autocmd("OptionSet", {
	pattern = "background",
	callback = function()
		if M.opts.variant == "auto" then
			M.apply()
		end
	end,
})

vim.api.nvim_create_user_command("TransparentToggle", M.toggle_transparent, {
	desc = "Toggle transparent background",
})

return M
