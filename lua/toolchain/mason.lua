local M = {}

-- Runtime tool names and Mason package names are separate namespaces.
local packages = {
	-- LSP
	["bash-language-server"] = "bash-language-server",
	["bacon-ls"] = "bacon-ls",
	["clangd"] = "clangd",
	["css-lsp"] = "css-lsp",
	["css-variables-language-server"] = "css-variables-language-server",
	["cssmodules-language-server"] = "cssmodules-language-server",
	["emmet-language-server"] = "emmet-language-server",
	["emmylua"] = "emmylua_ls",
	["gopls"] = "gopls",
	["html"] = "html-lsp",
	["jdtls"] = "jdtls",
	["jsonls"] = "json-lsp",
	["kotlin-lsp"] = "kotlin-language-server",
	["lua_ls"] = "lua-language-server",
	["pyright"] = "pyright",
	["rnix"] = "rnix-lsp",
	["ruff"] = "ruff",
	["rust_analyzer"] = "rust-analyzer",
	["stylelint-language-server"] = "stylelint-language-server",
	["tailwindcss"] = "tailwindcss-language-server",
	["tombi"] = "tombi",
	["vtsls"] = "vtsls",
	["vue_ls"] = "vue-language-server",
	["luau-lsp"] = "luau-lsp",
	["nushell"] = "nushell",
	["qmlls"] = "qmlls",

	-- Debug adapter IDs are independent of executables and DAP types.
	["delve"] = "delve",
	["debugpy"] = "debugpy",
	["js-debug"] = "js-debug-adapter",

	-- Formatter and lint
	["biome"] = "biome",
	["clang_format"] = "clang-format",
	["gofumpt"] = "gofumpt",
	["goimports"] = "goimports",
	["isort"] = "isort",
	["nixfmt"] = "nixfmt",
	["oxfmt"] = "oxfmt",
	["oxlint"] = "oxlint",
	["prettier"] = "prettier",
	["ruff_format"] = "ruff",
	["selene"] = "selene",
	["shellcheck"] = "shellcheck",
	["shfmt"] = "shfmt",
	["sqruff"] = "sqruff",
	["stylua"] = "stylua",
	["taplo"] = "taplo",
	["xmlformatter"] = "xmlformatter",
	["yapf"] = "yapf",
	["golangcilint"] = "golangci-lint",
}

-- Auxiliary packages are always included, even without a language match.
M.extra_packages = {}

local function add(result, seen, name)
	local package = packages[name]
	if package and not seen[package] then
		seen[package] = true
		result[#result + 1] = package
	end
end

---@param name string
---@return boolean
function M.is_installed(name)
	local package = packages[name]
	if not package then
		return true
	end
	local ok, registry = pcall(require, "mason-registry")
	return ok and registry.has_package(package) and registry.get_package(package):is_installed()
end

---@param filetype string
---@return string[]
function M.get_packages(filetype)
	local result = {}
	local seen = {}
	for _, package in ipairs(M.extra_packages) do
		if not seen[package] then
			seen[package] = true
			result[#result + 1] = package
		end
	end
	local definition = require("toolchain").lang.get_by_filetype(filetype) or {}

	for _, field in ipairs({ "lsp", "formatters", "linters", "debug" }) do
		for _, name in ipairs(definition[field] or {}) do
			add(result, seen, type(name) == "table" and name.adapter or name)
		end
	end

	table.sort(result)
	return result
end

return M
