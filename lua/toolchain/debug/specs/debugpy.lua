local ctx = require("toolchain.debug.context")

---@class DebugpyConfiguration: dap.Configuration
---@field pythonPath? string
---@field python? string
---@field envFile? string
---@field env? table<string, string>
---@field connect? { host?: string, port?: number }|fun(): { host: string, port: number }|dap.Abort

---@return string
local function root()
	return ctx.root({ "pyproject.toml", "setup.py", "requirements.txt", "pytest.ini", "manage.py", ".git" })
end

---@param env string Virtual environment directory.
---@return string
local function python_executable(env)
	return vim.fs.joinpath(env, vim.fn.has("win32") == 1 and "Scripts/python.exe" or "bin/python")
end

---Prefer active/project environments before system Python.
---@return string|dap.Abort
local function python()
	for _, env in ipairs({ vim.env.VIRTUAL_ENV, vim.env.CONDA_PREFIX }) do
		if env then
			local path = python_executable(env)
			if vim.fn.executable(path) == 1 then
				return path
			end
		end
	end
	local project = root()
	for _, folder in ipairs({ ".venv", "venv", ".env", "env" }) do
		local path = python_executable(vim.fs.joinpath(project, folder))
		if vim.fn.executable(path) == 1 then
			return path
		end
	end
	return ctx.command("python3") or ctx.command("python") or require("dap").ABORT
end

---@return { host: string, port: number }|dap.Abort
local function connect()
	local host = vim.fn.input("Host [127.0.0.1]: ")
	local port = ctx.port("5678")
	if port == require("dap").ABORT then
		return port
	end
	return { host = host ~= "" and host or "127.0.0.1", port = port }
end

---@param path string
---@return table<string, string>
local function parse_env(path)
	local lines = vim.fn.readfile(path)
	local env = {}
	for _, line in ipairs(lines) do
		local key, value = line:match("^([^#][^=]*)=(.*)$")
		if key then
			env[vim.trim(key)] = value:gsub("^['\"](.*)['\"]$", "%1")
		end
	end
	return env
end

---@param config DebugpyConfiguration
---@param callback fun(config: DebugpyConfiguration)
local function enrich_config(config, callback)
	if not config.pythonPath and not config.python then
		local interpreter = python()
		assert(type(interpreter) == "string", "Python interpreter is unavailable")
		config.pythonPath = interpreter
	end
	local env_file = vim.fn.fnamemodify(config.envFile or root() .. "/.env", ":p")
	config.envFile = nil
	if vim.fn.filereadable(env_file) == 1 then
		config.env = vim.tbl_deep_extend("force", parse_env(env_file), config.env or {})
	end
	callback(config)
end

---@type DebugSpec
return {
	type = "python",
	---@param callback fun(adapter: dap.Adapter)
	---@param config DebugpyConfiguration
	adapter = function(callback, config)
		local adapter
		if config.request == "attach" then
			local address = config.connect or config
			assert(
				type(address.port) == "number" and address.port > 0 and address.port <= 65535,
				"debugpy attach requires a valid port"
			)
			adapter = { type = "server", host = address.host or "127.0.0.1", port = address.port }
		else
			local command = ctx.command("debugpy-adapter")
			if command then
				adapter = { type = "executable", command = command }
			else
				local interpreter = python()
				assert(type(interpreter) == "string", "Python/debugpy is unavailable; install Mason package debugpy")
				local result = vim.system({ interpreter, "-c", "import debugpy" }):wait(3000)
				assert(result.code == 0, "debugpy is unavailable; install Mason package debugpy or pip install debugpy")
				adapter = { type = "executable", command = interpreter, args = { "-m", "debugpy.adapter" } }
			end
		end
		adapter.enrich_config = enrich_config
		adapter.options = { source_filetype = "python" }
		callback(adapter)
	end,
	configurations = {
		{
			name = "Debug Python file",
			type = "python",
			request = "launch",
			program = "${file}",
			cwd = root,
			console = "integratedTerminal",
			justMyCode = true,
		},
		{
			name = "Debug Python file with arguments",
			type = "python",
			request = "launch",
			program = "${file}",
			args = ctx.arguments,
			cwd = root,
			console = "integratedTerminal",
			justMyCode = true,
		},
		{
			name = "Debug Python module",
			type = "python",
			request = "launch",
			module = function()
				return ctx.input("Python module: ")
			end,
			args = ctx.arguments,
			cwd = root,
			console = "integratedTerminal",
			justMyCode = true,
		},
		{
			name = "Debug Python doctest",
			type = "python",
			request = "launch",
			module = "doctest",
			args = { "${file}" },
			cwd = root,
			console = "integratedTerminal",
			noDebug = true,
		},
		{
			name = "Attach Python",
			type = "python",
			request = "attach",
			connect = connect,
			cwd = root,
		},
	},
}
