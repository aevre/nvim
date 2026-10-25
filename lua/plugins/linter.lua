-- Linter
---@type LazyPluginSpec
return {
	"mfussenegger/nvim-lint",
	event = "BufEdit",
	opts = {
		events = {
			"BufReadPost",
			"BufWritePost",
			"InsertLeave",
		},

		linters_by_ft = require("toolchain").get_linters(),

		---@type table<string, LintLinter>
		linters = require("toolchain").get_linter_configs(),
	},
	config = function(_, opts)
		local M = {}

		local lint = require("lint")

		local function merge_linter(origin, override)
			local merged = vim.tbl_deep_extend("force", origin, override)

			if type(override.prepend_args) == "table" then
				merged.args = merged.args or {}
				vim.list_extend(merged.args, override.prepend_args)
			end

			return merged
		end

		for name, linter in pairs(opts.linters) do
			local origin = lint.linters[name]

			if type(linter) == "table" and type(origin) == "table" then
				lint.linters[name] = merge_linter(origin, linter)
			else
				lint.linters[name] = linter
			end
		end

		lint.linters_by_ft = opts.linters_by_ft

		function M.debounce(ms, fn)
			local timer = vim.uv.new_timer()

			if not timer then
				return function(...)
					local argv = { ... }
					vim.schedule(function()
						fn(unpack(argv))
					end)
				end
			end

			return function(...)
				local argv = { ... }
				timer:stop()
				timer:start(ms, 0, function()
					vim.schedule_wrap(fn)(unpack(argv))
				end)
			end
		end

		function M.lint()
			local names = lint._resolve_linter_by_ft(vim.bo.filetype)

			names = vim.list_extend({}, names)

			if #names == 0 then
				vim.list_extend(names, lint.linters_by_ft["*"] or {})
			end

			local ctx = { filename = vim.api.nvim_buf_get_name(0) }
			ctx.dirname = vim.fn.fnamemodify(ctx.filename, ":h")
			names = vim.tbl_filter(function(name)
				local linter = lint.linters[name]
				if not linter then
					Utils.log.info("Linter not found: " .. name, { title = "linter" })
					return false
				end
				local cmd = type(linter.cmd) == "function" and linter.cmd() or linter.cmd
				return (not cmd or vim.fn.executable(cmd) == 1)
					and not (type(linter) == "table" and linter.condition and not linter.condition(ctx))
			end, names)

			if #names > 0 then
				lint.try_lint(names)
			end
		end

		local group = vim.api.nvim_create_augroup("nvim-lint", { clear = true })
		vim.api.nvim_create_autocmd(opts.events, {
			group = group,
			callback = M.debounce(100, M.lint),
		})
		vim.api.nvim_create_autocmd("User", {
			group = group,
			pattern = "ToolchainReady",
			callback = function()
				for _, bufnr in ipairs(vim.api.nvim_list_bufs()) do
					if vim.api.nvim_buf_is_loaded(bufnr) then
						vim.api.nvim_buf_call(bufnr, M.lint)
					end
				end
			end,
		})
	end,
}
