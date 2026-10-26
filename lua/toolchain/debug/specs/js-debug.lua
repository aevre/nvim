local ctx = require("toolchain.debug.context")

---@return string
local function root()
	return ctx.root({ "package.json", ".git" })
end

---@type DebugSpec
return {
	type = "pwa-node",
	---@param callback fun(adapter: dap.Adapter)
	adapter = function(callback)
		local command = ctx.command("js-debug-adapter")
		local args = { "${port}", "127.0.0.1" }
		if not command then
			local path =
				vim.fs.find("node_modules", { path = root(), upward = true, type = "directory", limit = math.huge })
			for _, dir in ipairs(path) do
				local entry = dir .. "/@vscode/js-debug/src/dapDebugServer.js"
				if vim.fn.filereadable(entry) == 1 then
					command = ctx.command("node")
					table.insert(args, 1, entry)
					break
				end
			end
		end
		assert(command, "JS debug adapter is unavailable; install Mason package js-debug-adapter")
		callback({
			type = "server",
			host = "127.0.0.1",
			port = "${port}",
			executable = { command = command, args = args },
		})
	end,
	configurations = {
		require("toolchain.debug.jest").configuration(false),
		require("toolchain.debug.jest").configuration(true),
		{
			name = "Launch Node file",
			type = "pwa-node",
			request = "launch",
			program = function()
				if vim.bo.filetype == "typescript" or vim.bo.filetype == "typescriptreact" then
					return ctx.input("Compiled JavaScript entry: ", root() .. "/dist/", "file")
				end
				return vim.api.nvim_buf_get_name(0)
			end,
			cwd = root,
			args = ctx.arguments,
			runtimeExecutable = function()
				return ctx.command("node") or require("dap").ABORT
			end,
			sourceMaps = true,
			outFiles = function()
				return { root() .. "/**/*.js", "!**/node_modules/**" }
			end,
			skipFiles = { "<node_internals>/**" },
		},
		{
			name = "Attach Node server",
			type = "pwa-node",
			request = "attach",
			address = "127.0.0.1",
			port = function()
				return ctx.port("9229")
			end,
			cwd = root,
			sourceMaps = true,
			skipFiles = { "<node_internals>/**" },
		},
	},
}
