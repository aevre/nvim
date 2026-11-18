---@type LazySpec
return {
	"aevre/luma.nvim",
	dir = vim.env.NVIM_PLUGIN_MODE == "dev" and vim.fn.expand("~/Projects/lib/luma.nvim") or nil,
	name = "luma.nvim",
	event = "BufReadPost",
	dependencies = {
		"win.nvim",
		"animate.nvim",
	},
	opts = {
		model = "openrouter",
		prompt = "You are a helpful Chinese coding assistant.",
		max_tokens = 8000,
		temperature = 0.3,
		history = {
			path = vim.fn.stdpath("cache") .. "/luma-history",
			max = 15,
		},
		ui = {
			position = "float",
			width = 0.8,
			height = 0.8,
			input_height = 0.18,
			border = "rounded",
		},
		models = {
			openrouter = {
				backend = "openai",
				model = "cohere/north-mini-code:free",
				url = "https://openrouter.ai/api/v1/chat/completions",
				api_key = "OPENROUTER_TOKEN",
			},
		},
		web_search = {
			api_key = "TAVILY_TOKEN",
			url = "https://api.tavily.com/search",
			max_results = 3,
		},
		tools = require("plugins.qol.luma.tools"),
	},
	keys = {
		{ "<leader>ac", "<cmd>LumaToggle<cr>", desc = "Toggle Luma Chat" },
		{
			"<leader>aa",
			":LumaTool attach<cr>",
			mode = "x",
			desc = "Add the selected text to the current Luma conversation as context",
		},
		{ "<leader>ak", "<cmd>LumaTool ask<cr>", desc = "Enter a question and send it to the configured model" },
		{ "<leader>ae", "<cmd>LumaTool explain<cr>", desc = "Explain the current buffer in Chinese" },
		{
			"<leader>ae",
			":LumaTool explain<cr>",
			mode = "x",
			desc = "Explain the selected code in Chinese",
		},
		{
			"<leader>aw",
			"<cmd>LumaTool word_translate<cr>",
			desc = "Translate the word under the cursor between Chinese and English",
		},
		{
			"<leader>aw",
			":LumaTool word_translate<cr>",
			mode = "x",
			desc = "Translate the selected text between Chinese and English",
		},
		{
			"<leader>at",
			"<cmd>LumaTool translate<cr>",
			desc = "Open an independent translator with its own model and history",
		},
		{
			"<leader>aT",
			":LumaTool tests<cr>",
			mode = "x",
			desc = "Generate test code for the selected implementation",
		},
		{
			"<leader>ao",
			":LumaTool rewrite<cr>",
			mode = "x",
			desc = "Rewrite the selected text according to an instruction and preview the diff",
		},
		{
			"<leader>ag",
			"<cmd>LumaTool commit<cr>",
			desc = "Generate a commit message from staged changes for review",
		},
		{ "<leader>ab", "<cmd>LumaTool bash<cr>", desc = "Describe a task and generate a Bash script for review" },
		{
			"<leader>ab",
			":LumaTool bash<cr>",
			mode = "x",
			desc = "Generate a Bash script for a task based on the selected text",
		},
		{ "<leader>an", "<cmd>LumaNew<cr>", desc = "New Luma Chat" },
		{ "<leader>ah", "<cmd>LumaHistory<cr>", desc = "Luma History" },
		{ "<leader>am", "<cmd>LumaModel<cr>", desc = "Select Luma Model" },
		{ "<leader>ax", "<cmd>LumaCancel<cr>", desc = "Cancel Luma Request" },
	},
}
