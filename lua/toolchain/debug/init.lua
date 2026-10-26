---@class LanguageDebug
---@field adapter string Adapter spec ID, independent of the DAP type.
---@field defaults? boolean Include shared defaults (true unless explicitly false).
---@field configurations? dap.Configuration[] Configurations appended after defaults.

---@class DebugSpec
---@field type? string DAP type; defaults to the spec filename.
---@field adapter dap.Adapter|dap.AdapterFactory
---@field configurations dap.Configuration[]

---@class ToolchainDebugSetupOptions
---@field override? boolean Replace entries currently registered with nvim-dap.
---@field launch_json? boolean Install the `.vscode/launch.json` provider (enabled by default).

---@alias ToolchainDebugAdapters table<string, dap.Adapter|dap.AdapterFactory>
---@alias ToolchainDebugConfigurations table<string, dap.Configuration[]>

---@class ToolchainDebug
local M = {}
---@type table<string, DebugSpec>
local specs = require("toolchain.specs").load("debug", function(spec)
	local adapter_valid = type(spec.adapter) == "function"
		or (type(spec.adapter) == "table" and vim.tbl_contains({ "executable", "server", "pipe" }, spec.adapter.type))
	return adapter_valid and vim.islist(spec.configurations) and (spec.type == nil or type(spec.type) == "string")
end)
---@type fun(bufnr: integer): dap.Configuration[]|nil
local owned_provider
---@type fun(bufnr: integer): dap.Configuration[]|nil
local previous_provider
---@type table<string, dap.Adapter|dap.AdapterFactory>
local owned_adapters = {}
---@type table<dap.Configuration, boolean>
local owned_configs = setmetatable({}, { __mode = "k" })

---@param value string|LanguageDebug
---@return LanguageDebug
local function declaration(value)
	if type(value) == "string" then
		return { adapter = value }
	end
	assert(type(value) == "table" and type(value.adapter) == "string", "Invalid language debug declaration")
	assert(value.defaults == nil or type(value.defaults) == "boolean", "debug.defaults must be boolean")
	assert(value.configurations == nil or vim.islist(value.configurations), "debug.configurations must be a list")
	return value
end

---@param languages table<string, LanguageSpec>
---@return ToolchainDebugAdapters adapters Adapters keyed by DAP type.
---@return ToolchainDebugConfigurations configurations Configurations keyed by filetype.
function M.resolve(languages)
	local adapters, configurations = {}, {}
	local names = vim.tbl_keys(languages)
	table.sort(names)
	for _, name in ipairs(names) do
		local language = languages[name]
		for _, value in ipairs(language.debug or {}) do
			local item = declaration(value)
			local spec = assert(specs[item.adapter], "Unknown debug adapter: " .. item.adapter)
			local adapter_type = spec.type or item.adapter
			assert(
				not adapters[adapter_type] or adapters[adapter_type] == spec.adapter,
				"Conflicting DAP type: " .. adapter_type
			)
			adapters[adapter_type] = spec.adapter
			local configs = vim.deepcopy(item.defaults == false and {} or spec.configurations)
			vim.list_extend(configs, vim.deepcopy(item.configurations or {}))
			for _, config in ipairs(configs) do
				assert(
					type(config.name) == "string" and type(config.request) == "string",
					"Invalid debug configuration for " .. name
				)
				config.type = config.type or adapter_type
			end
			for _, ft in ipairs(language.filetypes) do
				configurations[ft] = configurations[ft] or {}
				for _, config in ipairs(configs) do
					local duplicate = vim.iter(configurations[ft]):any(function(existing)
						return vim.deep_equal(existing, config)
					end)
					if not duplicate then
						table.insert(configurations[ft], vim.deepcopy(config))
					end
				end
			end
		end
	end
	return adapters, configurations
end

-- Preserve manual entries; only replace configurations still owned by this module.
---@param opts? ToolchainDebugSetupOptions
function M.setup(opts)
	opts = opts or {}
	local dap = require("dap")
	local adapters, configurations = M.resolve(require("toolchain.lang").get())
	for name, adapter in pairs(adapters) do
		if opts.override or dap.adapters[name] == nil or dap.adapters[name] == owned_adapters[name] then
			dap.adapters[name] = adapter
			owned_adapters[name] = adapter
		end
	end
	for ft, configs in pairs(configurations) do
		local current = dap.configurations[ft] or {}
		local result = {}
		if not opts.override then
			for _, config in ipairs(current) do
				if not owned_configs[config] then
					table.insert(result, config)
				end
			end
		end
		for _, config in ipairs(configs) do
			local exists = vim.iter(result):any(function(existing)
				return vim.deep_equal(existing, config)
			end)
			if not exists then
				table.insert(result, config)
				owned_configs[config] = true
			end
		end
		dap.configurations[ft] = result
	end
	local provider = dap.providers.configs["dap.launch.json"]
	if opts.launch_json == false then
		if provider == owned_provider then
			dap.providers.configs["dap.launch.json"] = previous_provider
		end
		return
	end
	local source = type(provider) == "function" and debug.getinfo(provider, "S").source or ""
	if provider == owned_provider or provider == nil or source:match("/dap%.lua$") or opts.override then
		if provider ~= owned_provider then
			previous_provider = provider
		end
		-- Read on demand so project changes do not accumulate launch configurations.
		owned_provider = function(bufnr)
			local ctx = require("toolchain.debug.context")
			local root = ctx.root({ ".vscode" }, bufnr)
			local path = root .. "/.vscode/launch.json"
			if vim.fn.filereadable(path) ~= 1 then
				return {}
			end
			local ok, configs = pcall(require("dap.ext.vscode").getconfigs, path)
			if not ok then
				vim.notify("Invalid " .. path .. ": " .. tostring(configs), vim.log.levels.ERROR)
				return {}
			end
			local aliases = { node = "pwa-node", debugpy = "python", delve = "go" }
			for _, config in ipairs(configs) do
				config.type = aliases[config.type] or config.type
				local function expand(value)
					if type(value) == "string" then
						return (
							value
								:gsub("%${workspaceFolder}", function()
									return root
								end)
								:gsub("%${workspaceFolderBasename}", function()
									return vim.fs.basename(root)
								end)
						)
					elseif type(value) == "table" then
						for key, child in pairs(value) do
							value[key] = expand(child)
						end
					end
					return value
				end
				expand(config)
			end
			return configs
		end
		dap.providers.configs["dap.launch.json"] = owned_provider
	end
end

---@cast M ToolchainDebug
return M
