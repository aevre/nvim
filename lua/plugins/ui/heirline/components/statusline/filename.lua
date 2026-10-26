local common = require("plugins.ui.heirline.components.common")

return {
	init = function(self)
		local path = vim.api.nvim_buf_get_name(0)
		self.filepath = path
		local filename = vim.fn.fnamemodify(path, ":t")
		self.filename = filename == "" and "[No Name]" or filename
		self.icon_filename = self.filename
	end,
	{ provider = " " },
	common.FileIcon,
	{
		provider = function(self)
			return self.filename
		end,
		hl = function(self)
			return { italic = true, fg = self.palette.fg }
		end,
	},
}
