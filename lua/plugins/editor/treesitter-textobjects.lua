---@type LazyPluginSpec
return {
	"nvim-treesitter/nvim-treesitter-textobjects",
	branch = "main",
	event = "BufEdit",
	dependencies = { "nvim-treesitter/nvim-treesitter" },
	init = function()
		vim.g.no_plugin_maps = true
	end,
	config = function()
		---@type TSTextObjects.Config
		local opts = {
			move = {
				set_jumps = true,
			},
			swap = {
				enable = true,
			},
		}
		local ok, TSTextObjects = pcall(require, "nvim-treesitter-textobjects")
		if not ok or TSTextObjects == nil then
			return
		end
		---@diagnostic disable-next-line: param-type-mismatch
		TSTextObjects.setup(opts)

		local TSTextObjectsRepeat = require("nvim-treesitter-textobjects.repeatable_move")
		local TSTextObjectsMove = require("nvim-treesitter-textobjects.move")
		local TSTextObjectsSwap = require("nvim-treesitter-textobjects.swap")

		---@type utils.keymap.config[]
		local keys = {
			{
				";",
				TSTextObjectsRepeat.repeat_last_move_next,
				mode = { "n", "x", "o" },
				desc = "Repeat last move next",
			},
			{
				",",
				TSTextObjectsRepeat.repeat_last_move_previous,
				mode = { "n", "x", "o" },
				desc = "Repeat last move previous",
			},

			{ "f", TSTextObjectsRepeat.builtin_f_expr, mode = { "n", "x", "o" }, expr = true },
			{ "F", TSTextObjectsRepeat.builtin_F_expr, mode = { "n", "x", "o" }, expr = true },
			{ "t", TSTextObjectsRepeat.builtin_t_expr, mode = { "n", "x", "o" }, expr = true },
			{ "T", TSTextObjectsRepeat.builtin_T_expr, mode = { "n", "x", "o" }, expr = true },

			{
				"]z",
				function()
					TSTextObjectsMove.goto_next_start("@fold", "folds")
				end,
				mode = { "n", "x", "o" },
				desc = "Goto next fold point",
			},
			{
				"]f",
				function()
					TSTextObjectsMove.goto_next_start("@function.outer", "textobjects")
				end,
				mode = { "n", "x", "o" },
				desc = "Next function start",
			},
			{
				"]F",
				function()
					TSTextObjectsMove.goto_next_end("@function.outer", "textobjects")
				end,
				mode = { "n", "x", "o" },
				desc = "Next function end",
			},
			{
				"[F",
				function()
					TSTextObjectsMove.goto_previous_end("@function.outer", "textobjects")
				end,
				mode = { "n", "x", "o" },
				desc = "Previous function end",
			},
			{
				"[f",
				function()
					TSTextObjectsMove.goto_previous_start("@function.outer", "textobjects")
				end,
				mode = { "n", "x", "o" },
				desc = "Previous function start",
			},
			{
				"]c",
				function()
					TSTextObjectsMove.goto_next_start("@class.outer", "textobjects")
				end,
				mode = { "n", "x", "o" },
				desc = "Next class start",
			},
			{
				"[c",
				function()
					TSTextObjectsMove.goto_previous_start("@class.outer", "textobjects")
				end,
				mode = { "n", "x", "o" },
				desc = "Previous class start",
			},
			{
				"]C",
				function()
					TSTextObjectsMove.goto_next_end("@class.outer", "textobjects")
				end,
				mode = { "n", "x", "o" },
				desc = "Next class end",
			},
			{
				"[C",
				function()
					TSTextObjectsMove.goto_previous_end("@class.outer", "textobjects")
				end,
				mode = { "n", "x", "o" },
				desc = "Previous class end",
			},
			{
				"]a",
				function()
					TSTextObjectsMove.goto_next_start("@parameter.inner", "textobjects")
				end,
				mode = { "n", "x", "o" },
				desc = "Next argument start",
			},
			{
				"[a",
				function()
					TSTextObjectsMove.goto_previous_start("@parameter.inner", "textobjects")
				end,
				mode = { "n", "x", "o" },
				desc = "Previous argument start",
			},
			{
				"]A",
				function()
					TSTextObjectsMove.goto_next_end("@parameter.inner", "textobjects")
				end,
				mode = { "n", "x", "o" },
				desc = "Next argument end",
			},
			{
				"[A",
				function()
					TSTextObjectsMove.goto_previous_end("@parameter.inner", "textobjects")
				end,
				mode = { "n", "x", "o" },
				desc = "Previous argument end",
			}, -- 交换参数 (Argument) 顺序
			{
				"<leader>ma",
				function()
					TSTextObjectsSwap.swap_next("@parameter.inner")
				end,
				desc = "Swap next argument",
			},
			{
				"<leader>mA",
				function()
					TSTextObjectsSwap.swap_previous("@parameter.inner")
				end,
				desc = "Swap previous argument",
			},
			{
				"<leader>mf",
				function()
					TSTextObjectsSwap.swap_next("@function.outer")
				end,
				desc = "Swap next function",
			},
			{
				"<leader>mF",
				function()
					TSTextObjectsSwap.swap_previous("@function.outer")
				end,
				desc = "Swap previous function",
			},
			{
				"]=",
				function()
					TSTextObjectsMove.goto_next_start("@assignment.outer", "textobjects")
				end,
				desc = "Next assignment",
			},
			{
				"[=",
				function()
					TSTextObjectsMove.goto_previous_start("@assignment.outer", "textobjects")
				end,
				desc = "Previous assignment",
			},
			{
				"]r",
				function()
					TSTextObjectsMove.goto_next_start("@return.outer", "textobjects")
				end,
				desc = "Next return",
			},
			{
				"[r",
				function()
					TSTextObjectsMove.goto_previous_start("@return.outer", "textobjects")
				end,
				desc = "Previous return",
			},
		}
		Utils.keymap.add(keys)
	end,
}
