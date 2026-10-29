# Toolchain 配置

[English](toolchain.md) | [简体中文](toolchain.zh-CN.md)

[返回主文档](../README.zh-CN.md) · [功能与排错](configuration.zh-CN.md)

`lua/toolchain` 是语言和开发工具配置的统一入口：

- `toolchain/lang/specs/*.lua` 描述语言、filetype、LSP、Treesitter，以及该语言使用的 formatter/linter 名称。
- `toolchain/format/specs/*.lua` 与 `toolchain/lint/specs/*.lua` 描述工具条件（分别使用 `formatter` 和 `linter` 字段）。`toolchain/specs.lua` 自动发现语言、格式化、lint 和调试规格目录中的 `.lua` 文件。
- `toolchain/mason.lua` 将 LSP、formatter、linter 名称映射为 Mason 包名，并保留调试和辅助工具。
- `toolchain/init.lua` 聚合这些配置，供 LSP、Conform、nvim-lint、Mason、Treesitter 和 fzf source 使用。

公共入口由 `require("toolchain")` 提供：

| 方法 | 返回内容 |
| --- | --- |
| `setup()` | 注册按 `FileType` 延迟启用 LSP 的自动命令。 |
| `get_formatters()` | 从语言规格聚合 `filetype -> formatter[]`。 |
| `get_formatter_configs()` | 返回工具规格提供的 Conform formatter 条件。 |
| `get_linters()` | 从语言规格聚合 `filetype -> linter[]`。 |
| `get_linter_configs()` | 返回工具规格提供的 nvim-lint linter 条件。 |
| `get_treesitter()` | 返回语言规格声明的 parser 和用于启动 parser 的 filetype。 |
| `get_language_by_filetype(ft)` | 合并声明该 filetype 的语言规格；不存在时返回 nil。 |
| `get_mason_packages(ft)` | 返回语言工具和额外工具对应的 Mason 包名。 |

语言规格只描述语言与工具的关系；工具条件、LSP 启动参数和 UI 行为分别由
对应的 `format/specs/` / `lint/specs/`、`lsp/` 和插件配置负责。

## 目录结构

```text
lua/toolchain/
├── init.lua
├── specs.lua
├── mason.lua
├── lang/
│   ├── init.lua
│   └── specs/*.lua
├── format/
│   ├── init.lua
│   └── specs/*.lua
├── lint/
│   ├── init.lua
│   └── specs/*.lua
└── debug/
    ├── init.lua
    ├── context.lua
    └── specs/*.lua
```

语言和工具规格目录中的每个 `.lua` 文件都会被自动扫描。不要在这些
`specs/` 目录中放置模板 Lua 文件、测试文件或返回非规格内容的 Lua 文件，
无效规格会在加载时明确报出来源。工具链文档放在 `docs/`，
模板应放在规格目录之外或 Markdown 文件中。

## 语言规格

例如 `lua/toolchain/lang/specs/zig.lua`：

```lua
---@type LanguageSpec
return {
	filetypes = { "zig" },
	formatters = { "zigfmt" },
	lsp = { "zls" },
	treesitter = { "zig" },
}
```

`filetypes` 是必填的非空字符串数组，必须填写 Neovim 实际使用的
`vim.bo.filetype`，而不是文件扩展名。例如 React 文件使用
`javascriptreact` 或 `typescriptreact`。

支持的字段：

| 字段 | 类型 | 作用 |
| --- | --- | --- |
| `filetypes` | `string[]` | 语言对应的 Neovim filetype，必填。 |
| `formatters` | `string[]` | 该语言的 Conform formatter 名称。 |
| `linters` | `string[]` | 该语言的 nvim-lint linter 名称。 |
| `lint_filetypes` | `string[]` | 实际运行 lint 的 filetype；省略时使用 `filetypes`。 |
| `lsp` | `string[]` | 打开对应 filetype 时按需启用的 LSP 名称。 |
| `treesitter` | `string[]` | 要安装和启用的 Treesitter parser 名称。 |
| `treesitter_filetypes` | `string[]` | 额外触发这些 parser、但不继承语言其他工具的 filetype。 |

