vim.lsp.config("rust_analyzer", {
	settings = {
		["rust-analyzer"] = {
			diagnostics = {
				enable = false,
			},
		},
	},
})

local function reload_workspace(bufnr)
	local clients = vim.lsp.get_clients({ bufnr = bufnr, name = "rust_analyzer" })
	for _, client in ipairs(clients) do
		Utils.log.info("Reloading Cargo Workspace")
		---@diagnostic disable-next-line:param-type-mismatch
		client:request("rust-analyzer/reloadWorkspace", nil, function(err)
			if err then
				error(tostring(err))
			end
			Utils.log.info("Cargo workspace reloaded")
		end, 0)
	end
end

---@class RustAnalyzerCargoRunnableArgs
---@field cwd string
---@field workspaceRoot string
---@field cargoArgs string[]
---@field cargoExtraArgs? string[]
---@field executableArgs? string[]
---@field environment? table<string, string>
---@field overrideCargo? string

---@param args RustAnalyzerCargoRunnableArgs
---@param debugging? boolean
---@return string[]
local function cargo_command(args, debugging)
	assert(type(args.cargoArgs) == "table", "Only Cargo runnables are supported")
	local cargo_args = vim.deepcopy(args.cargoArgs)
	if debugging then
		if cargo_args[1] == "run" then
			cargo_args[1] = "build"
		elseif cargo_args[1] == "test" and not vim.list_contains(cargo_args, "--no-run") then
			table.insert(cargo_args, "--no-run")
		end
		if not vim.list_contains(cargo_args, "--message-format=json") then
			table.insert(cargo_args, "--message-format=json")
		end
	end
	vim.list_extend(cargo_args, args.cargoExtraArgs or {})
	return vim.list_extend({ args.overrideCargo or "cargo" }, cargo_args)
end

---@param stdout string
---@param is_test boolean
---@return string[]
local function cargo_executables(stdout, is_test)
	local executables = {}
	for line in stdout:gmatch("[^\r\n]+") do
		local ok, artifact = pcall(vim.json.decode, line)
		if
			ok
			and type(artifact) == "table"
			and artifact.reason == "compiler-artifact"
			and type(artifact.executable) == "string"
		then
			local target = artifact.target or {}
			local profile = artifact.profile or {}
			local is_build_script = vim.list_contains(target.kind or {}, "custom-build")
			local is_test_target = profile.test == true or vim.list_contains(target.kind or {}, "test")
			if not is_build_script and is_test == is_test_target then
				table.insert(executables, artifact.executable)
			end
		end
	end
	return executables
end

---@param args RustAnalyzerCargoRunnableArgs
local function debug_runnable(args)
	local command = cargo_command(args, true)
	local cwd = args.cwd or args.workspaceRoot
	Utils.log.info("Compiling Cargo target for debugging")
	vim.system(command, { cwd = cwd, env = args.environment, text = true }, function(result)
		if result.code ~= 0 then
			vim.schedule(function()
				Utils.log.error(result.stderr or "Cargo build failed")
			end)
			return
		end

		local executables = cargo_executables(result.stdout or "", args.cargoArgs[1] == "test")
		vim.schedule(function()
			if #executables == 0 then
				Utils.log.error("Cargo produced no debuggable executable")
				return
			end

			---@param program? string
			local function launch(program)
				if not program then
					return
				end
				require("dap").run({
					name = "Debug Cargo target",
					type = "gdb",
					request = "launch",
					program = program,
					cwd = cwd,
					args = args.executableArgs or {},
					env = args.environment,
				})
			end

			if #executables == 1 then
				launch(executables[1])
			else
				vim.ui.select(executables, { prompt = "Select Cargo executable" }, launch)
			end
		end)
	end)
end

