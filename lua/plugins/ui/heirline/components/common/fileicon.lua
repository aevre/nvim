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
		if icon_hl then
			local hl_val = vim.api.nvim_get_hl(0, { name = icon_hl, link = false })
			self.icon_color = hl_val.fg and string.format("#%06x", hl_val.fg) or nil
		else
			self.icon_color = nil
		end
	end,
	provider = function(self)
		return self.icon and (self.icon .. " ")
	end,
	hl = function(self)
		return { fg = self.icon_color }
	end,
}
