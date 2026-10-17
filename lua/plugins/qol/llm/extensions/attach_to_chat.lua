local tools = require("llm.tools")

return {
	handler = tools.attach_to_chat_handler,
	opts = {
		is_codeblock = true,
		inline_assistant = true,
		enable_buffer_context = true,
		language = "Chinese",
		diagnostic = { vim.diagnostic.severity.WARN, vim.diagnostic.severity.ERROR },
	},
}
