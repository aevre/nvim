local ctx = require("toolchain.debug.context")

---@class DelveConfiguration: dap.Configuration
---@field port? integer|string
---@field cwd? string

---@return string
local function root()
	return ctx.root({ "go.mod", "go.work", ".git" })
end

---Keep Delve's generated binary outside the project working tree.
---@return string
local function output()
	return vim.fn.tempname()
end

---@return string|dap.Abort
local function test_name()
	local row = vim.api.nvim_win_get_cursor(0)[1] - 1
	local lines = vim.api.nvim_buf_get_lines(0, 0, row + 1, false)
	local candidate
	for index, line in ipairs(lines) do
		local name = line:match("^%s*func%s+(Test[%w_]+)%s*%(")
		if name and index <= row + 1 then
			candidate = name
		end
	end
	if not candidate then
		vim.notify("No Test function found above cursor", vim.log.levels.WARN)
		return require("dap").ABORT
	end
	return candidate
end

---@return string[]|dap.Abort
local function debug_test()
	local name = test_name()
	if type(name) == "string" then
		return { "-test.run", "^" .. name .. "$" }
	end
	return name
end

---@type DebugSpec
return {
	type = "go",
	---@param callback fun(adapter: dap.Adapter)
	---@param config DelveConfiguration
	adapter = function(callback, config)
		local command = ctx.command("dlv")
		assert(command, "Delve is unavailable; install Mason package delve or provide dlv on PATH")
		callback({
			type = "server",
			port = config.port or "${port}",
			options = { initialize_timeout_sec = 20 },
			executable = {
				command = command,
				args = { "dap", "--listen=127.0.0.1:${port}" },
				detached = vim.fn.has("win32") == 0,
				cwd = config.cwd or root(),
			},
		})
	end,
	configurations = {
		{
			name = "Debug package",
			type = "go",
			request = "launch",
			program = "${fileDirname}",
			cwd = root,
			args = ctx.arguments,
			buildFlags = function()
				return ctx.arguments("Build flags: ")
			end,
			output = output,
			outputMode = "remote",
		},
		{
			name = "Debug current file",
			type = "go",
			request = "launch",
			program = "${file}",
			cwd = root,
			args = ctx.arguments,
			buildFlags = function()
				return ctx.arguments("Build flags: ")
			end,
			output = output,
			outputMode = "remote",
		},
		{
			name = "Debug package tests",
			type = "go",
			request = "launch",
			mode = "test",
			outputMode = "remote",
			program = "${fileDirname}",
			cwd = root,
			args = function()
				return ctx.arguments("Test arguments: ", "-test.v")
			end,
			buildFlags = function()
				return ctx.arguments("Build flags: ")
			end,
			output = output,
		},
		{
			name = "Debug current test",
			type = "go",
			request = "launch",
			mode = "test",
			outputMode = "remote",
			program = "${fileDirname}",
			cwd = root,
			args = debug_test,
			buildFlags = function()
				return ctx.arguments("Build flags: ")
			end,
			output = output,
		},
		{
			name = "Attach Go process",
			type = "go",
			request = "attach",
			mode = "local",
			processId = function()
				return require("dap.utils").pick_process()
			end,
			cwd = root,
		},
	},
}
