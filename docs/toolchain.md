# Toolchain Configuration

[English](toolchain.md) | [简体中文](toolchain.zh-CN.md)

[Back to the main documentation](../README.md) · [Features and troubleshooting](configuration.md)

`lua/toolchain` is the unified entry point for language and development tool configuration:

- `toolchain/lang/specs/*.lua` describes languages, filetypes, LSPs, Treesitter, and the formatter/linter names used by each language.
- `toolchain/tool/specs/*.lua` describes the availability conditions and Conform configuration for each tool, such as whether the tool's configuration file exists in the project.
- `toolchain/mason.lua` maps LSP, formatter, and linter names to Mason package names, while also keeping debugging and auxiliary tools.
- `toolchain/init.lua` aggregates these configurations for use by LSP, Conform, nvim-lint, Mason, Treesitter, and the fzf source.

The public entry point is provided by `require("toolchain")`:

| Method | Return value |
| --- | --- |
| `setup()` | Registers an autocommand that lazily enables LSP by `FileType`. |
| `get_formatters()` | Aggregates `filetype -> formatter[]` from language specifications. |
| `get_formatter_configs()` | Returns the Conform formatter conditions provided by tool specifications. |
| `get_linters()` | Aggregates `filetype -> linter[]` from language specifications. |
| `get_linter_configs()` | Returns the nvim-lint linter conditions provided by tool specifications. |
| `get_treesitter()` | Returns the parsers declared by language specifications and the filetypes used to start those parsers. |
| `get_language_by_filetype(ft)` | Merges the language specifications declaring that filetype; returns nil when none exists. |
| `get_mason_packages()` | Returns the Mason package names corresponding to language tools and extra tools. |

Language specifications only describe the relationship between languages and tools; tool conditions, LSP startup arguments, and UI behavior are handled respectively by `tool/specs/`, `lsp/`, and plugin configuration.

## Directory Structure

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

The `.lua` files in the language and tool specification directories are scanned automatically. Do not put template Lua files, test files, or Lua files returning non-specification content in these two `specs/` directories, or they will be loaded as configuration at startup and produce warnings. Keep toolchain documentation in `docs/` and templates outside the specification directories or in Markdown files.

## Language Specifications

For example, `lua/toolchain/lang/specs/zig.lua`:

```lua
---@type LanguageSpec
return {
	filetypes = { "zig" },
	formatters = { "zigfmt" },
	lsp = { "zls" },
	treesitter = { "zig" },
}
```

`filetypes` is a required, non-empty array of strings. It must contain the actual `vim.bo.filetype` used by Neovim, not the file extension. For example, React files use `javascriptreact` or `typescriptreact`.

Supported fields:

| Field | Type | Purpose |
| --- | --- | --- |
| `filetypes` | `string[]` | The Neovim filetype corresponding to the language; required. |
| `formatters` | `string[]` | The Conform formatter names for the language. |
| `linters` | `string[]` | The nvim-lint linter names for the language. |
| `lint_filetypes` | `string[]` | The filetypes on which linting actually runs; uses `filetypes` when omitted. |
| `lsp` | `string[]` | The LSP names to enable on demand when opening the corresponding filetype. |
| `treesitter` | `string[]` | The Treesitter parser names to install and enable. |

Use the array form even when there is only one value, such as `{ "stylua" }`. When multiple language specifications declare the same filetype, formatter, linter, LSP, and Treesitter aggregate queries deduplicate the results.

The Treesitter plugin obtains the filetype list from the specifications and registers `FileType` callbacks for these types. It first tries to start an existing parser, then installs the parser declared by that language specification if startup fails. There is currently no additional base parser list, and all language parsers are not installed at startup in one batch. `typescriptreact` and `markdown.mdx` are filetypes and are not used directly as parser names in specifications.

The plugin loads at `BufReadPre`, `BufNewFile`, or `VeryLazy`. After installation, it retries startup every 100ms and reports failure after 300 attempts. On success, it enables Treesitter indentation and folding expressions for visible windows. Languages without a `treesitter` field do not enter this automatic startup list.

The concrete LSP commands, roots, settings, and special behavior remain in the top-level `lsp/` directory:

```text
lsp/pyright.lua
lsp/ruff.lua
```

Language specifications only decide which languages use an LSP; modify the corresponding `lsp/<name>.lua` file when changing LSP implementation details.

Neovim configuration Lua uses `lua_ls`. Its `vim` global, Neovim runtime, configuration directory, and LuaJIT environment are written in `.luarc.json` at the configuration root; do not copy these workspace library settings into `lsp/lua_ls.lua`. The latter only declares the startup command, filetypes, and project root markers.

## Tool Specifications

Tool specifications handle each tool's own availability conditions. Using Prettier as an example:

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

`formatter.condition` is a Conform formatter condition. The formatter is available only when it returns `true`. Tool conditions do not decide whether a language uses the tool; the relationship between languages and tools is still declared by the `formatters` field in `toolchain/lang/specs/*.lua`.

