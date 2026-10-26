local ctx = require("toolchain.debug.context")
local function root()
	return ctx.root({ "pyproject.toml", "setup.py", "requirements.txt", ".git" })
end

local function python()
	local project = root()
	for _, env in ipairs({ project .. "/.venv", project .. "/venv", vim.env.VIRTUAL_ENV or "" }) do
		local path = env .. "/bin/python"
		if env ~= "" and vim.fn.executable(path) == 1 then
			return path
		end
	end
	return ctx.command("python3") or ctx.command("python") or require("dap").ABORT
end

---@type DebugSpec
return {
	adapter = function(callback, config)
		if config.request == "attach" then
			local connect = config.connect or config
			assert(
				type(connect.port) == "number" and connect.port > 0 and connect.port <= 65535,
				"debugpy attach requires a valid port"
			)
			callback({ type = "server", host = connect.host or "127.0.0.1", port = connect.port })
			return
		end
		local command = ctx.command("debugpy-adapter")
		if command then
			callback({ type = "executable", command = command })
			return
		end
		local interpreter = python()
		assert(interpreter ~= require("dap").ABORT, "Python/debugpy is unavailable; install Mason package debugpy")
		local result = vim.system({ interpreter, "-c", "import debugpy" }):wait(3000)
		assert(result.code == 0, "debugpy is unavailable; install Mason package debugpy or pip install debugpy")
		callback({ type = "executable", command = interpreter, args = { "-m", "debugpy.adapter" } })
	end,
	configurations = {
		{
			name = "Debug Python file",
			type = "debugpy",
			request = "launch",
			program = "${file}",
			pythonPath = python,
			cwd = root,
		},
		{
			name = "Debug Python module",
			type = "debugpy",
			request = "launch",
			module = function()
				return ctx.input("Python module: ")
			end,
			pythonPath = python,
			cwd = root,
		},
		{
			name = "Attach Python (127.0.0.1:5678)",
			type = "debugpy",
			request = "attach",
			connect = { host = "127.0.0.1", port = 5678 },
			cwd = root,
		},
	},
}
