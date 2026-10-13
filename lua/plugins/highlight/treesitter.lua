local toolchain = require("toolchain")

local language_treesitter = toolchain.get_treesitter()
local filetypes = language_treesitter.filetypes

local installing = {}
local reported = {}

for _, filetype in ipairs(language_treesitter.filetypes) do
	if not vim.tbl_contains(filetypes, filetype) then
		filetypes[#filetypes + 1] = filetype
	end
end

---@param buf integer
---@return boolean, any?
local function start_treesitter(buf)
	if not vim.api.nvim_buf_is_valid(buf) or vim.bo[buf].filetype == "" then
		return true
	end

	local ok, err = pcall(vim.treesitter.start, buf)
	if not ok then
		return false, err
	end

	vim.bo[buf].indentexpr = "v:lua.require'nvim-treesitter'.indentexpr()"
	for _, win in ipairs(vim.fn.win_findbuf(buf)) do
		if vim.api.nvim_win_is_valid(win) then
			vim.api.nvim_set_option_value("foldexpr", "v:lua.vim.treesitter.foldexpr()", { win = win })
			vim.api.nvim_set_option_value("foldmethod", "expr", {
				win = win,
			})
		end
	end
	return true
end

---@param parser string
---@param err any
local function notify_failure(parser, err)
	if reported[parser] then
		return
	end
	reported[parser] = true
	vim.notify(
		("Treesitter parser '%s' could not be started: %s"):format(parser, tostring(err)),
		vim.log.levels.WARN,
		{ title = "Treesitter" }
	)
end

---@param buf integer
---@return string
local function request_install(buf)
	local filetype = vim.bo[buf].filetype
	local root_parser = vim.treesitter.language.get_lang(filetype) or filetype

	local definition = toolchain.get_language_by_filetype(filetype)
	local parsers = definition and definition.treesitter

	if not parsers or #parsers == 0 then
		parsers = { root_parser }
	end

	local pending = {}

	for _, parser in ipairs(parsers) do
		if not installing[parser] then
			installing[parser] = true
			pending[#pending + 1] = parser
		end
	end

	if #pending == 0 then
		return root_parser
	end

	local ok, treesitter = pcall(require, "nvim-treesitter")
	if not ok then
		for _, parser in ipairs(pending) do
			installing[parser] = nil
		end
		return root_parser
	end

	local installed, err = pcall(treesitter.install, pending, { summary = false })
	if not installed then
		for _, parser in ipairs(pending) do
			installing[parser] = nil
			notify_failure(root_parser, err)
		end
	end
	return root_parser
end

---@param buf integer
---@param attempts integer
local function start_when_ready(buf, attempts)
	local ok, err = start_treesitter(buf)
	if ok then
		return
	end

	local parser = request_install(buf)
	if attempts >= 300 then
		notify_failure(parser, err)
		return
	end
	vim.defer_fn(function()
		start_when_ready(buf, attempts + 1)
	end, 100)
end

---@type LazyPluginSpec
return {
	"nvim-treesitter/nvim-treesitter",
	branch = "main",
	build = ":TSUpdate",
	event = { "BufReadPre", "BufNewFile", "VeryLazy" },
	opts = {},
	init = function()
		local group = vim.api.nvim_create_augroup("ToolchainTreesitter", {
			clear = true,
		})

		vim.api.nvim_create_autocmd("FileType", {
			group = group,
			pattern = filetypes,
			callback = function(event)
				start_when_ready(event.buf, 0)
			end,
		})
	end,
}
