# Toolchain 配置

[English](toolchain.md) | [简体中文](toolchain.zh-CN.md)

[返回主文档](../README.zh-CN.md) · [功能与排错](configuration.zh-CN.md)

`lua/toolchain` 是语言和开发工具配置的统一入口：

- `toolchain/lang/specs/*.lua` 描述语言、filetype、LSP、Treesitter，以及该语言使用的 formatter/linter 名称。
- `toolchain/tool/specs/*.lua` 描述工具自己的可用条件和 Conform 配置，例如项目中是否存在该工具的配置文件。
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
| `get_mason_packages()` | 返回语言工具和额外工具对应的 Mason 包名。 |

语言规格只描述语言与工具的关系；工具条件、LSP 启动参数和 UI 行为分别由
对应的 `tool/specs/`、`lsp/` 和插件配置负责。

## 目录结构

```text
lua/toolchain/
├── init.lua
├── mason.lua
├── lang/
│   ├── init.lua
│   └── specs/
│       ├── lua.lua
│       ├── python.lua
│       └── ...
└── tool/
    ├── init.lua
    └── specs/
        ├── prettier.lua
        ├── biome.lua
        └── oxfmt.lua
```

语言和工具规格目录中的每个 `.lua` 文件都会被自动扫描。不要在这两个
`specs/` 目录中放置模板 Lua 文件、测试文件或返回非规格内容的 Lua 文件，
否则启动时会被当作配置加载并产生警告。工具链文档放在 `docs/`，
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

---@type ToolSpec
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
lua/toolchain/tool/specs/prettier.lua
lua/toolchain/tool/specs/biome.lua
lua/toolchain/tool/specs/oxfmt.lua
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
lua/toolchain/tool/specs/eslint.lua
lua/toolchain/tool/specs/oxlint.lua
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
| java / java | — | — | jdtls（仅声明命令） |
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

Parser 声明为 bash、zsh、c、cpp、go、java、javascript、json、kotlin、lua、
markdown/markdown_inline、nix、python、rust、toml、typescript/tsx、vue/css/scss、
xml、yaml。CSS、Dart、HTML、Luau、Nu、QML、SQL 规格没有 `treesitter` 字段。

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
5. 如果工具需要配置文件条件，在 `toolchain/tool/specs/` 中新增或修改对应工具规格。
6. 需要 Mason 自动安装的工具，在 `lua/toolchain/mason.lua` 中添加显式名称映射，即使运行时名称与包名相同也要登记。
7. 打开该语言文件，确认 LSP、格式化、lint 和 Treesitter 行为。

新增语言不需要修改语言列表，也不需要手动加入 fzf source；`<leader>cL`
会自动显示新语言规格。

## 修改已有配置

- 改变语言与 filetype 的关系：修改 `toolchain/lang/specs/*.lua` 的 `filetypes`。
- 改变语言使用哪些工具：修改语言规格的 `formatters` 或 `linters`。
- 改变工具是否可用：修改 `toolchain/tool/specs/<tool>.lua` 的条件。
- 改变 LSP 命令、root 或 settings：修改 `lsp/<名称>.lua`。
- 改变 Treesitter parser/filetype：修改语言规格的 `treesitter` / `filetypes`。
- 改变 Treesitter 启动、安装与重试机制：修改 `lua/plugins/highlight/treesitter.lua`。
- 添加 formatter 关联：在语言规格的 `formatters` 中声明。

不要把项目路径写入语言或工具规格；这些规格必须能复用在不同工作区。

## Mason 自动安装

`VeryLazy` 阶段的 Mason registry 回调会调用 `toolchain.get_mason_packages()`，
根据当前语言规格中实际声明且有名称映射的 LSP、formatter 和 linter 安装对应包。
这不是仅针对当前已打开语言的安装列表。Mason 包名与运行时
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

调试适配器和通用辅助工具仍在 `extra_packages` 中维护，不会因为当前语言
没有打开而被移除。Mason 注册表刷新失败或包不存在时，安装动作由 Mason
自身报告失败，不会阻止语言规格加载。

LSP 则按 `FileType` 启用：有名称映射时，必须先在 Mason 中安装；无映射时
`is_installed()` 直接返回 true，后续仍取决于命令是否可执行。安装成功后会
重试已打开 buffer 的服务。`dartls` 无 Mason 映射，需要 Dart SDK；`rustfmt`
也未映射，应自行准备。ESLint 没有包名映射，CLI lint 需要项目或 PATH 提供。
`bacon-ls` 没有名称映射，但已列入额外安装清单。zsh filetype 与 bash 共用
`bash-language-server` 的 Mason 包映射。

语言规格的 filetype 触发首次 `vim.lsp.enable(name)`，随后该服务全局启用，
后续附着范围由服务自己的 filetypes 和 root 规则决定。例如先打开 Go 文件启用
gopls 后，它还可附着到 `gomod`、`gowork`、`gotmpl` buffer，尽管 Go 语言规格
未列出这些类型。

`lsp/emmylua.lua`、`lsp/nushell.lua`、`lsp/stylua.lua` 当前没有被语言规格启用。
Java 声明了 `jdtls`，其配置仅为 `cmd = "jdtls"`，没有项目 workspace 或调试集成。

## 验证

```sh
stylua --check lua/toolchain lua/plugins/highlight/treesitter.lua lua/sources/language.lua
git diff --check
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

## 与其他模块的关系

- `lua/config/lsp.lua` 调用 `toolchain.setup()`，并负责 LSP 的缓冲区绑定、诊断、快捷键和支持的提示功能。
- `lua/plugins/formatter.lua` 使用 formatter 聚合结果和工具条件；当前仅配置手动格式化。
- `lua/plugins/linter.lua` 使用 linter 聚合结果，在读文件、写文件、离开插入模式时触发。
- `lua/plugins/highlight/treesitter.lua` 使用 parser 聚合结果，并在 parser 缺失时触发安装和重试。
- `lua/plugins/lsp/mason.lua` 使用 Mason 包聚合结果，在 Mason 注册表刷新后安装缺失包。
- `lua/sources/language.lua` 读取语言规格列表，不需要手动维护语言索引。
