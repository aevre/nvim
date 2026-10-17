---@type LazyPluginSpec
return {
	"aevre/auto-save.nvim",
	event = "BufEdit",
	opts = {
		debounced_dekay = 1000,
		print_enabled = false,
		trigger_events = { "InsertLeave", "TextChanged" },
		condition = function(buf)
			local fn = vim.fn

			if fn.getbufvar(buf, "&filetype") == "oil" then
				return false
			end

			if fn.getbufvar(buf, "&modifiable") == 1 then
				return fn.mode() == "n"
			end

			return false
		end,
	},
}
