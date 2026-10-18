local M = {}

-- stylua: ignore
M.plugins = {
	["builtin"]                     = "builtin",
	["win.nvim"]                     = "win",
	["aerial.nvim"]                   = "aerial",
  ["alpha-nvim"]                    = "alpha",
  ["blink.cmp"]                     = "blink",
  ["flash.nvim"]                    = "flash",
  ["fzf-lua"]                       = "fzf",
  ["grug-far.nvim"]                 = "grug-far",
  ["lazy.nvim"]                     = "lazy",
  ["mini.diff"]                     = "mini_diff",
  ["mini.files"]                    = "mini_files",
  ["mini.hipatterns"]               = "mini_hipatterns",
  ["mini.icons"]                    = "mini_icons",
  -- ["mini.jump"]                     = "mini_jump",
  -- ["mini.pick"]                     = "mini_pick",
  ["mini.surround"]                 = "mini_surround",
  ["noice.nvim"]                    = "noice",
  ["notify.nvim"]                   = "notify",
  ["nvim-treesitter-context"]       = "treesitter-context",
  ["nvim-treesitter"]               = "treesitter",
  ["which-key.nvim"]                = "which-key",
  ["yanky.nvim"]                    = "yanky",
  ["extra"]                         = "extra"
}

function M.get_group(name)
	return require("theme.plugins." .. name)
end

---@param name string
---@param palette theme.Palette
---@param config theme.Options
function M.get(name, palette, config)
	return M.get_group(name).get(palette, config)
end

---@param palette theme.Palette
---@param config theme.Options
function M.setup(palette, config)
	local groups = {}

	for _, name in pairs(M.plugins) do
		for group, opts in pairs(M.get(name, palette, config)) do
			if type(opts) == "string" then
				opts = { link = opts }
			end

			groups[group] = opts
		end
	end

	return groups
end

return M
