local opt = vim.opt
local g = vim.g

g.editorconfig = true

-------------------------------------------------------------------------------
-- 系统环境与终端设置
-------------------------------------------------------------------------------
-- 根据操作系统设置默认 Shell
if Utils.is_win() then
	Utils.terminal("nu")
else
	Utils.terminal("zsh")
end

-- 剪贴板配置：SSH 环境下禁用，本地环境下使用系统剪贴板
opt.clipboard = vim.env.SSH_CONNECTION and "" or "unnamedplus"

-- 检测 WezTerm 环境变量
if vim.env.TERM_PROGRAM == "WezTerm" then
	g.wezterm_render = true
end

-------------------------------------------------------------------------------
-- 核心编辑器行为 (Editing Behavior)
-------------------------------------------------------------------------------
opt.autowrite = true -- 自动保存
opt.autoread = true
opt.undofile = true -- 开启持久化撤销
opt.undolevels = 10000 -- 最大撤销步数
opt.updatetime = 200 -- 响应时间（影响插件触发速度）
opt.timeoutlen = g.vscode and 1000 or 300 -- 键序列超时时间
opt.confirm = false -- 退出未保存文件时不弹出确认框
opt.mouse = "a" -- 开启鼠标支持

-- 单词识别与文本处理
-- 将下划线从单词定义中移除，使 user_name 被视为两个词
opt.iskeyword:remove("_")
opt.textwidth = 80 -- 文本最大宽度
opt.formatoptions = "jcroqlnt" -- 自动排版优化

-------------------------------------------------------------------------------
-- 缩进与排版 (Indent & Tabs)
-------------------------------------------------------------------------------
opt.expandtab = true -- 将 Tab 转换为转换空格
opt.shiftwidth = 2 -- 缩进宽度为 2
opt.tabstop = 2 -- Tab 占据的空格数
opt.shiftround = true -- 缩进对齐到 shiftwidth 的倍数
opt.smartindent = true -- 智能缩进
opt.linebreak = true -- 折行时不截断单词
opt.breakindent = true -- 折行时保持缩进对齐

-------------------------------------------------------------------------------
-- 搜索与过滤 (Search & Grep)
-------------------------------------------------------------------------------
opt.ignorecase = true -- 搜索忽略大小写
opt.smartcase = true -- 存在大写字母时自动开启大小写敏感
opt.inccommand = "nosplit" -- 实时预览替换效果
opt.grepprg = "rg --vimgrep" -- 使用 ripgrep 作为 grep 工具
opt.grepformat = "%f:%l:%c:%m"

-------------------------------------------------------------------------------
-- 界面视觉设置 (UI Appearance)
-------------------------------------------------------------------------------
opt.number = true -- 显示行号
opt.relativenumber = true -- 显示相对行号
opt.numberwidth = 4 -- 行号列宽度
opt.cursorline = true -- 高亮当前行
opt.signcolumn = "yes" -- 始终显示左侧标志列（防止抖动）
opt.laststatus = 3 -- 全局状态栏（Neovim 0.7+ 特性）
opt.showmode = false -- 不显示模式信息（通常状态栏插件已提供）
opt.ruler = false -- 隐藏标尺
opt.termguicolors = true -- 开启 24 位真彩色支持
opt.winminwidth = 5 -- 窗口最小宽度
opt.pumheight = 10 -- 补全菜单最大高度
opt.pumblend = 10 -- 补全菜单透明度

opt.guicursor = {
	"n-v-sm:block-Cursor",
	"i-ci-ve:ver25-Cursor",
	"c:ver25-Cursor",
	"r-cr-o:hor20-Cursor",
}

-- 布局方案
opt.splitbelow = true -- 水平分割窗口在下方
opt.splitright = true -- 垂直分割窗口在右方

-- 列表字符显示 (不可见字符)
opt.list = true
opt.fillchars = {
	foldopen = "",
	foldclose = "",
	fold = " ",
	foldsep = " ",
	diff = " ",
	eob = " ",
}

-------------------------------------------------------------------------------
-- 补全、折叠与跳转 (Navigation & Completion)
-------------------------------------------------------------------------------
opt.completeopt = { "menu", "menuone", "noselect" }
opt.complete = "" -- 禁用所有内置补全源（交给插件处理）
opt.jumpoptions = "stack" -- 跳转列表以栈形式工作
opt.sessionoptions = { "buffers", "curdir", "tabpages", "winsize", "help", "globals", "skiprtp", "folds" }

-- 折叠设置
opt.foldlevel = 99
opt.foldmethod = "indent" -- 基于缩进进行折叠
opt.foldtext = ""
opt.conceallevel = 2 -- 隐藏某些特定标记（如 Markdown）

-- 滚动平滑度
opt.scrolloff = 10 -- 光标距离上下边界保留 10 行
opt.sidescrolloff = 8 -- 光标距离左右边界保留 8 列
opt.smoothscroll = true -- 开启平滑滚动（Neovim 0.9+）
opt.virtualedit = "onemore" -- 光标可以移动到行尾最后一个字符之后

-------------------------------------------------------------------------------
-- 语言与外部渲染 (Fonts & External Tools)
-------------------------------------------------------------------------------
opt.spelllang = { "en" }
g.have_nerd_font = true
opt.guifont = "Maple Mono NF CN:h14"
opt.winborder = "rounded" -- 窗口边框圆角

-------------------------------------------------------------------------------
-- Neovide 专属配置 (GUI Setting)
-------------------------------------------------------------------------------
-- 窗口设置
g.neovide_fullscreen = false
g.neovide_opacity = 0.90
g.neovide_window_blurred = true
g.neovide_hide_mouse_when_typing = true

-- 性能优化
g.neovide_refresh_rate = 165
g.neovide_refresh_rate_idle = 5

-- 光标特效与动画
g.neovide_cursor_animation_length = 0.10
g.neovide_cursor_short_animation_length = 0.02
g.neovide_cursor_trail_size = 0.5
g.neovide_cursor_vfx_mode = "pixiedust"
g.neovide_cursor_antialiasing = true
