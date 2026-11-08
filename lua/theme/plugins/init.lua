local M = {}

local detect = require("theme.plugins.detect")

---@class theme.PluginAdapter
---@field id string
---@field adapter string
---@field always? boolean
---@field modules? string[]
---@field names? string[]
---@field repos? string[]
---@field urls? string[]
---@field priority? integer
---@field shared? string[]

---@type theme.PluginAdapter[]
M.plugins = {
	{ id = "builtin", adapter = "builtin", always = true },
	{ id = "extra", adapter = "extra", always = true },
	{ id = "cmdline.nvim", adapter = "cmdline", modules = { "cmdline" }, repos = { "aevre/cmdline.nvim" } },
	{ id = "win.nvim", adapter = "win", modules = { "win" }, repos = { "aevre/win.nvim" } },
	{ id = "aerial.nvim", adapter = "aerial", modules = { "aerial" }, repos = { "stevearc/aerial.nvim" } },
	{ id = "alpha-nvim", adapter = "alpha", modules = { "alpha" }, repos = { "goolord/alpha-nvim" } },
	{ id = "blink.cmp", adapter = "blink", modules = { "blink.cmp" }, repos = { "saghen/blink.cmp" } },
	{ id = "flash.nvim", adapter = "flash", modules = { "flash" }, repos = { "folke/flash.nvim" } },
	{ id = "fzf-lua", adapter = "fzf", modules = { "fzf-lua" }, repos = { "ibhagwan/fzf-lua" } },
	{ id = "grug-far.nvim", adapter = "grug-far", modules = { "grug-far" }, repos = { "MagicDuck/grug-far.nvim" } },
	{ id = "lazy.nvim", adapter = "lazy", modules = { "lazy" }, repos = { "folke/lazy.nvim" } },
	{ id = "mini.diff", adapter = "mini_diff", modules = { "mini.diff" }, repos = { "nvim-mini/mini.diff" } },
	{ id = "mini.files", adapter = "mini_files", modules = { "mini.files" }, repos = { "nvim-mini/mini.files" } },
	{
		id = "mini.hipatterns",
		adapter = "mini_hipatterns",
		modules = { "mini.hipatterns" },
		repos = { "nvim-mini/mini.hipatterns" },
	},
	{ id = "mini.icons", adapter = "mini_icons", modules = { "mini.icons" }, repos = { "nvim-mini/mini.icons" } },
	{
		id = "mini.surround",
		adapter = "mini_surround",
		modules = { "mini.surround" },
		repos = { "nvim-mini/mini.surround" },
	},
	{ id = "noice.nvim", adapter = "noice", modules = { "noice" }, repos = { "folke/noice.nvim" } },
	{
		id = "nvim-notify",
		adapter = "nvim_notify",
		modules = { "notify" },
		repos = { "rcarriga/nvim-notify" },
		priority = 10,
		shared = { "Notify*" },
	},
	{
		id = "notify.nvim",
		adapter = "notify",
		modules = { "notify" },
		repos = { "aevre/notify.nvim" },
		urls = { "https://codeberg.org/aevre/notify.nvim" },
		priority = 20,
		shared = { "Notify*" },
	},
	{ id = "terminal.nvim", adapter = "terminal", modules = { "terminal" }, repos = { "aevre/terminal.nvim" } },
	{
		id = "nvim-treesitter-context",
		adapter = "treesitter-context",
		modules = { "treesitter-context" },
		repos = { "nvim-treesitter/nvim-treesitter-context" },
	},
	{
		id = "nvim-treesitter",
		adapter = "treesitter",
		modules = { "nvim-treesitter" },
		repos = { "nvim-treesitter/nvim-treesitter" },
	},
	{
		id = "which-key.nvim",
		adapter = "which-key",
		modules = { "which-key" },
		repos = { "folke/which-key.nvim" },
	},
	{ id = "yanky.nvim", adapter = "yanky", modules = { "yanky" }, repos = { "gbprod/yanky.nvim" } },
}

local function matches(patterns, name)
	for _, pattern in ipairs(patterns or {}) do
		local lua_pattern = "^" .. vim.pesc(pattern):gsub("%%%*", ".*") .. "$"
		if name:match(lua_pattern) then
			return true
		end
	end
	return false
end

local function aliases(spec)
	local ret = {}
	for _, value in ipairs({ spec.id, spec.adapter }) do
		for _, key in ipairs(detect.keys(value)) do
			ret[key] = true
		end
	end
	for _, field in ipairs({ "names", "repos", "urls", "modules" }) do
		for _, value in ipairs(spec[field] or {}) do
			for _, key in ipairs(detect.keys(value)) do
				ret[key] = true
			end
		end
	end
	return ret
end

---@param ref string|theme.PluginAdapter
---@return theme.PluginAdapter?
function M.resolve(ref)
	if type(ref) == "table" then
		return ref
	end

	local keys = detect.keys(ref)
	local found
	for _, spec in ipairs(M.plugins) do
		local known = aliases(spec)
		for _, key in ipairs(keys) do
			if known[key] then
				if found and found ~= spec then
					return nil
				end
				found = spec
				break
			end
		end
	end
	return found
end

---@param ref string|theme.PluginAdapter
---@return theme.PluginStatus?
function M.status(ref)
	local spec = M.resolve(ref)
	return spec and detect.status(spec) or nil
end

---@param ref string|theme.PluginAdapter
---@param state? "declared"|"installed"|"loaded"|"imported"|"available"
---@return boolean
function M.has(ref, state)
	local spec = M.resolve(ref)
	return spec ~= nil and detect.has(spec, state)
end

function M.get_group(name)
	return require("theme.plugins." .. name)
end

---@param name string
---@param palette theme.Palette
---@param config theme.Options
function M.get(name, palette, config)
	return M.get_group(name).get(palette, config)
end

---@param groups table<string, table|string>
---@param owners table<string, theme.PluginAdapter>
---@param spec theme.PluginAdapter
---@param adapter_groups table<string, table|string>
local function merge(groups, owners, spec, adapter_groups)
	for group, opts in pairs(adapter_groups) do
		if type(opts) == "string" then
			opts = { link = opts }
		end

		local owner = owners[group]
		local replace = true
		if owner then
			local shared = matches(owner.shared, group) and matches(spec.shared, group)
			if not shared then
				error(("highlight group %q is owned by both %q and %q"):format(group, owner.id, spec.id))
			end
			replace = (owner.priority or 0) <= (spec.priority or 0)
		end

		if replace then
			groups[group] = opts
			owners[group] = spec
		end
	end
end

---@param palette theme.Palette
---@param config theme.Options
---@param state? "declared"|"installed"|"loaded"|"imported"|"available"
function M.setup(palette, config, state)
	local groups = {}
	local owners = {}
	state = state or "installed"

	for _, spec in ipairs(M.plugins) do
		if spec.always or detect.has(spec, state) then
			merge(groups, owners, spec, M.get(spec.adapter, palette, config))
		end
	end

	return groups
end

return M
