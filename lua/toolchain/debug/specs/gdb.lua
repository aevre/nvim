local ctx = require("toolchain.debug.context")

---@return string
local function root()
	return ctx.root({ "Cargo.toml", "CMakeLists.txt", "Makefile", ".git" })
end

---@type DebugSpec
return {
	---@param callback fun(adapter: dap.Adapter)
	adapter = function(callback)
		local command = ctx.command("gdb")
		assert(command, "GDB is unavailable; install GDB 14.1+ with Python/DAP support")
		local result = vim.system({ command, "--version" }, { text = true }):wait(3000)
		local major, minor = (result.stdout or ""):match("(%d+)%.(%d+)")
		major, minor = tonumber(major), tonumber(minor)
		assert(
			result.code == 0 and major and (major > 14 or (major == 14 and minor >= 1)),
			"GDB 14.1+ with Python/DAP support is required"
		)
		callback({ type = "executable", command = command, args = { "--quiet", "--interpreter=dap" } })
	end,
	configurations = {
		{
			name = "Launch executable",
			type = "gdb",
			request = "launch",
			program = function()
				return ctx.program(root() .. "/")
			end,
			cwd = root,
			stopAtBeginningOfMainSubprogram = false,
		},
		{
			name = "Attach process",
			type = "gdb",
			request = "attach",
			pid = function()
				return require("dap.utils").pick_process()
			end,
			cwd = root,
		},
	},
}
