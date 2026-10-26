local ctx = require("toolchain.debug.context")
local function root()
	return ctx.root({ "go.mod", "go.work", ".git" })
end

---@type DebugSpec
return {
	adapter = function(callback, config)
		local command = ctx.command("dlv")
		assert(command, "Delve is unavailable; install Mason package delve or provide dlv on PATH")
		callback({
			type = "server",
			port = "${port}",
			executable = {
				command = command,
				args = { "dap", "--listen=127.0.0.1:${port}" },
				cwd = config.cwd or root(),
			},
		})
	end,
	configurations = {
		{
			name = "Debug package",
			type = "delve",
			request = "launch",
			program = "${fileDirname}",
			cwd = root,
			outputMode = "remote",
		},
		{
			name = "Debug current file",
			type = "delve",
			request = "launch",
			program = "${file}",
			cwd = root,
			outputMode = "remote",
		},
		{
			name = "Debug package tests",
			type = "delve",
			request = "launch",
			mode = "test",
			outputMode = "remote",
			program = "${fileDirname}",
			cwd = root,
		},
		{
			name = "Attach Go process",
			type = "delve",
			request = "attach",
			mode = "local",
			processId = function()
				return require("dap.utils").pick_process()
			end,
			cwd = root,
		},
	},
}
