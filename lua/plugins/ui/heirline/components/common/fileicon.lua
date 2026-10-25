return {
	init = function(self)
		local path = self.filepath or vim.api.nvim_buf_get_name(self.bufnr or 0)
		local filename = self.filename or vim.fn.fnamemodify(path, ":t")
		local icon, icon_hl, _ = require("mini.icons").get("file", filename)
		local buftype = vim.api.nvim_get_option_value("buftype", { buf = self.bufnr or 0 })
		if buftype == "terminal" then
			icon = ""
			icon_hl = "DevIconTerminal"
		end
		self.icon = icon
		self.icon_hl = icon_hl
	end,
	provider = function(self)
		return self.icon and (self.icon .. " ")
	end,
	hl = function(self)
		return self.icon_hl
	end,
}
