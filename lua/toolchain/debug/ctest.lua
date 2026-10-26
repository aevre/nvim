local ctx = require("toolchain.debug.context")

---@return dap.Configuration
local function configuration()
	return setmetatable({ name = "Debug CTest test", type = "gdb", request = "launch" }, {
		__call = function(base)
			local config = vim.deepcopy(base)
			setmetatable(config, nil)
			config.program = require("dap").ABORT
			local command = ctx.command("ctest")
			if not command then
				vim.notify("CTest is unavailable", vim.log.levels.ERROR)
				return config
			end
			local root = ctx.root({ "CMakeLists.txt", ".git" })
			local build = ctx.input("CTest build directory: ", root .. "/build/", "dir")
			if type(build) ~= "string" then
				return config
			end
			build = vim.fn.fnamemodify(build, ":p")
			local extra = ctx.arguments("CTest options (e.g. -C Debug): ")
			if type(extra) ~= "table" or extra == require("dap").ABORT then
				return config
			end
			local cmd = vim.list_extend({ command, "--test-dir", build, "--show-only=json-v1" }, extra)
			local co = coroutine.running()
			local ok, err = pcall(vim.system, cmd, { text = true }, function(result)
				vim.schedule(function()
					coroutine.resume(co, result)
				end)
			end)
			if not ok then
				vim.notify(tostring(err), vim.log.levels.ERROR)
				return config
			end
			local result = coroutine.yield()
			local decoded, data = pcall(vim.json.decode, result.stdout or "")
			if result.code ~= 0 or not decoded or type(data) ~= "table" or type(data.tests) ~= "table" then
				vim.notify("CTest discovery failed: " .. (result.stderr or "invalid JSON"), vim.log.levels.ERROR)
				return config
			end
			local tests = vim.tbl_filter(function(test)
				return type(test.command) == "table" and type(test.command[1]) == "string"
			end, data.tests)
			if #tests == 0 then
				vim.notify("No built CTest commands found", vim.log.levels.WARN)
				return config
			end
			local test = require("dap.ui").pick_one(tests, "CTest test: ", function(item)
				return item.name
			end)
			if not test then
				return config
			end
			config.program = test.command[1]
			config.args = vim.list_slice(test.command, 2)
			config.cwd = build
			for _, property in ipairs(test.properties or {}) do
				if property.name == "WORKING_DIRECTORY" then
					config.cwd = property.value
				end
			end
			return config
		end,
	})
end

return { configuration = configuration }
