---@type LazyPluginSpec
return {
	"milanglacier/minuet-ai.nvim",
	event = "BufEdit",
	opts = {
		auto_trigger = {},
		provider = "openai_compatible",

		provider_options = {
			openai_compatible = {
				api_key = function()
					return os.getenv("OPENROUTER_TOKEN")
				end,
				end_point = "https://openrouter.ai/api/v1/chat/completions",
				model = "cohere/north-mini-code:free",
				name = "Openrouter",
				optional = {
					max_tokens = 56,
					top_p = 0.9,
					provider = {
						sort = "throughput",
					},
					reasoning_effort = "none",
				},
			},
		},

		blink = {
			enable_auto_complete = true,
		},
		context_window = 700,
		context_ratio = 0.75,
		debounce = 3000,
		-- notify = "debug",
		request_timeout = 3,
	},
}