即使只有一个值也使用数组形式，例如 `{ "stylua" }`。同一 filetype 被多个
语言规格声明时，formatter、linter、LSP 和 Treesitter 聚合查询会去重。

Treesitter 插件从规格取得 filetype 列表，为这些类型注册 `FileType` 回调，
先尝试启动已有 parser，失败后再安装该语言规格声明的 parser。当前没有额外
基础 parser 列表，也不会在启动时一次性安装全部语言的 parser。
`typescriptreact`、`markdown.mdx` 是 filetype，不会直接当作规格中的 parser 名称。

插件在 `BufReadPre`、`BufNewFile` 或 `VeryLazy` 加载；安装后每 100ms 重试
启动，达到 300 次后报告失败。成功后启用 Treesitter 缩进与可见窗口的折叠表达式。
没有 `treesitter` 字段的语言不会进入此自动启动列表。

LSP 的具体命令、root、settings 和特殊行为仍放在顶层 `lsp/` 目录：

```text
lsp/pyright.lua
lsp/ruff.lua
```

语言规格只决定哪些语言使用它；修改 LSP 实现细节时修改对应的
`lsp/<名称>.lua`。

Neovim 配置中的 Lua 使用 `lua_ls`。配置根目录的 `.luarc.json` 提供全局变量、
LuaJIT 环境等项目设置；`lsp/lua_ls.lua` 声明启动命令、filetype 和项目根标记，
并动态将已安装插件的 `lua` 目录、luv library 和 `VIMRUNTIME` 加入 workspace library。

## 工具规格

工具规格负责工具自己的可用条件。以 Prettier 为例：

```lua
local configs = {
	".prettierrc",
	".prettierrc.json",
	"prettier.config.js",
}

---@type FormatSpec
return {
	formatter = {
		condition = function(_, ctx)
			return #vim.fs.find(configs, {
				path = vim.fs.dirname(ctx.filename),
				upward = true,
				stop = vim.uv.os_homedir(),
			}) > 0
		end,
	},
}
```

`formatter.condition` 是 Conform formatter condition，返回 `true` 才会让
该 formatter 可用。工具条件不负责决定语言是否使用它；语言与工具的关联
仍由 `toolchain/lang/specs/*.lua` 中的 `formatters` 字段声明。

当前可选 formatter 的条件：

- Prettier：找到 Prettier 配置文件后才生效。
- Biome：找到 `biome.json` 或 `biome.jsonc` 后才生效。
- Oxfmt：找到 Oxfmt 配置文件后生效；当项目没有 Prettier、Biome、Oxfmt
  配置时，作为默认 fallback 生效。

这些条件位于：

```text
lua/toolchain/format/specs/prettier.lua
lua/toolchain/format/specs/biome.lua
lua/toolchain/format/specs/oxfmt.lua
```

配置探测从当前文件目录向上搜索，以 home 目录为停止边界，只识别各工具规格中
列出的文件名，不检查 `package.json` 字段；`.prettierrc.cjs`、`eslint.config.ts`
等未列出的名称不会被识别。因此，未识别的 Prettier 配置也不会阻止 Oxfmt fallback。

修改 CLI formatter 配置文件探测规则时，修改对应工具规格，不要把条件逻辑重新写回
`lua/plugins/formatter.lua`。

Linter 也遵循相同规则。语言规格中的 `linters` 只声明语言使用哪些 linter，
工具规格中的 `linter.condition` 决定该 linter 在当前项目中是否启用。条件由
本配置的 linter 回调在调用 `lint.try_lint()` 前根据当前文件路径执行。

当前带项目配置条件的 linter：

- ESLint：找到 ESLint 配置文件后才生效。
- Oxlint：找到 `.oxlintrc.json` 后才生效。

这些条件位于：

```text
lua/toolchain/lint/specs/eslint.lua
lua/toolchain/lint/specs/oxlint.lua
```