Current optional formatter conditions:

- Prettier: takes effect only when a Prettier configuration file is found.
- Biome: takes effect only when `biome.json` or `biome.jsonc` is found.
- Oxfmt: takes effect when an Oxfmt configuration file is found; when the project has no Prettier, Biome, or Oxfmt configuration, it takes effect as the default fallback.

These conditions are located in:

```text
lua/toolchain/tool/specs/prettier.lua
lua/toolchain/tool/specs/biome.lua
lua/toolchain/tool/specs/oxfmt.lua
```

When changing tool configuration file detection rules, modify only the corresponding tool specification. Do not write the condition logic back into `lua/plugins/formatter.lua`.

Linters follow the same rules. `linters` in a language specification only declares which linters the language uses; `linter.condition` in a tool specification decides whether that linter is enabled in the current project. The condition is executed by this configuration's linter callback based on the current file path before calling `lint.try_lint()`.

Current linters with project configuration conditions:

- ESLint: takes effect only when an ESLint configuration file is found.
- Oxlint: takes effect only when `.oxlintrc.json` is found.

These conditions are located in:

```text
lua/toolchain/tool/specs/eslint.lua
lua/toolchain/tool/specs/oxlint.lua
```

When changing linter configuration file detection rules, modify only the corresponding tool specification. Do not write the condition logic back into `lua/plugins/linter.lua`. The latter is responsible for merging configuration, filtering tools, and triggering linting.

Conform still uses the default behavior of the formatter list: if multiple formatter conditions are satisfied and `stop_after_first = true` is not set when calling it, Conform may execute multiple formatters in sequence. Tool specifications only decide whether a tool is available; they do not change this execution strategy.

Whether a formatter is installed is determined by the Mason package list, while whether a formatter is effective for the current project is determined by Conform's `condition`; these two decisions are independent. A formatter declared by a language specification does not mean that it will run in every project.

GraphQL and Handlebars currently have no formatter mapping. Luau uses `stylua` through its language specification. Zsh uses `shfmt` and the shared Bash language server; ShellCheck does not support zsh, so its native `zsh -n` syntax check is used instead.

## Current Language List

The table below lists the formatter, CLI linter, and LSP declarations in the specifications; declarations remain subject to tool availability, the service's own filetype/root requirements, and installation conditions. The Web formatting combination means `prettier → biome → oxfmt`.

| Specification / filetype | Formatter | CLI linter | LSP |
| --- | --- | --- | --- |
| bash / bash, sh | shfmt | shellcheck | bash-language-server |
| zsh / zsh | shfmt | zsh (`zsh -n`) | bash-language-server (shared) |
| c / c | clang_format | — | clangd |
| cpp / cpp | clang_format | — | clangd |
| css / css, scss, less | Web combination | — | css-lsp, css-variables-language-server, emmet-language-server, stylelint-language-server, tailwindcss, biome, oxfmt |
| dart / dart | — | — | dartls |
| go / go | goimports, gofumpt | golangcilint | gopls |
| html / html | Web combination | — | html, emmet-language-server, stylelint-language-server, tailwindcss, biome, oxfmt |
| java / java | — | — | jdtls (declaration only) |
| javascript / javascript, javascriptreact | Web combination | eslint, oxlint (javascript only) | vtsls, biome, oxlint, cssmodules-language-server, oxfmt |
| json / json, jsonc | Web combination | — | jsonls, biome, oxfmt |
| kotlin / kotlin | — | — | kotlin-lsp |
| lua / lua | stylua | selene | lua_ls |
| luau / luau | stylua | — | luau-lsp |
| markdown / markdown, markdown.mdx | Web combination | — | tailwindcss, oxfmt |
| nix / nix | nixfmt | — | rnix |
| nu / nu | — | — | — (nushell declaration is commented out) |
| python / python | ruff_format, isort, yapf | — | pyright, ruff |
| qml / qml, qmljs | — | — | qmlls |
| rust / rust | rustfmt | — | rust_analyzer, bacon-ls |
| sql / sql | sqruff | — | — |
| toml / toml | taplo | — | tombi |
| typescript / typescript, typescriptreact | Web combination | eslint, oxlint (typescript only) | vtsls, biome, oxlint, oxfmt |
| vue / vue | Web combination | eslint, oxlint | vue_ls, vtsls, stylelint-language-server, tailwindcss, biome, oxfmt |
| xml / xml, svg | xmlformatter | — | — |
| yaml / yaml | Web combination | — | — |

Parser declarations are bash, zsh, c, cpp, go, java, javascript, json, kotlin, lua, markdown/markdown_inline, nix, python, rust, toml, typescript/tsx, vue/css/scss, xml, and yaml. The CSS, Dart, HTML, Luau, Nu, QML, and SQL specifications have no `treesitter` field.

## Lint Rules

If some filetypes should not run linting, use `lint_filetypes`, for example:

