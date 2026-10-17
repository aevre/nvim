local prompts = require("plugins.qol.llm.prompts")
local tools = require("llm.tools")

return {
	handler = tools.side_by_side_handler,
	prompt = prompts.TestCode,
	opts = {
		right = {
			border = {
				style = "rounded",
				text = { top = " Test Cases ", top_align = "center" },
			},
		},
	},
}