修改 linter 配置文件探测规则时，只修改对应工具规格，不要把条件逻辑写回
`lua/plugins/linter.lua`。后者负责合并配置、筛选工具和触发 lint。

这些条件只控制 CLI formatter 和 linter。同名 LSP 在 `lsp/<名称>.lua` 中独立
判断 root 和配置文件；需要同时改变两者行为时，也应修改对应 LSP 文件。例如
Oxlint LSP 识别 `oxlint.config.ts`，CLI 条件只识别 `.oxlintrc.json`；Oxfmt LSP
也没有 formatter 的无配置 fallback。

Conform 当前仍使用 formatter 列表的默认行为：如果多个 formatter 条件同时
满足，且调用时没有设置 `stop_after_first = true`，Conform 可能按顺序执行多个
formatter。工具规格只决定工具是否可用，不改变这个执行策略。

formatter 是否安装由 Mason 包列表决定，formatter 是否对当前项目生效由
Conform 的 `condition` 决定；这两个判断相互独立。某个 formatter 被语言规格
声明，并不表示它在每个项目中都会运行。

Luau 通过语言规格使用 `stylua`。GraphQL 和 Handlebars 当前没有 formatter
映射；需要时在语言规格中添加对应工具。Zsh 使用 `shfmt` 和共享的 Bash
language server；ShellCheck 不支持 zsh，因此改用原生 `zsh -n` 语法检查。

## 当前语言清单

下表列出规格中的 Conform formatter、CLI linter 与 LSP 声明；formatter 栏的
`—` 表示没有 Conform 映射，手动格式化仍可回退到支持格式化的已连接 LSP。
这些声明仍受工具可用性、服务自身 filetype/root 和安装条件限制。
Web 格式化组合指 `prettier → biome → oxfmt`。

| 规格 / filetype | Formatter | CLI linter | LSP |
| --- | --- | --- | --- |
| bash / bash, sh | shfmt | shellcheck | bash-language-server |
| zsh / zsh | shfmt | zsh（`zsh -n`） | bash-language-server（共享） |
| c / c | clang_format | — | clangd |
| cpp / cpp | clang_format | — | clangd |
| css / css, scss, less | Web 组合 | — | css-lsp, css-variables-language-server, emmet-language-server, stylelint-language-server, tailwindcss, biome, oxfmt |
| dart / dart | — | — | dartls |
| go / go | goimports, gofumpt | golangcilint | gopls |
| html / html | Web 组合 | — | html, emmet-language-server, stylelint-language-server, tailwindcss, biome, oxfmt |
| java / java | — | — | jdtls（原生 LSP、独立项目 workspace） |
| javascript / javascript, javascriptreact | Web 组合 | eslint, oxlint（仅 javascript） | vtsls, biome, oxlint, cssmodules-language-server, oxfmt |
| json / json, jsonc | Web 组合 | — | jsonls, biome, oxfmt |
| kotlin / kotlin | — | — | kotlin-lsp |
| lua / lua | stylua | selene | lua_ls |
| luau / luau | stylua | — | luau-lsp |
| markdown / markdown, markdown.mdx | Web 组合 | — | tailwindcss, oxfmt |
| nix / nix | nixfmt | — | rnix |
| nu / nu | — | — | —（nushell 声明被注释） |
| python / python | ruff_format, isort, yapf | — | pyright, ruff |
| qml / qml, qmljs | — | — | qmlls |
| rust / rust | rustfmt | — | rust_analyzer, bacon-ls |
| sql / sql | sqruff | — | — |
| toml / toml | taplo | — | tombi |
| typescript / typescript, typescriptreact | Web 组合 | eslint, oxlint（仅 typescript） | vtsls, biome, oxlint, oxfmt |
| vue / vue | Web 组合 | eslint, oxlint | vue_ls, vtsls, stylelint-language-server, tailwindcss, biome, oxfmt |
| xml / xml, svg | xmlformatter | — | — |
| yaml / yaml | Web 组合 | — | — |

