---@return string workspace_root Cargo workspace root.
---@return string target_directory Cargo artifact directory.
local function cargo()
	local ctx = require("toolchain.debug.context")
	local root = ctx.root({ "Cargo.toml", ".git" })
	local command = ctx.command("cargo")
	if command then
		local result = vim.system(
			{ command, "metadata", "--no-deps", "--format-version", "1" },
			{ cwd = root, text = true }
		)
			:wait(3000)
		local ok, metadata = pcall(vim.json.decode, result.stdout or "")
		if result.code == 0 and ok then
			return metadata.workspace_root, metadata.target_directory
		end
	end
	return root, vim.env.CARGO_TARGET_DIR or root .. "/target"
end

---@type LanguageSpec
return {
	debug = {
		{
			adapter = "gdb",
			configurations = {
				{
					name = "Launch Cargo build artifact",
					type = "gdb",
					request = "launch",
					program = function()
						local ctx = require("toolchain.debug.context")
						local _, target = cargo()
						return ctx.program(target .. "/debug/")
					end,
					cwd = function()
						local root = cargo()
						return root
					end,
				},
			},
		},
	},
	filetypes = { "rust" },
	formatters = { "rustfmt" },
	lsp = { "rust_analyzer", "bacon-ls" },
	treesitter = { "rust" },
}
