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

	local filetype = vim.bo[buf].filetype
	local parser = vim.treesitter.language.get_lang(filetype) or filetype
	local available, load_err = pcall(vim.treesitter.language.inspect, parser)
	if not available then
		return false, load_err
	end

	local ok, err = pcall(vim.treesitter.start, buf)
	if not ok then
		return false, err
	end

	vim.bo[buf].indentexpr = "v:lua.require'nvim-treesitter'.indentexpr()"
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
local function install_and_start(buf)
	local filetype = vim.bo[buf].filetype
	local root_parser = vim.treesitter.language.get_lang(filetype) or filetype
	local definition = toolchain.get_language_by_filetype(filetype)
	local parsers = definition and definition.treesitter or { root_parser }
	local key = table.concat(parsers, ",")

	if installing[key] then
		installing[key][#installing[key] + 1] = buf
		return
	end
	installing[key] = { buf }

	local ok, treesitter = pcall(require, "nvim-treesitter")
	if not ok then
		installing[key] = nil
		notify_failure(root_parser, treesitter)
		return
	end

	local task = treesitter.install(parsers, { summary = false })
	task:await(function(err, success)
		local buffers = installing[key] or {}
		installing[key] = nil
		vim.schedule(function()
			if err or not success then
				notify_failure(root_parser, err or "installation failed")
				return
			end

			for _, bufnr in ipairs(buffers) do
				local started, start_err = start_treesitter(bufnr)
				if not started then
					notify_failure(root_parser, start_err)
				end
			end
		end)
	end)
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
				install_and_start(event.buf)
			end,
		})
	end,
}