Parser 声明为 bash、zsh、c、cpp、go、gomod、gowork、gotmpl、java、javascript、
json、kotlin、lua、markdown/markdown_inline、nix、python、rust、toml、typescript/tsx、
vue/css/scss、xml、yaml。`gosum` filetype 会触发 Go 相关 parser 安装；没有独立的
`gosum` parser。CSS、Dart、HTML、Luau、Nu、QML、SQL 规格没有 `treesitter` 字段。

## Lint 规则

如果某些 filetype 不应运行 lint，使用 `lint_filetypes`，例如：

```lua
filetypes = { "typescript", "typescriptreact" },
linters = { "eslint", "oxlint" },
lint_filetypes = { "typescript" },
```

这就是 JavaScript/TypeScript 排除 React filetype 的方式。不要从
`filetypes` 中删除 React 类型，否则会同时影响 LSP 和 formatter。

## 新增语言

以新增 Zig 为例：

1. 确认 Neovim 的 filetype 是 `zig`。
2. 新建 `lua/toolchain/lang/specs/zig.lua`，至少填写 `filetypes`。
3. 按需补充 `formatters`、`linters`、`lsp` 和 `treesitter`。
4. 如果 LSP 名称没有对应的 `lsp/<名称>.lua`，新建该文件。
5. 如果工具需要配置文件条件，在 `toolchain/format/specs/` 或 `toolchain/lint/specs/` 中新增或修改对应规格。
6. 需要 Mason 自动安装的工具，在 `lua/toolchain/mason.lua` 中添加显式名称映射，即使运行时名称与包名相同也要登记。
7. 打开该语言文件，确认 LSP、格式化、lint 和 Treesitter 行为。

新增语言不需要修改语言列表，也不需要手动加入 fzf source；`<leader>cL`
会自动显示新语言规格。

## 修改已有配置

- 改变语言与 filetype 的关系：修改 `toolchain/lang/specs/*.lua` 的 `filetypes`。
- 改变语言使用哪些工具：修改语言规格的 `formatters` 或 `linters`。
- 改变 formatter 或 linter 是否可用：修改 `toolchain/format/specs/<tool>.lua` 或 `toolchain/lint/specs/<tool>.lua` 中的 `formatter` 或 `linter` 字段。
- 改变 LSP 命令、root 或 settings：修改 `lsp/<名称>.lua`。
- 改变 Treesitter parser/filetype：修改语言规格的 `treesitter` / `filetypes`。
- 改变 Treesitter 启动、安装与重试机制：修改 `lua/plugins/highlight/treesitter.lua`。
- 添加 formatter 关联：在语言规格的 `formatters` 中声明。

不要把项目路径写入语言或工具规格；这些规格必须能复用在不同工作区。

## Mason 自动安装

`VeryLazy` 阶段刷新 Mason registry 后，会处理已打开的 buffer，并监听后续 `FileType`。调用 `toolchain.get_mason_packages(ft)`，仅安装该 filetype 声明且有映射的 LSP、formatter、linter、debug adapter，以及额外工具。Mason 包名与运行时
名称可能不同，例如：

| 运行时名称 | Mason 包名 |
| --- | --- |
| `rust_analyzer` | `rust-analyzer` |
| `clang_format` | `clang-format` |
| `golangcilint` | `golangci-lint` |
| `ruff_format` | `ruff` |

名称映射位于 `lua/toolchain/mason.lua`。需要 Mason 自动安装的 LSP、formatter
或 linter 都必须显式登记，即使运行时名称与 Mason 包名相同。未映射的工具仍会
被配置声明使用，但除非列入 `extra_packages`，否则不会进入自动安装清单。

Debug 映射为 `delve -> delve`、`debugpy -> debugpy`、`js-debug -> js-debug-adapter`；GDB 无 Mason 映射。`require("toolchain").mason.extra_packages` 默认为空，可加入额外包名，未知 filetype 也会包含这些额外包。Mason 注册表刷新失败或包不存在时，安装动作由 Mason
自身报告失败，不会阻止语言规格加载。

