-- plugins/qol/oil.lua
---@type LazyPluginSpec
return {
	"stevearc/oil.nvim",
	cmd = "Oil",
	lazy = false,
	keys = {
		{ "-", "<cmd>Oil<cr>", desc = "Open parent directory" },
	},
	opts = function()
		return {
			default_file_explorer = true,
			columns = { "icon" },
			buf_options = { buflisted = false, bufhidden = "hide" },
			delete_to_trash = false,
			skip_confirm_for_simple_edits = true,
			lsp_file_methods = { enabled = true, timeout_ms = 1000, autosave_changes = false },
			constrain_cursor = "editable",
			use_default_keymaps = false,
			keymaps = {
				["g?"] = { "actions.show_help", mode = "n" },
				["<CR>"] = "actions.select",
				["\\"] = { "actions.select", opts = { horizontal = true } },
				["|"] = { "actions.select", opts = { vertical = true } },
				["<C-t>"] = { "actions.select", opts = { tab = true } },
				["<C-r>"] = "actions.refresh",
				["<C-p>"] = "actions.preview",
				["<C-c>"] = { "actions.close", mode = "n" },
				["zh"] = { "actions.toggle_hidden", mode = "n" },
				["-"] = { "actions.close", mode = "n" },
				["`"] = { "actions.cd", mode = "n" },
				["~"] = { "actions.cd", opts = { scope = "tab" }, mode = "n" },
				["gs"] = { "actions.change_sort", mode = "n" },
				["gx"] = "actions.open_external",
				["<BS>"] = "actions.parent",
				["gd"] = {
					desc = "Toggle file detail view",
					callback = function()
						_G.Oil.toggle_detail()
					end,
				},
				["gh"] = {
					desc = "Toggle hidden / ignored files",
					callback = function()
						_G.Oil.toggle_hide_ignored()
					end,
				},
			},
		}
	end,
	config = function(_, opts)
		local Oil = _G.Oil or {}

		local detail = false
		Oil.hide_ignored = true

		local function parse_output(proc)
			local result = proc:wait()
			local ret = {}
			if result.code == 0 then
				for line in vim.gsplit(result.stdout, "\n", { plain = true, trimempty = true }) do
					ret[line:gsub("/$", "")] = true
				end
			end
			return ret
		end

		local function new_git_status()
			return setmetatable({}, {
				__index = function(self, dir)
					local ignore_proc = vim.system(
						{ "git", "ls-files", "--ignored", "--exclude-standard", "--others", "--directory" },
						{ cwd = dir, text = true }
					)
					local tracked_proc = vim.system({ "git", "ls-tree", "HEAD", "--name-only" }, {
						cwd = dir,
						text = true,
					})
					local ret = {
						ignored = parse_output(ignore_proc),
						tracked = parse_output(tracked_proc),
					}
					rawset(self, dir, ret)
					return ret
				end,
			})
		end
		function Oil.toggle_detail()
			detail = not detail

			require("oil").set_columns(detail and { "icon", "permissions", "size", "mtime" } or { "icon" })
		end

		local git_status = new_git_status()

		function Oil.get_winbar()
			local winid = vim.g.statusline_winid
			if not winid or winid == 0 then
				winid = vim.api.nvim_get_current_win()
			end
			local bufnr = vim.api.nvim_win_get_buf(winid)
			local dir = require("oil").get_current_dir(bufnr)
			if dir then
				return vim.fn.fnamemodify(dir, ":~")
			end
			return vim.api.nvim_buf_get_name(bufnr)
		end

		function Oil.toggle_hide_ignored()
			Oil.hide_ignored = not Oil.hide_ignored

			require("oil.actions").refresh.callback()

			vim.notify(Oil.hide_ignored and "Oil: hide dotfiles/gitignored" or "Oil: show all files")
		end

		_G.Oil = Oil

		local refresh = require("oil.actions").refresh
		local orig_refresh = refresh.callback
		refresh.callback = function(...)
			git_status = new_git_status()
			orig_refresh(...)
		end

		opts = vim.tbl_deep_extend("force", opts, {
			win_options = {
				winbar = "%!v:lua.Oil.get_winbar()",
			},
			view_options = {
				is_hidden_file = function(name, bufnr)
					if not _G.Oil.hide_ignored then
						return false
					end
					local dir = require("oil").get_current_dir(bufnr)
					if not dir then
						return vim.startswith(name, ".") and name ~= ".."
					end
					local is_dotfile = vim.startswith(name, ".") and name ~= ".."
					if is_dotfile then
						return not git_status[dir].tracked[name]
					else
						return git_status[dir].ignored[name]
					end
				end,
			},
		})

		vim.api.nvim_create_autocmd("User", {
			pattern = "OilEnter",
			callback = function()
				for index = vim.fn.argc() - 1, 0, -1 do
					local arg = vim.fn.argv(index)
					if vim.fn.isdirectory(arg) == 1 or vim.startswith(arg, "oil://") then
						vim.cmd((index + 1) .. "argdelete")
					end
				end
			end,
		})

		require("oil").setup(opts)
	end,
}
