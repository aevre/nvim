# 功能、依赖与排错

[English](configuration.md) | [简体中文](configuration.zh-CN.md)

[返回 README](../README.zh-CN.md) · [快捷键](keymaps.zh-CN.md) · [工具链](toolchain.zh-CN.md)

## 插件加载与功能

Lazy 导入 `plugins` 以及 `coding`、`colorschemes`、`deps`、`editor`、`highlight`、`lsp`、`qol`、`ui` 分类。使用 `:Lazy` 查看插件状态。

| 功能 | 当前实现与触发 |
| --- | --- |
| 搜索 | fzf-lua 启动加载，提供文件、grep、Git、LSP 与自定义 source |
| 文件浏览 | Oil 启动加载并接管默认 explorer；mini.files 由 `<leader>e` 触发；Oil 诊断与 Git 扩展按 `oil` filetype 加载 |
| 补全 | blink.cmp 在 `InsertEnter` / `CmdlineEnter` 加载，使用 LSP、LuaSnip、path、buffer、ripgrep、Minuet 源 |
| 片段 | LuaSnip + friendly-snippets，另加载 `snippets/` 中的 Lua 片段 |
| 编辑 | blink.pairs、mini.ai/jump/move/splitjoin/surround、ts-comments、ts-autotag 多在 `BufEdit` 加载；Dial 提供增减操作 |
| 跳转 | Flash 在 `VeryLazy` 加载；Treesitter textobjects 在 `BufEdit` 加载 |
| 格式化与检查 | Conform、nvim-lint 在 `BufEdit` 加载，工具关联由 toolchain 提供 |
| Git | mini.git 与 mini.diff 在 `BufEdit` 加载；CodeDiff 通过命令/快捷键加载；Lazygit 使用本地终端封装 |
| 大纲与注释 | Aerial 通过 `<leader>cs` 加载；Neogen 通过命令/快捷键加载 |
| 会话 | session.nvim 在 `BufReadPre` 加载；启用自动保存，关闭自动恢复与切换会话时保存；提供恢复、选择和手动保存键位 |
| 搜索替换 | grug-far 通过命令/快捷键加载 |
| UI | Alpha 在 `VimEnter`，Heirline 在 `UIEnter`；Incline、缩进线、Treesitter context 在 `BufEdit` |
| 消息与诊断 | cmdline.nvim 与 notify.nvim 启动加载，负责命令行/消息界面与通知；notify.nvim 同时处理 LSP 进度；tiny-inline-diagnostic 在 `LspAttach` 加载并关闭原生 virtual text |
| 其他 | Which-key 在 `VeryLazy`，Yanky 和 Screenkey 由键位触发；WakaTime 在 `BufEdit` |
| HTTP | nvim-http-client 通过 `VeryLazy`、`http/rest` 或快捷键加载；向上查找 `http-client.env.json` |
| AI | Minuet 与 llm.nvim 均配置为 `BufEdit` 加载；Minuet 也是 blink.cmp 的依赖 |

明确禁用的 spec：persistence.nvim、noice.nvim、nvim-notify、refactoring.nvim、mini.pairs、rainbow-delimiters.nvim、tiny-cmdline.nvim、transparent.nvim、mini.clue、neoscroll.nvim、snacks.nvim、treesitter-parser-registry。`lspconfig.lua` 返回空表，当前不使用 nvim-lspconfig 插件配置 LSP。透明效果来自本地主题模块，与禁用的 transparent.nvim 无关。

cmdline.nvim 启用命令行弹窗、消息/搜索通知视图和 NUI popup menu。notify.nvim 将匹配 `saved …`、`written` 或 `已写入` 的保存确认路由到内置 Fidget 视图，其余 `vim.notify()` 与 `msg.show.*` 消息进入常规通知。`<leader>n` 查看通知历史，`<leader>fn` 查看 Fidget 历史。`NVIM_PLUGIN_MODE=dev` 还会启用 notify.nvim 的调试输出。

## 工具链的实际行为

LSP 使用 `lsp/<名称>.lua` 和 `vim.lsp.enable()`。打开 filetype 时读取语言规格；有 Mason 名称映射的服务只有在对应 Mason 包已安装时才会启用，没有映射的名称直接通过这一检查。PATH 中存在同名服务并不能绕过已映射服务的 Mason 门槛。服务还需满足自身 filetype、root 和命令条件。

Mason 在 `VeryLazy` 刷新注册表并安装缺失包；安装成功后重新尝试已打开 buffer 的 LSP。当前自定义 `config` 直接使用 Mason registry，并未调用 mason-lspconfig 的 `setup()`。Java 声明了 `jdtls`，但 `lsp/jdtls.lua` 仅设置 `cmd = "jdtls"`，nvim-jdtls spec 也只有 `ft = "java"`；项目 workspace 和调试集成需要另行配置。

Conform 的 `<leader>cf` 异步格式化，默认超时配置为 3000ms，允许 LSP fallback。没有设置 `format_on_save`。Web formatter 按 `prettier → biome → oxfmt` 的声明顺序筛选并执行可用项，不是严格三选一；Python 同样声明了 `ruff_format → isort → yapf`，Go 为 `goimports → gofumpt`。

nvim-lint 在 `BufReadPost`、`BufWritePost`、`InsertLeave` 上注册 100ms 防抖回调。ESLint 与 Oxlint 需满足工具规格中的配置文件条件；JavaScript/TypeScript 的 React filetype 被排除在这两项 CLI lint 映射之外，但 LSP 仍可能提供诊断。

