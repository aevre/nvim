---@class ToolchainDebugContext
local M = {}

---Resolve a project root from the target buffer, falling back to its directory or cwd.
---@param markers? string|string[] Root marker accepted by `vim.fs.root`.
---@param bufnr? integer Buffer whose path anchors the search; defaults to current buffer.
---@return string root
function M.root(markers, bufnr)
	local file = vim.api.nvim_buf_get_name(bufnr or 0)
	local start = file ~= "" and vim.fs.dirname(file) or vim.fn.getcwd()
	return vim.fs.root(start, markers or { ".git" }) or start
end

---Find a command on PATH or in Mason's executable directory.
---@param name string Executable name.
---@return string? path Absolute executable path when available.
function M.command(name)
	local path = vim.fn.exepath(name)
	if path ~= "" then
		return path
	end
	local mason = vim.fs.joinpath(vim.fn.stdpath("data"), "mason", "bin", name)
	return vim.fn.executable(mason) == 1 and mason or nil
end

---Prompt for a required string and convert cancellation or empty input to DAP abort.
---@param prompt string
---@param default? string
---@param completion? string Vim input completion kind.
---@return string|dap.Abort
function M.input(prompt, default, completion)
	local ok, value = pcall(vim.fn.input, { prompt = prompt, default = default or "", completion = completion })
	if not ok or value == "" then
		return require("dap").ABORT
	end
	return value
end

---Prompt for shell-like arguments; empty input intentionally means no arguments.
---@param prompt? string
---@param default? string
---@return string[]|dap.Abort
function M.arguments(prompt, default)
	local ok, value = pcall(vim.fn.input, { prompt = prompt or "Arguments: ", default = default or "" })
	if not ok then
		return require("dap").ABORT
	end
	return require("dap.utils").splitstr(value)
end

---Prompt for and validate an executable path.
---@param default? string
---@return string|dap.Abort
function M.program(default)
	local value = M.input("Executable: ", default or M.root() .. "/", "file")
	if type(value) ~= "string" then
		return value
	end
	value = vim.fn.fnamemodify(value, ":p")
	if vim.fn.executable(value) ~= 1 then
		vim.notify("Debug executable is not runnable: " .. value, vim.log.levels.ERROR)
		return require("dap").ABORT
	end
	return value
end

---Prompt for a valid TCP port.
---@param default? string
---@return integer|dap.Abort
function M.port(default)
	local value = M.input("Debug server port: ", default)
	local port = tonumber(value)
	if not port or port < 1 or port > 65535 or port % 1 ~= 0 then
		return require("dap").ABORT
	end
	return port
end

---@cast M ToolchainDebugContext
return M
