local tools = require("llm.tools")

return {
	handler = tools.qa_handler,
	prompt = [[Write a suitable bash script and run it through CodeRunner]],
	opts = {
		url = "https://api.siliconflow.cn/v1/chat/completions",
		api_type = "openai",
		max_tokens = 4096,
		-- model = "Qwen/Qwen2.5-7B-Instruct",
		model = "Qwen/Qwen3-8B",
		fetch_key = vim.env.SILICONFLOW_TOKEN,
		enable_thinking = false,

		-- url = "http://localhost:11434/api/chat",
		-- model = "qwen3:1.7b",
		-- api_type = "ollama",
		-- fetch_key = vim.env.LOCAL_LLM_KEY,
		-- enable_thinking = false,
		component_width = "60%",
		component_height = "50%",
		query = {
			title = "  CodeRunner ",
			hl = { link = "Define" },
		},
		input_box_opts = {
			size = "15%",
			win_options = {
				winhighlight = "Normal:Normal,FloatBorder:FloatBorder",
			},
		},
		preview_box_opts = {
			size = "85%",
			win_options = {
				winhighlight = "Normal:Normal,FloatBorder:FloatBorder",
			},
		},
		functions_tbl = {
			CodeRunner = function(code)
				local filepath = "/tmp/script.sh"

				Utils.log.info(string.format("CodeRunner running...\n```bash\n%s\n```", code))
				local file = io.open(filepath, "w")
				if file then
					file:write(code)
					file:close()
					local script_result = vim.system({ "bash", filepath }, { text = true }):wait()
					os.remove(filepath)
					return script_result.stdout
				else
					return ""
				end
			end,
		},
		schema = {
			{
				type = "function",
				["function"] = {
					name = "CodeRunner",
					description = "Bash code interpreter",
					parameters = {
						properties = {
							code = {
								type = "string",
								description = "bash code",
							},
						},
						required = { "code" },
						type = "object",
					},
				},
			},
		},
	},
}