LSP 则按 `FileType` 启用：有名称映射时，必须先在 Mason 中安装；无映射时
`is_installed()` 直接返回 true，后续仍取决于命令是否可执行。安装成功后会
重试已打开 buffer 的服务。`dartls` 无 Mason 映射，需要 Dart SDK；`rustfmt`
也未映射，应自行准备。ESLint 没有包名映射，CLI lint 需要项目或 PATH 提供。
`bacon-ls` 已有显式 Mason 映射。zsh filetype 与 bash 共用
`bash-language-server` 的 Mason 包映射。

语言规格的 filetype 触发首次 `vim.lsp.enable(name)`，随后该服务全局启用，
后续附着范围由服务自己的 filetypes 和 root 规则决定。例如先打开 Go 文件启用
gopls 后，它还可附着到 `gomod`、`gowork`、`gotmpl` buffer，尽管 Go 语言规格
未列出这些类型。

`lsp/emmylua.lua`、`lsp/nushell.lua`、`lsp/stylua.lua` 当前没有被语言规格启用。
Java 使用原生 `vim.lsp`，配置分层多模块/单模块 root、共享 cache configuration 和按绝对路径散列的独立 `-data` workspace。`JDTLS_JVM_ARGS` 按空白拆分为 `--jvm-arg` 参数。已移除 `nvim-jdtls`；尚未接入 java-debug/vscode-java-test bundles 及其扩展命令。

## 调试

`lua/toolchain/debug/specs/*.lua` 中的 `DebugSpec` 定义 adapter 表或 factory、configurations 和可选 DAP `type`（默认取规格文件名）。语言规格的 `debug` 可写 adapter ID 字符串，或 `{ adapter, defaults = false, configurations }`；默认配置会包含，显式配置追加，`defaults = false` 时仅使用显式配置。C、C++、Rust 共用 GDB。

`setup_debug(opts)` 保留原生配置并保证重复调用幂等；`{ override = true }` 覆盖冲突，`{ launch_json = false }` 恢复先前 provider，包括原生基于当前目录的 provider。默认保留用户自定义 provider。provider 按需读取最近的 `.vscode/launch.json`，展开 workspace 变量，并将 node/python/go 别名映射为 pwa-node/debugpy/delve；不支持 VS Code tasks/extensions 或浏览器默认配置。Toolchain 自带输入取消或留空会中止；原生 launch.json 输入沿用 nvim-dap 行为，取消未必转换成 `dap.ABORT`。不实现 VS Code command 变量、compound、task 和扩展专属字段。

GDB 需系统提供 14.1+ 且带 Python/DAP 支持，不通过 Mason 安装。GDB 版本校验和 debugpy 导入校验均限制为 3 秒；缺少或无效的 adapter 会立即报告清晰错误，不会让异步 callback 一直挂起。Python 依次选择项目 `.venv`、`venv`、活动 `VIRTUAL_ENV`、系统 Python。JS 使用命令包装器或项目的 `@vscode/js-debug`；TypeScript 提示选择编译后的 JS。Vue 仅支持 attach；需手动启动 npm/pnpm inspector 脚本。手动 Cargo 配置选择已有产物；rust-analyzer 的 `debugSingle` 会构建选中的 runnable，解析 Cargo JSON 产物后通过 GDB 启动。

Mason 按 filetype 从语言规格映射包；`extra_packages` 默认空。仅添加 `nvim-dap`、`nvim-dap-view` 插件，未实现测试结果或覆盖率框架。新增 `<leader>dl` 重复上次调试、`<leader>dh` 查看光标表达式；其他快捷键为：`<leader>dc` 继续/启动、`dp` 暂停、`dr` 重启、`dt` 终止、`db` 断点、`dB` 条件断点、`di` 步入、`do` 步过、`dO` 步出、`dg` 运行到光标、`du` 切换 UI、`de` REPL。

### 声明与扩展

```lua
-- 使用共享默认配置
return { filetypes = { "go" }, debug = { "delve" } }

-- 追加语言配置；defaults = false 表示只使用显式配置
return {
    filetypes = { "c" },
    debug = {
        { adapter = "gdb", configurations = {
            { name = "My binary", request = "launch", program = "/path/to/build/app" },
        } },
    },
}
```

