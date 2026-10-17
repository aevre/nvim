local tools = require("llm.tools")

return {
	handler = tools.action_handler,
	opts = {
		language = "Chinese",
	},
}
