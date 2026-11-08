local M = {}

local function trim_git(value)
	return value:gsub("%.git$", ""):gsub("/+$", "")
end

local function url_key(value)
	local host, path = value:match("^git@([^:]+):(.+)$")
	if not host then
		host, path = value:match("^[%w+.-]+://([^/]+)/(.+)$")
	end
	if not host then
		return nil
	end
	return "url:" .. host:lower() .. "/" .. trim_git(path:lower())
end

local function repo_key(value)
	if value:match("^[^/]+/[^/]+/?$") then
		return "repo:" .. trim_git(value:lower())
	end

	local url = url_key(value)
	return url and "repo:" .. url:match("^[^:]+:[^/]+/(.+)$") or nil
end

local function ref_keys(value)
	if type(value) ~= "string" or value == "" then
		return {}
	end

	local lower = value:lower()
	local keys = {
		"id:" .. lower,
		"name:" .. lower,
		"module:" .. lower,
	}
	local url = url_key(value)
	local repo = repo_key(value)
	if url then
		keys[#keys + 1] = url
	end
	if repo then
		keys[#keys + 1] = repo
	end
	return keys
end

local function add_alias(aliases, value, kind)
	if type(value) ~= "string" or value == "" then
		return
	end
	aliases[kind .. ":" .. value:lower()] = true
	local url = url_key(value)
	local repo = repo_key(value)
	if url then
		aliases[url] = true
	end
	if repo then
		aliases[repo] = true
	end
end

local function plugin_aliases(plugin)
	local aliases = {}
	add_alias(aliases, plugin.name, "name")
	add_alias(aliases, plugin.url, "url")
	return aliases
end

local function spec_aliases(spec)
	local aliases = {}
	add_alias(aliases, spec.id, "id")
	for _, name in ipairs(spec.names or {}) do
		add_alias(aliases, name, "name")
	end
	for _, repo in ipairs(spec.repos or {}) do
		add_alias(aliases, repo, "repo")
	end
	for _, url in ipairs(spec.urls or {}) do
		add_alias(aliases, url, "url")
	end
	return aliases
end

local function intersects(left, right)
	for key in pairs(left) do
		if right[key] then
			return true
		end
	end
	return false
end

local function lazy_plugin(spec)
	local config = package.loaded["lazy.core.config"]
	if type(config) ~= "table" or type(config.plugins) ~= "table" then
		return nil, false
	end

	local expected = spec_aliases(spec)
	for key, plugin in pairs(config.plugins) do
		local aliases = plugin_aliases(plugin)
		add_alias(aliases, key, "name")
		if intersects(expected, aliases) then
			return plugin, true
		end
	end
	return nil, true
end

local function module_find(name)
	if type(vim.loader) == "table" and type(vim.loader.find) == "function" then
		local ok, found = pcall(vim.loader.find, name)
		if ok and found and found[1] then
			return true
		end
	end

	local path = "lua/" .. name:gsub("%.", "/")
	return #vim.api.nvim_get_runtime_file(path .. ".lua", false) > 0
		or #vim.api.nvim_get_runtime_file(path .. "/init.lua", false) > 0
end

local function module_status(modules)
	local loaded = false
	local available = false
	local installed = false

	for _, name in ipairs(modules or {}) do
		if package.loaded[name] then
			loaded = true
			available = true
		end
		if package.preload[name] ~= nil then
			available = true
		end
		if module_find(name) then
			installed = true
			available = true
		end
	end

	return installed, loaded, available
end

---@class theme.PluginStatus
---@field declared boolean
---@field installed boolean
---@field loaded boolean
---@field imported boolean
---@field available boolean

---@param spec table
---@return theme.PluginStatus
function M.status(spec)
	local plugin, managed = lazy_plugin(spec)
	local module_installed, module_loaded, module_available = module_status(spec.modules)
	local state = plugin and plugin._ or nil
	local enabled = plugin and state and state.kind ~= "disabled" and state.cond ~= false
	local installed = module_installed
	local loaded = module_loaded
	local available = module_available
	if managed then
		installed = enabled and state.installed == true or false
		loaded = enabled and state.loaded ~= nil or false
		available = enabled and installed or loaded
	end

	return {
		declared = plugin ~= nil,
		installed = installed,
		loaded = loaded,
		imported = (not managed or loaded) and module_loaded,
		available = available,
	}
end

---@param spec table
---@param state? "declared"|"installed"|"loaded"|"imported"|"available"
---@return boolean
function M.has(spec, state)
	state = state or "available"
	local status = M.status(spec)
	return status[state] == true
end

---@param value string
---@return string[]
function M.keys(value)
	return ref_keys(value)
end

return M
