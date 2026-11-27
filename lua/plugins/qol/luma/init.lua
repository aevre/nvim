---@type LazyPluginSpec
return {
	"aevre/luma.nvim",
	dir = vim.env.NVIM_PLUGIN_MODE == "dev" and vim.fn.expand("~/Projects/lib/luma.nvim") or nil,
	name = "luma.nvim",
	event = "BufReadPost",
	dependencies = {
		"win.nvim",
		"animate.nvim",
	},
	---@type luma.ConfigInput
	opts = {
		model = "openrouter",
		prompt = "You are a helpful Chinese coding assistant.",
		debug = false,
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
				model = "nvidia/nemotron-3.5-lightning:free",
				url = "https://openrouter.ai/api/v1/chat/completions",
				api_key = "OPENROUTER_TOKEN",
			},
			["qwen2.5-coder:1.5b"] = {
				backend = "ollama",
				model = "qwen2.5-coder:1.5b",
				url = "http://127.0.0.1:11434/api/chat",
			},
			["qwen3.5:4b"] = {
				backend = "ollama",
				model = "qwen3.5:4b",
				think = false,
				url = "http://127.0.0.1:11434/api/chat",
				timeout = 600000,
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
		{ "<leader>ac", "<cmd>LumaToggle<cr>", desc = "Toggle chat" },
		{
			"<leader>aa",
			"<Esc><cmd>'<,'>LumaTool attach<cr>",
			mode = "x",
			desc = "Attach selection",
		},
		{ "<leader>ak", "<cmd>LumaTool ask<cr>", desc = "Ask model" },
		{ "<leader>ae", "<cmd>LumaTool explain<cr>", desc = "Explain buffer" },
		{
			"<leader>ae",
			"<Esc><cmd>'<,'>LumaTool explain<cr>",
			mode = "x",
			desc = "Explain selection",
		},
		{ "<leader>ad", "<cmd>LumaTool document_buffer<cr>", desc = "Document buffer in English" },
		{
			"<leader>ad",
			"<Esc><cmd>'<,'>LumaTool document_selection<cr>",
			mode = "x",
			desc = "Document selection in English",
		},
		{
			"<leader>aw",
			"<cmd>LumaTool word_translate<cr>",
			desc = "Translate word",
		},
		{
			"<leader>aw",
			"<Esc><cmd>'<,'>LumaTool word_translate<cr>",
			mode = "x",
			desc = "Translate selection",
		},
		{
			"<leader>at",
			"<cmd>LumaTool translate<cr>",
			desc = "Open translator",
		},
		{
			"<leader>aT",
			"<Esc><cmd>'<,'>LumaTool tests<cr>",
			mode = "x",
			desc = "Generate tests",
		},
		{
			"<leader>ao",
			"<Esc><cmd>'<,'>LumaTool rewrite<cr>",
			mode = "x",
			desc = "Rewrite selection",
		},
		{
			"<leader>ag",
			"<cmd>LumaTool commit<cr>",
			desc = "Commit message",
		},
		{ "<leader>ab", "<cmd>LumaTool bash<cr>", desc = "Generate Bash" },
		{
			"<leader>ab",
			"<Esc><cmd>'<,'>LumaTool bash<cr>",
			mode = "x",
			desc = "Bash from selection",
		},
		{ "<leader>an", "<cmd>LumaNew<cr>", desc = "New chat" },
		{ "<leader>ah", "<cmd>LumaHistory<cr>", desc = "Chat history" },
		{ "<leader>am", "<cmd>LumaModel<cr>", desc = "Select model" },
		{ "<leader>ax", "<cmd>LumaCancel<cr>", desc = "Cancel request" },
	},
}
