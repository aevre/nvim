---@type LazyPluginSpec[]
return {
	{
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
	},
	{
		"saghen/blink.cmp",
		optional = true,
		opts = {
			sources = {
				default = { "minuet" },
				providers = {
					minuet = {
						name = "minuet",
						module = "minuet.blink",
						transform_items = function(ctx, items)
							local start_col =
								require("blink.cmp.fuzzy").get_keyword_range(ctx.line, ctx.cursor[2], "prefix")
							local prefix = ctx.line:sub(start_col + 1, ctx.cursor[2])
							for _, item in ipairs(items) do
								local col = item.insertText:sub(1, #prefix) == prefix and start_col or ctx.cursor[2]
								item.textEdit = {
									newText = item.insertText,
									range = {
										start = { line = ctx.cursor[1] - 1, character = col },
										["end"] = { line = ctx.cursor[1] - 1, character = ctx.cursor[2] },
									},
								}
							end
							return items
						end,
						async = true,
						timeout_ms = 3000,
						score_offset = 50,
					},
				},
			},
			keymap = {
				["<A-y>"] = {
					function(cmp)
						require("minuet").change_preset("openrouter")
						return cmp.show({ providers = { "minuet" } })
					end,
				},
				["<A-o>"] = {
					function(cmp)
						require("minuet").change_preset("ollama")
						return cmp.show({ providers = { "minuet" } })
					end,
				},
			},
		},
	},
}