local function is_library(fname)
	local user_home = vim.fs.normalize(vim.env.HOME)
	local cargo_home = os.getenv("CARGO_HOME") or user_home .. "/.cargo"
	local registry = cargo_home .. "/registry/src"
	local git_registry = cargo_home .. "/git/checkouts"

	local rustup_home = os.getenv("RUSTUP_HOME") or user_home .. "/.rustup"
	local toolchains = rustup_home .. "/toolchains"

	for _, item in ipairs({ toolchains, registry, git_registry }) do
		if vim.fs.relpath(item, fname) then
			local clients = vim.lsp.get_clients({ name = "rust_analyzer" })
			return #clients > 0 and clients[#clients].config.root_dir or nil
		end
	end
end

---@type vim.lsp.Config
return {
	cmd = { "rust-analyzer" },
	filetypes = { "rust" },
	root_dir = function(bufnr, on_dir)
		local fname = vim.api.nvim_buf_get_name(bufnr)
		local reused_dir = is_library(fname)
		if reused_dir then
			on_dir(reused_dir)
			return
		end

		local cargo_crate_dir = vim.fs.root(fname, { "Cargo.toml" })
		local cargo_workspace_root

		if cargo_crate_dir == nil then
			on_dir(
				vim.fs.root(fname, { "rust-project.json" })
					or vim.fs.dirname(vim.fs.find(".git", { path = fname, upward = true })[1])
			)
			return
		end

		local cmd = {
			"cargo",
			"metadata",
			"--no-deps",
			"--format-version",
			"1",
			"--manifest-path",
			cargo_crate_dir .. "/Cargo.toml",
		}

		vim.system(cmd, { text = true }, function(output)
			if output.code == 0 then
				if output.stdout then
					local result = vim.json.decode(output.stdout)
					if result["workspace_root"] then
						cargo_workspace_root = vim.fs.normalize(result["workspace_root"])
					end
				end

				on_dir(cargo_workspace_root or cargo_crate_dir)
			else
				vim.schedule(function()
					Utils.log.error(
						("[rust_analyzer] cmd failed with code %d: %s\n%s"):format(output.code, cmd, output.stderr)
					)
				end)
			end
		end)
	end,
	capabilities = {
		experimental = {
			serverStatusNotification = true,
			commands = {
				commands = {
					"rust-analyzer.showReferences",
					"rust-analyzer.runSingle",
					"rust-analyzer.debugSingle",
				},
			},
		},
	},
	before_init = function(init_params, config)
		-- See https://github.com/rust-lang/rust-analyzer/blob/eb5da56d839ae0a9e9f50774fa3eb78eb0964550/docs/dev/lsp-extensions.md?plain=1#L26
		if config.settings and config.settings["rust-analyzer"] then
			init_params.initializationOptions = config.settings["rust-analyzer"]
		end
		---@param command table{ title: string, command: string, arguments: table[] }
		vim.lsp.commands["rust-analyzer.runSingle"] = function(command)
			---@type RustAnalyzerCargoRunnableArgs
			local args = command.arguments[1].args
			local cmd = cargo_command(args)
			if args.executableArgs and #args.executableArgs > 0 then
				vim.list_extend(cmd, { "--" })
				vim.list_extend(cmd, args.executableArgs)
			end

			vim.system(cmd, { cwd = args.cwd, env = args.environment, text = true }, function(result)
				vim.schedule(function()
					if result.code == 0 then
						Utils.log.info(result.stdout or "Cargo command completed")
					else
						Utils.log.error(result.stderr or "Cargo command failed")
					end
				end)
			end)
		end

		---@param command table{ title: string, command: string, arguments: table[] }
		vim.lsp.commands["rust-analyzer.debugSingle"] = function(command)
			debug_runnable(command.arguments[1].args)
		end
	end,
	on_attach = function(_, bufnr)
		vim.api.nvim_buf_create_user_command(bufnr, "LspCargoReload", function()
			reload_workspace(bufnr)
		end, { desc = "Reload current cargo workspace" })
	end,
}
