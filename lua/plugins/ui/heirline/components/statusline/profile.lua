local command

vim.ui_attach(vim.api.nvim_create_namespace("heirline-profile"), { ext_messages = true }, function(event, content)
	if event ~= "msg_showcmd" then
		return
	end

	local chunks = {}
	for _, chunk in ipairs(content or {}) do
		chunks[#chunks + 1] = chunk[2] or ""
	end
	local value = vim.trim(table.concat(chunks))
	if value == "" then
		return
	end

	command = value:gsub("%%", "%%%%")
	vim.schedule(function()
		vim.cmd("redrawstatus")
	end)
end)

return {
	condition = function()
		return command ~= nil
	end,
	{
		provider = function()
			return command
		end,
		hl = function(self)
			return { fg = self.palette.primary_bright or self.palette.pink }
		end,
	},
	{ provider = " " },
}
