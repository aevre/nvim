local ctx = require("toolchain.debug.context")
local M = {}

---@param filtered boolean Prompt for a Jest test-name regular expression.
---@return dap.Configuration
function M.configuration(filtered)
	return setmetatable({
		name = filtered and "Debug Jest test name" or "Debug Jest file",
		type = "pwa-node",
		request = "launch",
	}, {
		__call = function(base)
			local config = vim.deepcopy(base)
			setmetatable(config, nil)
			local file = vim.api.nvim_buf_get_name(0)
			local root = ctx.root({ "package.json", ".git" })
			local dir = vim.fs.dirname(file)
			local jest
			while dir do
				local entry = dir .. "/node_modules/jest/bin/jest.js"
				if vim.fn.filereadable(entry) == 1 then
					jest = entry
					break
				end
				local parent = vim.fs.dirname(dir)
				dir = parent ~= dir and parent or nil
			end
			if not jest or file == "" then
				vim.notify("Jest requires a saved test file and project-local jest", vim.log.levels.ERROR)
				config.program = require("dap").ABORT
				return config
			end
			local args = { "--runInBand", "--no-coverage", "--runTestsByPath", file }
			if filtered then
				local pattern = ctx.input("Jest test name (regex): ")
				if type(pattern) ~= "string" then
					config.program = pattern
					return config
				end
				vim.list_extend(args, { "--testNamePattern", pattern })
			end
			return vim.tbl_extend("force", config, {
				program = jest,
				cwd = root,
				args = args,
				runtimeExecutable = ctx.command("node") or require("dap").ABORT,
				console = "integratedTerminal",
				sourceMaps = true,
				skipFiles = { "<node_internals>/**" },
			})
		end,
	})
end

return M
