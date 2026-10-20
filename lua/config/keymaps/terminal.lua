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
		"<leader>ts",
		function()
			require("terminal").select()
		end,
		desc = "Select Terminal",
	},
	{
		"<leader>tf",
		function()
			require("terminal").toggle(nil, { win = win("float") })
		end,
		desc = "Terminal Float",
	},
	{
		"<leader>tk",
		function()
			require("terminal").toggle(nil, { win = win("top") })
		end,
		desc = "Terminal Top",
	},
	{
		"<leader>tj",
		function()
			require("terminal").toggle(nil, { win = win("bottom") })
		end,
		desc = "Terminal Bottom",
	},
	{
		"<leader>th",
		function()
			require("terminal").toggle(nil, { win = win("left") })
		end,
		desc = "Terminal Left",
	},
	{
		"<leader>tl",
		function()
			require("terminal").toggle(nil, { win = win("right") })
		end,
		desc = "Terminal Right",
	},
	{
		"<leader>tm",
		function()
			require("terminal").toggle("rmpc", { win = win("float") })
		end,
		desc = "Music Player",
		silent = true,
		noremap = true,
	},
}

Utils.keymap.add(self_keys)
