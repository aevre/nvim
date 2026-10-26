local M = {}

function M.root(markers, bufnr)
	local file = vim.api.nvim_buf_get_name(bufnr or 0)
	local start = file ~= "" and vim.fs.dirname(file) or vim.fn.getcwd()
	return vim.fs.root(start, markers or { ".git" }) or start
end

function M.command(name)
	local path = vim.fn.exepath(name)
	if path ~= "" then
		return path
	end
	local mason = vim.fs.joinpath(vim.fn.stdpath("data"), "mason", "bin", name)
	return vim.fn.executable(mason) == 1 and mason or nil
end

function M.input(prompt, default, completion)
	local ok, value = pcall(vim.fn.input, { prompt = prompt, default = default or "", completion = completion })
	if not ok or value == "" then
		return require("dap").ABORT
	end
	return value
end

function M.program(default)
	local value = M.input("Executable: ", default or M.root() .. "/", "file")
	if value == require("dap").ABORT then
		return value
	end
	value = vim.fn.fnamemodify(value, ":p")
	if vim.fn.executable(value) ~= 1 then
		vim.notify("Debug executable is not runnable: " .. value, vim.log.levels.ERROR)
		return require("dap").ABORT
	end
	return value
end

function M.port(default)
	local value = M.input("Debug server port: ", default)
	local port = tonumber(value)
	if not port or port < 1 or port > 65535 or port % 1 ~= 0 then
		return require("dap").ABORT
	end
	return port
end

return M
