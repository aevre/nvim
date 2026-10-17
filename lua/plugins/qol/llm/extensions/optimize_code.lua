local tools = require("llm.tools")

return {
	handler = tools.side_by_side_handler,
	opts = {
		-- streaming_handler = local_llm_streaming_handler,
		left = {
			focusable = false,
		},
	},
}
