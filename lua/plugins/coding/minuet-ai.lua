---@type LazyPluginSpec
return {
	"milanglacier/minuet-ai.nvim",
	event = "BufEdit",
	opts = {
		auto_trigger = {},
		provider = "openai_fim_compatible",
		n_completions = 1,

		provider_options = {
			openai_compatible = {
				api_key = function()
					return os.getenv("OPENROUTER_TOKEN")
				end,
				end_point = "https://openrouter.ai/api/v1/chat/completions",
				model = "nvidia/nemotron-3.5-lightning:free",
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
			openai_fim_compatible = {
				api_key = "TERM",
				end_point = "http://127.0.0.1:11434/v1/completions",
				model = "qwen2.5-coder:1.5b",
				name = "Ollama",
				optional = {
					max_tokens = 56,
					top_p = 0.9,
				},
			},
		},
		presets = {
			openrouter = {
				provider = "openai_compatible",
				context_window = 700,
				throttle = 2000,
				debounce = 800,
				request_timeout = 3,
			},
			ollama = {
				provider = "openai_fim_compatible",
				context_window = 512,
				throttle = 500,
				debounce = 200,
				request_timeout = 5,
				provider_options = {
					openai_fim_compatible = {
						api_key = "TERM",
						end_point = "http://127.0.0.1:11434/v1/completions",
						model = "qwen2.5-coder:1.5b",
						name = "Ollama",
						optional = {
							max_tokens = 56,
							top_p = 0.9,
						},
					},
				},
			},
		},
		blink = {
			enable_auto_complete = true,
		},
		context_window = 512,
		context_ratio = 0.75,
		throttle = 500,
		debounce = 200,
		request_timeout = 5,
	},
}
