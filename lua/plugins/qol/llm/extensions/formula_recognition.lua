local tools = require("llm.tools")

return {
	handler = tools.images_handler,
	prompt = "Please convert the formula in the image to LaTeX syntax, and only return the syntax of the formula.",
	opts = {
		url = "http://localhost:11434/api/chat",
		model = "qwen2.5vl:3b",
		fetch_key = vim.env.LOCAL_LLM_KEY,
		api_type = "ollama",
		picker = {
			cmd = "fd . ~/Pictures/ | xargs -d '\n' ls -t | fzf --no-preview",
			enable_fzf_focus_print = false,
			select = {
				border = {
					style = "rounded",
					text = {
						top = " Files ",
						top_align = "center",
					},
				},
			},
			-- extern = function(callback)
			--   require("fzf-lua").files({
			--     cmd = "fd . ~/Pictures/ -e jpg -e jpeg -e png -e webp | xargs -d '\n' ls -t",
			--     winopts = {
			--       height = 0.7,
			--       width = 0.8,
			--     },
			--     actions = {
			--       default = function(selected)
			--         local path = string.gsub(selected[1], "^[^%w%p]+%s*", "") --  remove the icon if the file_icon is enable
			--         path = string.gsub(path, " ", "\\ ")
			--         callback(path)
			--       end,
			--     },
			--   })
			-- end,
			-- keymap
			mapping = {
				mode = "i",
				keys = "<C-f>",
			},
		},
	},
}