一个语言可以声明多个 Adapter；同一 Adapter 只注册一次，各 filetype 的 Configuration 独立复制。未声明 `debug` 的语言不会自动获得配置。`js-debug` 是规格 ID，注册的 DAP type 是 `pwa-node`。

新增 Adapter：在 `debug/specs/<id>.lua` 返回 `adapter`（原生 executable/server/pipe 表或 callback factory）、`configurations` 列表和可选 `type`；在语言 `debug` 中引用，需要自动安装时添加 Mason 映射。无需手动索引。新增语言仍只需添加 `lang/specs/` 文件，并按需填写 `debug`。

Formatter Spec 使用 `FormatSpec.formatter`；Linter Spec 使用 `LintSpec.linter`。保留原有条件和关联，使用内置默认配置的工具不必创建额外 Spec。

### 手动配置与混合配置

```lua
local dap = require("dap")
dap.adapters.custom = { type = "executable", command = "custom-dap" }
dap.configurations.c = {
    { name = "Custom", type = "custom", request = "launch", program = "/path/to/app" },
}
require("toolchain").setup_debug()
```

手动条目保留在前，默认配置追加，完全相同的配置不重复。显示名称相同不会触发覆盖。使用 `vim.list_extend(dap.configurations.c, {...})` 显式追加；在初始化后直接赋值 `dap.configurations.c = {...}` 可替换该 filetype。`setup_debug({ override = true })` 则明确替换声明范围内的配置和 Adapter。重复初始化会刷新 Toolchain 管理的条目；持久自定义应修改语言声明或新增原生条目。已有用户 Adapter 和 Provider 默认优先。

### 初始支持与限制

| 语言 | Adapter | 默认能力 |
| --- | --- | --- |
| C / C++ | GDB | 选择可执行文件、Attach 进程、选择已构建的 CTest 命令 |
| Rust | GDB | 共享默认配置、手动 Cargo 产物选择、rust-analyzer runnable 自动构建调试 |
| Go | Delve | Package、Current File、Package Tests、Attach 本地进程 |
| Python | debugpy | File、Module、Attach 127.0.0.1:5678 |
| JS / TS（含 React filetype） | vscode-js-debug | Node Launch、Inspector Attach、Source Maps、Jest 文件/测试名调试 |
| Vue / Nuxt | vscode-js-debug | 仅 Node Inspector Attach |

GDB 便于 Linux 上共享 C/C++/Rust；LLDB 在 macOS 集成和 Rust 可视化上可能更适合，可另加 Spec。请为构建产物启用 Debug Symbols；手动 Cargo 配置不会构建；rust-analyzer `debugSingle` 会构建，但不会加载 Rust pretty printer。CTest 使用官方 JSON 发现测试，直接启动命令并保留参数和工作目录，不执行 fixtures、依赖编排或环境属性。Go Current File 仅适合自包含文件，Package Tests 调试整个包，不发现单个测试；Attach 仍受系统权限和调试器能力限制。

Node Attach 默认端口 9229，需先自行通过 `node --inspect` 或 npm/pnpm 脚本启动服务。Monorepo 使用最近的 `package.json` 作为 cwd，特殊工作目录、环境变量、参数和 Runtime 可写入 launch.json。TS 默认选择编译后的 JS 并依赖 Source Maps；不自动转译 JSX，也不直接运行 Vue SFC。未配置浏览器调试。Jest 向上查找 `node_modules/jest/bin/jest.js`，调试当前已保存文件，也可输入测试名正则；`<leader>dl` 重复上次调试。TS 断点仍依赖项目自己的 transform/source-map 配置。

Python Adapter 与目标解释器独立：Mason Adapter 可以调试项目 `.venv`。其他解释器可通过原生 `pythonPath` 指定。本地 JS Adapter 仅使用已有构建入口 `node_modules/@vscode/js-debug/src/dapDebugServer.js`，不构建源码；优先使用 Mason 导出的命令包装器。

