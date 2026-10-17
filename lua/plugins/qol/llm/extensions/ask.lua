local tools = require("llm.tools")

return {
	handler = tools.disposable_ask_handler,
	opts = {
		position = {
			row = 2,
			col = 0,
		},
		size = {
			height = 1,
			width = "50%",
		},
		title = " Ask ",
		inline_assistant = true,
		enable_buffer_context = true,
		language = "Chinese",
		diagnostic = { vim.diagnostic.severity.WARN, vim.diagnostic.severity.ERROR },
		-- url = "https://api.chatanywhere.tech/v1/chat/completions",
		-- model = "gpt-4o-mini",
		-- api_type = "openai",
		-- fetch_key = vim.env.CHAT_ANYWHERE_KEY,
		display = {
			mapping = {
				mode = "n",
				keys = { "d" },
			},
			action = nil,
		},
		accept = {
			mapping = {
				mode = "n",
				keys = { "Y", "y" },
			},
			action = nil,
		},
		reject = {
			mapping = {
				mode = "n",
				keys = { "N", "n" },
			},
			action = nil,
		},
		close = {
			mapping = {
				mode = "n",
				keys = { "<esc>" },
			},
			action = nil,
		},
	},
}
