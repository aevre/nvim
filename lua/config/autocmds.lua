vim.api.nvim_create_autocmd({ "FileType" }, {
	pattern = { "json", "jsonc" }, -- 匹配 JSON 和 JSONC 文件类型
	group = vim.api.nvim_create_augroup("show_text", { clear = true }),
	callback = function()
		vim.wo.conceallevel = 0 -- 禁用文本隐藏（显示所有字符）
	end,
})

vim.api.nvim_create_autocmd("FileType", {
	callback = function()
		vim.opt_local.formatoptions:remove({ "c", "r", "o" })
	end,
})

-- 处理所有特殊缓冲区类型
vim.api.nvim_create_autocmd("FileType", {
	pattern = {
		"", -- [No Name] 空缓冲区
		"acwrite", -- 总是可写缓冲区
		"checkhealth", -- 健康检查
		"copilot", -- Copilot
		"dap-repl", -- DAP REPL
		"dap-view", -- DAP views
		"dap-view-help", -- DAP view help
		"dap-view-hover", -- DAP hover
		"dap-view-term", -- DAP terminal
		"dbout",
		"diff", -- 差异比较
		"dirvish", -- 目录浏览
		"DiffviewDiffPanel", -- Diffview 差异面板
		"DiffviewFileHistory", -- Diffview 文件历史
		"DiffviewFiles", -- Diffview 文件
		"fzf",
		"fugitive", -- Git 相关
		"fugitiveblame", -- Git blame
		"git", -- Git 相关
		"gitcommit", -- Git 提交信息
		"gitconfig", -- Git 配置
		"gitgraph",
		"gitrebase", -- Git rebase
		"gitsigns-blame",
		"grug-far",
		"help", -- 帮助文档
		"lspinfo", -- LSP 信息
		"mason", -- Mason 包管理
		"man", -- 手册页
		"neotest-output",
		"neotest-output-panel",
		"neotest-summary",
		"netrw", -- 文件浏览器
		"nofile", -- 无文件缓冲区
		"nowrite", -- 只读缓冲区
		"notify", -- 通知窗口
		"nvim-pack",
		"oil", -- Oil 文件浏览器
		"PlenaryTestPopup", -- Plenary 测试弹窗
		"popup", -- 弹出窗口
		"prompt", -- 提示窗口
		"qf", -- quick fix 窗口
		"quickfix", -- 快速修复列表
		"spectre_panel",
		"startuptime", -- 启动时间分析
		"terminal", -- 终端
		"toggleterm", -- ToggleTerm
		"tsplayground", -- Treesitter 游乐场
	},
	group = vim.api.nvim_create_augroup("quit_window", { clear = true }),
	callback = function(event)
		-- 设置不列入缓冲区列表
		vim.bo[event.buf].buflisted = false

		-- 添加关闭快捷键
		vim.keymap.set("n", "q", ":close<CR>", {
			buffer = event.buf,
			silent = true,
			desc = "关闭特殊窗口",
		})
	end,
})

vim.api.nvim_create_autocmd("FileType", {
	pattern = "fzf",
	callback = function()
		vim.keymap.set("t", "jk", [[<C-\><C-n>]], { buffer = true, desc = "Exit fzf terminal mode" })
	end,
})

vim.api.nvim_create_autocmd({ "BufRead", "BufNewFile" }, {
	group = vim.api.nvim_create_augroup("env_filetype", { clear = true }),
	pattern = { "*.env", ".env.*" },
	callback = function()
		vim.opt_local.filetype = "sh"
	end,
})

-- Set filetype for .ejs files
vim.api.nvim_create_autocmd({ "BufRead", "BufNewFile" }, {
	group = vim.api.nvim_create_augroup("ejs_filetype", { clear = true }),
	pattern = { "*.ejs", "*.ejs.t" },
	callback = function()
		vim.opt_local.filetype = "embedded_template"
	end,
})

-- Set filetype for .code-snippets files
vim.api.nvim_create_autocmd({ "BufRead", "BufNewFile" }, {
	group = vim.api.nvim_create_augroup("code_snippets_filetype", { clear = true }),
	pattern = { "*.code-snippets" },
	callback = function()
		vim.opt_local.filetype = "json"
	end,
})

vim.api.nvim_create_autocmd("User", {
	pattern = "BlinkCmpMenuOpen",
	callback = function()
		---@diagnostic disable-next-line: undefined-field
		local formatoptions = vim.opt.formatoptions:get()
		if formatoptions.t then
			vim.b.restore_formatoptions_t = true
			---@diagnostic disable-next-line: undefined-field
			vim.opt.formatoptions:remove("t")
		end
	end,
})

vim.api.nvim_create_autocmd("User", {
	pattern = "BlinkCmpMenuClose",
	callback = function()
		if vim.b.restore_formatoptions_t then
			---@diagnostic disable-next-line: undefined-field
			vim.opt.formatoptions:append("t")
			vim.b.restore_formatoptions_t = nil
		end
	end,
})