launch.json 每次选择时重新读取，不累计写入 `dap.configurations`。使用最近包含 `.vscode` 的祖先目录，workspace 变量展开到该目录，其余变量沿用 nvim-dap。不执行 preLaunchTask、不推测远程路径映射、不实现完整 VS Code 系统。请填写 Adapter 实际支持的字段。

Go 的默认 Launch 配置使用 `outputMode = "remote"`，通过 DAP 转发 stdout/stderr；自定义 Go launch.json 也应添加此字段才能在 REPL 查看输出。Attach 不会接管已有进程的输出。UI 默认显示 REPL 标签，实时显示 Adapter 发来的程序输出；需要独立终端的程序由 dap-view 显示终端。将焦点移入调试窗口后，按 `R` 查看 REPL 输出、按 `S` 查看变量、按 `W` 查看 Watches。UI 使用 dap-view 原生 `auto_toggle = true` 管理，最后一个会话结束时关闭，可用 `<leader>du` 手动切换。监听器使用插件自身固定键，不随初始化累积。

## 验证

```sh
stylua --check lua/toolchain lua/plugins/highlight/treesitter.lua lua/sources/language.lua
git diff --check
nvim --headless -u NONE -l tests/language_debug.lua
```

实时 Go/C 会话使用实际 harness 环境，例如：

```sh
TOOLCHAIN_DEBUG_LANGUAGE=go \
TOOLCHAIN_DEBUG_SOURCE=/path/to/main.go \
TOOLCHAIN_DEBUG_PROGRAM=/path/to/go/package \
TOOLCHAIN_DEBUG_LINE=5 \
nvim --headless -u NONE -l tests/debug_session.lua
```

检查规格加载和聚合：

```sh
nvim --headless -u NONE \
  '+lua vim.opt.rtp:prepend(vim.fn.stdpath("config"))' \
  '+lua local tc=require("toolchain"); assert(#tc.lang.source_items() > 0); assert(tc.get_formatter_configs().prettier); print("toolchain specs passed")' \
  '+qa!'
```

`<leader>cL` 显示语言名和 filetype，预览显示语言规格源码，默认选择直接
打开对应的 `toolchain/lang/specs/<语言名>.lua` 文件。

`tests/language_debug.lua` 检查 Jest 路径与取消操作、CTest JSON 命令映射、JDTLS workspace 隔离、Rust Cargo JSON 产物转换和聚合后可调用配置的保留。此前 Go Package、Current File、Package Tests、C GDB 与 Rust GDB 会话已通过断点和 UI 生命周期检查；新增集成尚未经过真实会话验证，本机缺少对应 adapter/server 和代表性 Jest/CTest 项目。

Rust 每次 Cargo 启动都会以 3 秒超时调用 `cargo metadata --no-deps --format-version 1`。元数据成功时使用 `workspace_root` 和 `target_directory`；否则回退到最近的 Cargo 根目录和 `CARGO_TARGET_DIR`（或 `<root>/target`）。此手动配置只选择已有产物；rust-analyzer `debugSingle` 则保留 runnable 的 Cargo 参数，添加 JSON 输出，并为测试添加 `--no-run`，构建后调试可执行文件。Go adapter 会使用所选配置的 `cwd` 启动 Delve。

## 与其他模块的关系

- `lua/config/lsp.lua` 调用 `toolchain.setup()`，并负责 LSP 的缓冲区绑定、诊断、快捷键和支持的提示功能。
- `lua/plugins/formatter.lua` 使用 formatter 聚合结果和工具条件；当前仅配置手动格式化。
- `lua/plugins/linter.lua` 使用 linter 聚合结果，在读文件、写文件、离开插入模式时触发。
- `lua/plugins/highlight/treesitter.lua` 使用 parser 聚合结果，并在 parser 缺失时触发安装和重试。
- `lua/plugins/lsp/mason.lua` 使用 Mason 包聚合结果，在 Mason 注册表刷新后安装缺失包。
- `lua/sources/language.lua` 读取语言规格列表，不需要手动维护语言索引。
