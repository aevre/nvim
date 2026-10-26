---@class LanguageSpec
---@field filetypes string[] Filetypes.
---@field formatters? string[] Formatter names.
---@field linters? string[] Linter names.
---@field lint_filetypes? string[] Filetypes where lint runs.
---@field lsp? string[] LSP configuration names.
---@field treesitter? string[] Treesitter parser names.
---@field debug? (string|LanguageDebug)[] Debug adapter declarations.

---@class LanguageSourceItem
---@field name string Language spec filename.
---@field file string Language spec path.
---@field filetypes string Filetypes for display.
---@field formatters string Formatters for display.
---@field linters string Linters for display.
---@field lsp string LSPs for display.

local M = {}
local specs_dir = vim.fs.joinpath(vim.fn.stdpath("config"), "lua", "toolchain", "lang", "specs")

local languages = require("toolchain.specs").load("lang", function(spec)
	for _, field in ipairs({ "filetypes", "formatters", "linters", "lint_filetypes", "lsp", "treesitter" }) do
		if spec[field] ~= nil then
			if not vim.islist(spec[field]) or (field == "filetypes" and #spec[field] == 0) then
				return false
			end
			for _, value in ipairs(spec[field]) do
				if type(value) ~= "string" or value == "" then
					return false
				end
			end
		end
	end
	return spec.filetypes ~= nil and (spec.debug == nil or vim.islist(spec.debug))
end) ---@type table<string, LanguageSpec>
local lsp_enabled = {} ---@type table<string, boolean>

local function add_unique(list, value)
	if not vim.tbl_contains(list, value) then
		list[#list + 1] = value
	end
end

local function extend_unique(list, values)
	for _, value in ipairs(values) do
		add_unique(list, value)
	end
end

---@param definition LanguageSpec
---@param callback fun(filetype: string)
local function each_filetype(definition, callback)
	for _, filetype in ipairs(definition.filetypes) do
		callback(filetype)
	end
end

---@param field string
---@param filetypes_field? string
---@return table<string, string[]>
local function collect_by_filetype(field, filetypes_field)
	local result = {}

	for _, definition in pairs(languages) do
		local values = definition[field]
		if not values then
			goto continue
		end

		local filetypes = definition[filetypes_field] or definition.filetypes

		for _, filetype in ipairs(filetypes) do
			result[filetype] = result[filetype] or {}
			extend_unique(result[filetype], values)
		end

		::continue::
	end

	return result
end

---@return table<string, LanguageSpec>
function M.get()
	return vim.deepcopy(languages)
end

---@return table<string, string[]>
function M.get_formatters()
	local result = collect_by_filetype("formatters")

	vim.tbl_extend("force", result, {
		graphql = { "prettier", "biome", "oxfmt" },
		handlebars = { "prettier", "biome", "oxfmt" },
		luau = { "stylua" },
	})

	return result
end

---@return table<string, string[]>
function M.get_linters()
	return collect_by_filetype("linters", "lint_filetypes")
end

---@return { parsers: string[], filetypes: string[] }
function M.get_treesitter()
	local result = {
		parsers = {},
		filetypes = {},
	}
	for _, definition in pairs(languages) do
		if not definition.treesitter then
			goto continue
		end
		extend_unique(result.parsers, definition.treesitter)
		each_filetype(definition, function(filetype)
			add_unique(result.filetypes, filetype)
		end)
		::continue::
	end
	return result
end

---Enable declared LSPs only when opening a matching filetype.
---@param filetype string
function M.enable_lsp(filetype)
	local definition = M.get_by_filetype(filetype)
	if not definition or not definition.lsp then
		return
	end
	for _, name in ipairs(definition.lsp) do
		if not lsp_enabled[name] and require("toolchain.mason").is_installed(name) then
			vim.lsp.enable(name)
			lsp_enabled[name] = true
		end
	end
end

function M.enable_for_open_buffers()
	for _, bufnr in ipairs(vim.api.nvim_list_bufs()) do
		if vim.api.nvim_buf_is_loaded(bufnr) then
			M.enable_lsp(vim.bo[bufnr].filetype)
		end
	end
end

---Register lazy LSP activation by filetype.
function M.setup()
	local group = vim.api.nvim_create_augroup("LanguageLsp", { clear = true })
	vim.api.nvim_create_autocmd("FileType", {
		group = group,
		callback = function(event)
			M.enable_lsp(vim.bo[event.buf].filetype)
		end,
	})
	M.enable_lsp(vim.bo.filetype)
end

---@param filetype string
---@return LanguageSpec?
function M.get_by_filetype(filetype)
	local result
	for _, definition in pairs(languages) do
		if not vim.tbl_contains(definition.filetypes, filetype) then
			goto continue
		end
		result = result or {
			filetypes = {},
		}
		extend_unique(result.filetypes, definition.filetypes)

		for _, field in ipairs({
			"formatters",
			"linters",
			"lsp",
			"treesitter",
			"debug",
		}) do
			if definition[field] then
				result[field] = result[field] or {}
				extend_unique(result[field], definition[field])
			end
		end
		::continue::
	end
	return result
end

---@return LanguageSourceItem[]
function M.source_items()
	local items = {}
	for name, definition in pairs(languages) do
		items[#items + 1] = {
			name = name,
			file = vim.fs.joinpath(specs_dir, name .. ".lua"),
			filetypes = table.concat(definition.filetypes, ", "),
			formatters = table.concat(definition.formatters or {}, ", "),
			linters = table.concat(definition.linters or {}, ", "),
			lsp = table.concat(definition.lsp or {}, ", "),
		}
	end
	table.sort(items, function(a, b)
		return a.name < b.name
	end)
	return items
end

return M
