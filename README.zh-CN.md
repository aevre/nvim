# Neovim 配置

[English](README.md) | [简体中文](README.zh-CN.md)

面向日常开发的个人 Neovim 配置，以 lazy.nvim 管理插件，使用 Neovim 原生 LSP、blink.cmp 补全、Conform 格式化、nvim-lint 检查和 nvim-treesitter。语言与工具关系集中在 `lua/toolchain/`，主题由本地 `lua/theme/` 实现。

运行环境为 **Neovim 0.12.5**。配置使用 `vim.lsp.get_configs()`、`vim.lsp.codelens.enable()`、`vim.pack.update()` 等新接口，建议使用 Neovim 0.12，不承诺旧版本兼容。

- [快捷键参考](docs/keymaps.zh-CN.md)
- [功能、依赖与排错](docs/configuration.zh-CN.md)
- [语言与工具链配置](docs/toolchain.zh-CN.md)

## 安装

先备份已有 Neovim 配置。在 Linux/macOS 的默认配置路径下安装：

```sh
git clone https://github.com/immortal521/nvim.git ~/.config/nvim
nvim
```

目标目录必须不存在；使用自定义 `XDG_CONFIG_HOME` 时应放到对应的 `nvim` 目录。Windows 请放到 `:echo stdpath('config')` 对应的位置。配置虽然包含 Windows 分支，但仍有外部命令和平台相关行为，详见依赖说明。

首次启动会用 Git 克隆 lazy.nvim 的 stable 分支，随后安装插件。`VeryLazy` 阶段会刷新 Mason 注册表，安装工具链声明且有包名映射的工具及额外工具；这是全部声明工具的安装清单，不是只安装当前语言。Treesitter 则在支持的文件类型需要 parser 时请求安装。网络、编译器和语言运行时需要自行准备。

基本环境：

| 依赖 | 用途 |
| --- | --- |
| Neovim 0.12、Git | 编辑器、插件安装、Git 功能 |
| `zsh`；Windows 为 `nu` | 配置明确选择的 Shell，不直接沿用 `$SHELL` |
| `rg`、`fzf` | 文本搜索、选择器和 ripgrep 补全源 |
| C 编译工具链、`tree-sitter` CLI | Treesitter parser 构建；CLI 在 Mason 额外安装清单中 |
| Node.js/npm、Python、Go、Rust、Java 等 | 按语言及 Mason 包的实际安装要求准备；Mason 不负责安装所有语言运行时 |
| Nerd Font | 文件、诊断与状态栏图标；GUI 字体配置为 `Maple Mono NF CN:h14` |
| 系统剪贴板 provider | 本地 `unnamedplus` 剪贴板，具体工具由 `:checkhealth` 确认 |

blink.cmp 配置包含原生组件构建步骤；如构建失败，在 `:Lazy` 查看日志并按当前插件版本准备 Rust 工具链。更多可选命令（`lazygit`、`gh`、`zoxide`、`rmpc` 等）见[功能文档](docs/configuration.zh-CN.md)。

安装后检查：

```vim
:Lazy
:Mason
:checkhealth
:ConformInfo
```

打开实际项目文件，用 `<leader>cl` 检查 LSP，用 `<leader>cL` 查看对应语言规格。`<leader>` 和 `<localleader>` 都是空格。

## 日常入口

以下为普通模式常用键，完整模式与加载条件见[快捷键参考](docs/keymaps.zh-CN.md)。

| 按键 | 功能 |
| --- | --- |
| `<leader><space>` / `<leader>ff` | 查找文件 |
| `<leader>/` | 搜索项目文本 |
| `<leader>,` | 选择 buffer |
| `<leader>e` | mini.files 文件浏览器；默认目录浏览由 Oil 接管 |
| `<leader>gg` | Lazygit |
| `<leader>tf` | 浮动终端 |
| `<leader>cf` | 手动格式化 |
| `<leader>cd` | 当前行诊断 |
| `gd` / `gr` / `K` | LSP 定义、引用、悬浮文档（attach 后注册） |
| `<leader>ca` / `<leader>cr` | LSP code action / rename |
| `<leader>L` / `<leader>cm` | Lazy / Mason |
| `<leader>?` | 当前 buffer 的快捷键提示 |

配置启用自动保存插件，在 `InsertLeave`、`TextChanged` 时按条件保存；**没有配置 Conform 保存时自动格式化**。默认两空格缩进、相对行号、持久化撤销；SSH 环境下关闭 `unnamedplus` 系统剪贴板联动。

## 目录

```text
init.lua                   加载 config
lua/config/                选项、自动命令、全局键位、LSP、插件引导
lua/plugins/               按功能分组的 lazy.nvim spec 与插件内部模块
lua/toolchain/             语言规格、工具条件、Mason 名称映射
lsp/                       原生 LSP 的命令、根目录与 settings
lua/builtin/               本地 buffer 工具
lua/theme/                 调色板、高亮与透明背景
palette.json               当前主题的 JSON 覆盖值
lua/sources/               fzf 的语言、LSP、通知、图标数据源
lua/utils/                 共享工具函数
snippets/                  本地 LuaSnip 片段（当前为 Vue）
after/ftplugin/            Vue、Oil、mini.files 的文件类型补充
docs/                      中英文参考文档
lazy-lock.json             插件版本锁定
```

启动顺序为主题 → options → autocmds → keymaps → LSP/toolchain → lazy.nvim 引导 → 自定义事件 → 插件管理器。`BufEdit` 是本配置定义的 Lazy 事件别名，覆盖 `BufReadPost`、`BufNewFile`、`BufWritePre`。

## 修改配置

- 编辑行为与 Shell：[lua/config/options.lua](lua/config/options.lua)。
- 全局快捷键：[lua/config/keymaps/](lua/config/keymaps/)；插件键位通常在各自 spec 中。
- 添加或调整语言：[工具链文档](docs/toolchain.zh-CN.md)，使用 `<leader>cL` 直接打开规格。
- LSP 参数：[lsp/](lsp/)。文件存在不代表已启用，还需语言规格声明、安装与根目录条件满足。
- 主题：[lua/theme/](lua/theme/) 和 [palette.json](palette.json)。当前入口直接应用本地主题，没有调用 `colorscheme tokyonight`；`:TransparentToggle` 切换并持久化透明状态。
- 自有插件本地开发：设置 `NVIM_PLUGIN_MODE=dev`，即可从 `~/Projects/lib` 加载 `win`、`animate`、`scroll`、`terminal`、`lazygit`、`notify` 六个插件；未设置或使用其他值时从 Codeberg 加载。`NVIM_DEV_DIR` 仍是 Lazy 独立的通用本地插件匹配设置。

更新插件使用 `:Lazy update`；如需按已提交的锁文件恢复版本，使用 `:Lazy restore`。`<leader>pu` 调用的是 Neovim 原生 `vim.pack.update()`，不等于更新 Lazy 管理的插件。
