-- leader key
vim.keymap.set("", "<Space>", "<Nop>")
vim.g.mapleader = " "
vim.g.maplocalleader = " "

_G.Utils = require("utils")
_G.Config = {}

-- local colorschemes = "tokyonight"

require("theme").setup({ transparent = not vim.g.neovide, json = true })

require("config.options")
require("config.filetype")
require("config.autocmds")
require("config.keymaps")
require("config.lsp")
require("config.bootstrap")
require("config.events").setup()
require("config.lazy").setup()
-- require("config.colorschemes").setup(colorschemes)

local signal, _ = vim.uv.new_signal()
if signal then
	signal:start(
		"sigusr1",
		vim.schedule_wrap(function()
			require("theme").apply()
		end)
	)
end
