local function cache_dir()
	return vim.fs.joinpath(vim.fn.stdpath("cache"), "jdtls", "config")
end

---@param root_dir string
---@return string
local function workspace_dir(root_dir)
	local name = vim.fs.basename(root_dir)
	local hash = vim.fn.sha256(vim.fs.normalize(root_dir)):sub(1, 8)
	return vim.fs.joinpath(vim.fn.stdpath("cache"), "jdtls", "workspace", name .. "-" .. hash)
end

---@return string[]
local function jvm_args()
	local args = {}
	for arg in (vim.env.JDTLS_JVM_ARGS or ""):gmatch("%S+") do
		table.insert(args, "--jvm-arg=" .. arg)
	end
	return args
end

---@type vim.lsp.Config
return {
	cmd = function(dispatchers, config)
		local root_dir = assert(config.root_dir, "jdtls requires a project root")
		local config_dir = cache_dir()
		local data_dir = workspace_dir(root_dir)
		vim.fn.mkdir(config_dir, "p")
		vim.fn.mkdir(data_dir, "p")

		local cmd = { "jdtls", "-configuration", config_dir }
		vim.list_extend(cmd, jvm_args())
		vim.list_extend(cmd, { "-data", data_dir })
		return vim.lsp.rpc.start(cmd, dispatchers)
	end,
	filetypes = { "java" },
	workspace_required = true,
	root_markers = {
		{ "mvnw", "gradlew", "settings.gradle", "settings.gradle.kts", ".git" },
		{ "pom.xml", "build.gradle", "build.gradle.kts" },
	},
}
