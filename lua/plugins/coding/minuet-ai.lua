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
					model = "codegemma:2b-code",
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
							model = "codegemma:2b-code",
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
							local start_col, keyword_end =
								require("blink.cmp.fuzzy").get_keyword_range(ctx.line, ctx.cursor[2], "full")
							local prefix = ctx.line:sub(start_col + 1, ctx.cursor[2])
							local suffix = ctx.line:sub(ctx.cursor[2] + 1)
							for _, item in ipairs(items) do
								local matches_prefix = item.insertText:sub(1, #prefix) == prefix
								local col = matches_prefix and start_col or ctx.cursor[2]
								local first_line = item.insertText:match("^[^\n]*")
								local overlap = math.min(#first_line, #suffix)
								while overlap > 0 and first_line:sub(-overlap) ~= suffix:sub(1, overlap) do
									overlap = overlap - 1
								end
								if matches_prefix then
									local rest_of_word = ctx.line:sub(ctx.cursor[2] + 1, keyword_end)
									if first_line:sub(#prefix + 1, #prefix + #rest_of_word) == rest_of_word then
										overlap = math.max(overlap, #rest_of_word)
									end
									local continuation = first_line:sub(#prefix + 1)
									for length = math.min(#continuation, #suffix), overlap + 1, -1 do
										if continuation:sub(1, length) == suffix:sub(1, length) then
											overlap = length
											break
										end
									end
								end
								local finish_col = ctx.cursor[2] + overlap
								item.textEdit = {
									newText = item.insertText,
									range = {
										start = { line = ctx.cursor[1] - 1, character = col },
										["end"] = { line = ctx.cursor[1] - 1, character = finish_col },
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
