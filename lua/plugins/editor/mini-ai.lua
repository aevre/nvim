-- Extend and create a/i textobjects

local function ai_buffer(ai_type)
	local start_line, end_line = 1, vim.fn.line("$")
	if ai_type == "i" then
		-- Skip first and last blank lines for `i` textobject
		local first_nonblank, last_nonblank = vim.fn.nextnonblank(start_line), vim.fn.prevnonblank(end_line)
		-- Do nothing for buffer with all blanks
		if first_nonblank == 0 or last_nonblank == 0 then
			return { from = { line = start_line, col = 1 } }
		end
		start_line, end_line = first_nonblank, last_nonblank
	end

	local line_text = vim.fn.getline(end_line)
	if type(line_text) == "table" then
		line_text = line_text[1] or ""
	end

	local to_col = math.max(string.len(line_text or ""), 1)
	return { from = { line = start_line, col = 1 }, to = { line = end_line, col = to_col } }
end

---@type LazyPluginSpec
return {
	"nvim-mini/mini.ai",
	event = "BufEdit",
	opts = function()
		local ai = require("mini.ai")
		return {
			custom_textobjects = {
				o = ai.gen_spec.treesitter({
					a = { "@block.outer", "@conditional.outer", "@loop.outer" },
					i = { "@block.inner", "@conditional.inner", "@loop.inner" },
				}),
				f = ai.gen_spec.treesitter({
					a = "@function.outer",
					i = "@function.inner",
				}),
				c = ai.gen_spec.treesitter({
					a = "@class.outer",
					i = "@class.inner",
				}),
				a = ai.gen_spec.treesitter({
					a = "@parameter.outer",
					i = "@parameter.inner",
				}),
				d = { "%f[%d]%d+" }, -- digits
				e = { -- Word with case
					{ "%u[%l%d]+%f[^%l%d]", "%f[%S][%l%d]+%f[^%l%d]", "%f[%P][%l%d]+%f[^%l%d]", "^[%l%d]+%f[^%l%d]" },
					"^().*()$",
				},
				g = ai_buffer, -- buffer
				u = ai.gen_spec.function_call(), -- u for "Usage"
				U = ai.gen_spec.function_call({ name_pattern = "[%w_]" }),
			},
			mappings = {
				-- Main textobject prefixes
				around = "a",
				inside = "i",

				-- Next/last variants
				around_next = "an",
				inside_next = "in",
				around_last = "al",
				inside_last = "il",

				-- Move cursor to corresponding edge of `a` textobject
				goto_left = "g[",
				goto_right = "g]",
			},
			n_lines = 50,
			search_method = "cover_or_next",
			silent = false,
		}
	end,
}
