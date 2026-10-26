local ctx = require("toolchain.debug.context")
local function root()
	return ctx.root({ "go.mod", "go.work", ".git" })
end

local function output()
	return vim.fn.tempname()
end

local function input_list(prompt, default)
	local value = vim.fn.input({ prompt = prompt, default = default or "" })
	return vim.split(value, "%s+", { trimempty = true })
end

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

local function debug_test()
	local name = test_name()
	if name == require("dap").ABORT then
		return name
	end
	return { "-test.run", "^" .. name .. "$" }
end

---@type DebugSpec
return {
	type = "go",
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
			request = "launch",
			program = "${fileDirname}",
			cwd = root,
			args = function()
				return input_list("Arguments: ")
			end,
			buildFlags = function()
				return input_list("Build flags: ")
			end,
			output = output,
			outputMode = "remote",
		},
		{
			name = "Debug current file",
			request = "launch",
			program = "${file}",
			cwd = root,
			args = function()
				return input_list("Arguments: ")
			end,
			buildFlags = function()
				return input_list("Build flags: ")
			end,
			output = output,
			outputMode = "remote",
		},
		{
			name = "Debug package tests",
			request = "launch",
			mode = "test",
			outputMode = "remote",
			program = "${fileDirname}",
			cwd = root,
			args = function()
				return input_list("Test arguments: ", "-test.v")
			end,
			buildFlags = function()
				return input_list("Build flags: ")
			end,
			output = output,
		},
		{
			name = "Debug current test",
			request = "launch",
			mode = "test",
			outputMode = "remote",
			program = "${fileDirname}",
			cwd = root,
			args = debug_test,
			buildFlags = function()
				return input_list("Build flags: ")
			end,
			output = output,
		},
		{
			name = "Attach Go process",
			request = "attach",
			mode = "local",
			processId = function()
				return require("dap.utils").pick_process()
			end,
			cwd = root,
		},
	},
}
