local prompts = require("plugins.qol.llm.prompts")
local tools = require("llm.tools")

return {
	handler = tools.flexi_handler,
	prompt = prompts.CodeExplain,
	opts = {
		-- fetch_key = vim.env.GLM_KEY,
		-- url = "https://open.bigmodel.cn/api/paas/v4/chat/completions",
		-- model = "glm-4-flash",
		-- api_type = "zhipu",
		-- url = "http://localhost:11434/api/chat",
		-- -- model = "qwen3:1.7b",
		-- model = "qwen:0.5b",
		-- fetch_key = vim.env.LOCAL_LLM_KEY,
		-- api_type = "ollama",
		enter_flexible_window = true,
		enable_buffer_context = true,
	},
}