Treesitter 使用 `main` 分支，在 `BufReadPre`、`BufNewFile` 或 `VeryLazy` 加载。只有语言规格声明了 `treesitter` 的 filetype 才注册启动回调。先尝试启动已有 parser，失败时请求对应 parser 安装，每 100ms 重试，达到 300 次后报告失败。成功后设置 Treesitter 缩进和当前可见窗口的折叠表达式。独立的 CSS/HTML 文件未配置 Treesitter 自动启动；Vue 规格额外声明了 CSS/SCSS parser。

调试使用工具链中的 DAP 规格，仅增加 `nvim-dap` 和 `nvim-dap-view`；GDB 14.1+ 由系统提供，Delve、debugpy 和 JS 调试适配器按 filetype 选择 Mason 包。适配器行为、launch.json 支持、限制和测试见[工具链配置](toolchain.zh-CN.md#调试)。

## 需要自行准备的集成

| 工具或配置 | 使用场景 |
| --- | --- |
| `lazygit` | `<leader>gg` |
| `rmpc` | `<leader>tm` 音乐终端 |
| `zoxide` | fzf 的目录历史入口 |
| `gh` 与 GitHub 登录 | GitHub issue / PR 查询 |
| `curl` | HTTP/API 相关插件所需的外部请求环境 |
| `rustfmt` | Rust 格式化，当前没有 Mason 名称映射，通常通过 rustup 安装 |
| Dart SDK | `dartls` 调用 `dart language-server`，没有 Mason 映射 |
| Qt/QML 环境 | `qmlls` 及项目所需 Qt 工具 |
| 输入法命令 | 非 Windows 分支依次检测 `fcitx5-remote`、`fcitx-remote`、`ibus`；未找到会警告并回退到 fcitx5 命令名 |
| WakaTime 账户配置 | 已启用 WakaTime 插件，需要自行完成认证 |
| `OPENROUTER_TOKEN` | Minuet 补全及 llm.nvim 当前 OpenRouter 模型 |
| `TAVILY_TOKEN` | llm.nvim 网页搜索 |

Minuet 和 llm.nvim 当前模型为 `cohere/north-mini-code:free`；模型是否仍可用取决于服务端。`llm/models.lua` 中其他 provider 的定义没有加入当前 `models` 列表，不表示默认启用。聊天历史保存于 `stdpath('cache')/llm-history`。LLM 扩展覆盖问答、代码解释、翻译、测试/文档生成、提交信息和 BashRunner；调用前应阅读对应扩展，尤其 BashRunner 的命令执行行为。

## 文件类型与主题

`after/ftplugin/` 为 Vue、Oil、mini.files 提供补充行为。本地 LuaSnip 文件为 `snippets/go/go.lua`、`snippets/java/java.lua` 和 `snippets/vue/vue.lua`；片段可用性还取决于 LuaSnip 和 friendly-snippets 的加载。

`lua/config/filetype.lua` 为 Shell dotfile、Git 配置文件、`Taskfile`、`Brewfile` 等列出的文件名补充类型检测，同时识别对应的 `.tmpl` 和 chezmoi 前缀变体，例如 `dot_zshrc`、`private_dot_zshrc.tmpl`。

自动命令将 `*.env` / `.env.*` 设为 `sh`，`*.ejs` / `*.ejs.t` 设为 `embedded_template`，`*.code-snippets` 设为 `json`。JSON/JSONC 不隐藏文本；多个特殊窗口注册 `q` 关闭并从 buffer 列表隐藏。`FileType` 时移除 `formatoptions` 的 `c/r/o`，关闭注释自动排版和续写。

主题从 `lua/theme/palette.lua` 取得基础颜色，并合并 `palette.json`；默认 `variant = "auto"` 跟随 `background`。透明状态由 `stdpath('data')/transparent` 标记文件决定，`setup()` 会用该文件覆盖传入的 transparent 值。`:TransparentToggle` 修改标记并重新应用主题；支持信号的平台还注册了 SIGUSR1 重新应用主题。

## 排错

| 现象 | 检查步骤 |
| --- | --- |
| 启动或插件安装失败 | `:messages`、`:Lazy` 日志；确认 Git、网络、Neovim 版本及构建环境 |
| 终端或外部命令失败 | `:set shell?`，确认 `zsh` / `nu`；再检查具体命令是否在 PATH |
| LSP 未连接 | `:set ft?` → `<leader>cL` 确认声明 → `:Mason` 确认包 → `<leader>cl` 查看状态 → 检查 `lsp/` root 与 cmd；也可运行 `:checkhealth vim.lsp` |
| 格式化未执行 | `:ConformInfo` 查看当前 formatter、可执行文件与日志；确认项目配置满足条件；保存本身不会调用 Conform |
| lint 缺失 | 查看 `:lua vim.print(require('lint').linters_by_ft[vim.bo.filetype])`，检查配置文件条件和 CLI 是否可执行 |
| Treesitter 无高亮 | 确认语言规格的 parser/filetype，再查看 `:messages` 和 `:checkhealth nvim-treesitter`；首次安装需等待 |
| 图标乱码或剪贴板失败 | 使用 Nerd Font，执行 `:checkhealth`；SSH 下系统剪贴板同步本来就被关闭 |
| 键位与预期不同 | `:verbose nmap <键>` / `:verbose imap <键>` 查看最终定义与来源；注意延迟加载和 LSP attach 会影响注册顺序 |

