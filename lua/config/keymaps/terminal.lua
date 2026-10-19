local term_normal = {
	"jk",
	function()
		vim.cmd("stopinsert")
	end,
	mode = "t",
	expr = false,
	desc = "Single escape to normal mode",
}

local function win(position)
	return {
		position = position,
		border = position == "float" and "rounded" or nil,
		keys = {
			term_normal = term_normal,
		},
	}
end

local float = win("float")

local self_keys = {
	{
		"<leader>pu",
		function()
			vim.pack.update()
		end,
		desc = "Update Plugins",
	},
	{
		"<leader>gg",
		function()
			require("lazygit").open()
		end,
		desc = "Lazygit",
	},
	{
		"<leader>tf",
		function()
			require("terminal").toggle(nil, { win = float })
		end,
		desc = "Terminal Float",
	},
	{
		"<leader>tt",
		function()
			require("terminal").toggle(nil, { win = win("top") })
		end,
		desc = "Terminal Top",
	},
	{
		"<leader>tb",
		function()
			require("terminal").toggle(nil, { win = win("bottom") })
		end,
		desc = "Terminal Bottom",
	},
	{
		"<leader>tl",
		function()
			require("terminal").toggle(nil, { win = win("left") })
		end,
		desc = "Terminal Left",
	},
	{
		"<leader>tr",
		function()
			require("terminal").toggle(nil, { win = win("right") })
		end,
		desc = "Terminal Right",
	},
	{
		"<leader>tm",
		function()
			require("terminal").toggle("rmpc", { win = float })
		end,
		desc = "Music Player",
		silent = true,
		noremap = true,
	},
}

Utils.keymap.add(self_keys)