```lua
filetypes = { "typescript", "typescriptreact" },
linters = { "eslint", "oxlint" },
lint_filetypes = { "typescript" },
```

This is how the JavaScript/TypeScript configuration excludes the React filetype. Do not remove React types from `filetypes`, or that would also affect LSP and formatter behavior.

## Adding a Language

Using the addition of Zig as an example:

1. Confirm that Neovim's filetype is `zig`.
2. Create `lua/toolchain/lang/specs/zig.lua` with at least `filetypes`.
3. Add `formatters`, `linters`, `lsp`, and `treesitter` as needed.
4. If the LSP name has no corresponding `lsp/<name>.lua`, create that file.
5. If the tool needs a configuration file condition, add or modify the corresponding tool specification in `toolchain/tool/specs/`.
6. Open a file in that language and verify LSP, formatting, linting, and Treesitter behavior.

Adding a language does not require modifying the language list or manually adding an fzf source; `<leader>cL` automatically displays the new language specification.

## Modifying Existing Configuration

- Change the relationship between a language and filetypes: modify `filetypes` in `toolchain/lang/specs/*.lua`.
- Change which tools a language uses: modify `formatters` or `linters` in the language specification.
- Change whether a tool is available: modify the condition in `toolchain/tool/specs/<tool>.lua`.
- Change the LSP command, root, or settings: modify `lsp/<name>.lua`.
- Change the Treesitter parser/filetype: modify `treesitter` / `filetypes` in the language specification.
- Change the Treesitter startup, installation, and retry mechanism: modify `lua/plugins/highlight/treesitter.lua`.
- Add a formatter association: declare it in the language specification.

Do not write project paths into language or tool specifications; these specifications must be reusable across different workspaces.

## Mason Automatic Installation

The Mason registry callback at the `VeryLazy` stage calls `toolchain.get_mason_packages()` and installs the corresponding packages for LSPs, formatters, and linters that are actually declared in the current language specifications and have name mappings. This is not an installation list limited to currently open languages. Mason package names and runtime names may differ, for example:

| Runtime name | Mason package name |
| --- | --- |
| `rust_analyzer` | `rust-analyzer` |
| `clang_format` | `clang-format` |
| `golangcilint` | `golangci-lint` |
| `ruff_format` | `ruff` |

Name mappings are located in `lua/toolchain/mason.lua`. When adding an LSP, formatter, or linter, if it does not use the same Mason package name, add it to this mapping; otherwise it will continue to be used by the configuration, but Mason will not install it automatically.

Debug adapters and general auxiliary tools remain maintained in `extra_packages` and are not removed because the current language is not open. When a Mason registry refresh fails or a package does not exist, Mason itself reports the installation failure; this does not prevent language specifications from loading.

LSPs are enabled by `FileType`: when a name mapping exists, the package must first be installed in Mason; without a mapping, `is_installed()` directly returns true, after which availability still depends on whether the command is executable. After installation succeeds, already-open buffers' services are retried. `dartls` has no Mason mapping and requires the Dart SDK; `rustfmt` is also unmapped and should be prepared separately. ESLint has no package name mapping, so CLI linting requires the project or PATH to provide it. `bacon-ls` has no name mapping but is included in the extra installation list. The zsh filetype shares the `bash-language-server` package mapping with bash.

`lsp/emmylua.lua`, `lsp/nushell.lua`, and `lsp/stylua.lua` are not currently enabled by language specifications. Java declares `jdtls`, whose configuration is only `cmd = "jdtls"`; it has no project workspace or debugging integration.

## Verification

```sh
stylua --check lua/toolchain lua/plugins/highlight/treesitter.lua lua/sources/language.lua
git diff --check
```

Check specification loading and aggregation:

```sh
nvim --headless -u NONE \
  '+lua vim.opt.rtp:prepend(vim.fn.stdpath("config"))' \
  '+lua local tc=require("toolchain"); assert(#tc.lang.source_items() > 0); assert(tc.get_formatter_configs().prettier); print("toolchain specs passed")' \
  '+qa!'
```

`<leader>cL` displays language names and filetypes; the preview displays the language specification source, and the default selection directly opens the corresponding `toolchain/lang/specs/<language-name>.lua` file.

## Relationship with Other Modules

- `lua/config/lsp.lua` calls `toolchain.setup()` and handles LSP buffer attachment, progress events, and keymaps.
- `lua/plugins/formatter.lua` uses the formatter aggregate results and tool conditions; it currently configures only manual formatting.
- `lua/plugins/linter.lua` uses the linter aggregate results and triggers linting when reading files, writing files, and leaving insert mode.
- `lua/plugins/highlight/treesitter.lua` uses the parser aggregate results and triggers installation and retries when a parser is missing.
- `lua/plugins/lsp/mason.lua` uses the Mason package aggregate results and installs missing packages after the Mason registry refreshes.
- `lua/sources/language.lua` reads the language specification list and does not need to maintain a language index manually.
