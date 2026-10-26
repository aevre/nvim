# Toolchain Configuration

[English](toolchain.md) | [简体中文](toolchain.zh-CN.md)

[Back to the main documentation](../README.md) · [Features and troubleshooting](configuration.md)

`lua/toolchain` is the unified entry point for language and development tool configuration:

- `toolchain/lang/specs/*.lua` describes languages, filetypes, LSPs, Treesitter, and the formatter/linter names used by each language.
- `toolchain/format/specs/*.lua` and `toolchain/lint/specs/*.lua` describe tool conditions (`formatter` and `linter` fields respectively). `toolchain/specs.lua` automatically discovers `.lua` files in language, format, lint, and debug spec directories.
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
| `setup_debug(opts)` | Registers adapters/configurations and optional project provider. |
| `get_treesitter()` | Returns the parsers declared by language specifications and the filetypes used to start those parsers. |
| `get_language_by_filetype(ft)` | Merges the language specifications declaring that filetype; returns nil when none exists. |
| `get_mason_packages(ft)` | Returns the Mason package names corresponding to language tools and extra tools. |

Language specifications only describe the relationship between languages and tools; tool conditions, LSP startup arguments, and UI behavior are handled respectively by `format/specs/` / `lint/specs/`, `lsp/`, and plugin configuration.

## Directory Structure

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

The `.lua` files in the language and tool specification directories are scanned automatically. Do not put template Lua files, test files, or Lua files returning non-specification content in any `specs/` directory; malformed specifications fail with their source identified. Keep toolchain documentation in `docs/` and templates outside the specification directories or in Markdown files.

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
| `debug` | `(string|LanguageDebug)[]` | Adapter IDs or explicit language configurations. |
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

Neovim configuration Lua uses `lua_ls`. `.luarc.json` at the configuration root provides project settings such as globals and the LuaJIT environment. `lsp/lua_ls.lua` declares the startup command, filetypes, and root markers, and dynamically supplies workspace libraries from installed plugins' `lua` directories, the luv library, and `VIMRUNTIME`.

## Tool Specifications

Tool specifications handle each tool's own availability conditions. Using Prettier as an example:

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

`formatter.condition` is a Conform formatter condition. The formatter is available only when it returns `true`. Tool conditions do not decide whether a language uses the tool; the relationship between languages and tools is still declared by the `formatters` field in `toolchain/lang/specs/*.lua`.

Current optional formatter conditions:

- Prettier: takes effect only when a Prettier configuration file is found.
- Biome: takes effect only when `biome.json` or `biome.jsonc` is found.
- Oxfmt: takes effect when an Oxfmt configuration file is found; when the project has no Prettier, Biome, or Oxfmt configuration, it takes effect as the default fallback.

These conditions are located in:

```text
lua/toolchain/format/specs/prettier.lua
lua/toolchain/format/specs/biome.lua
lua/toolchain/format/specs/oxfmt.lua
```

Configuration detection searches upward from the current file's directory, with the home directory as the stop boundary, and only recognizes the filenames listed in each tool spec. It does not inspect `package.json` fields; unlisted names such as `.prettierrc.cjs` or `eslint.config.ts` are not recognized. An unrecognized Prettier configuration therefore does not prevent Oxfmt's fallback.

When changing CLI formatter configuration file detection rules, modify the corresponding tool specification. Do not write the condition logic back into `lua/plugins/formatter.lua`.

Linters follow the same rules. `linters` in a language specification only declares which linters the language uses; `linter.condition` in a tool specification decides whether that linter is enabled in the current project. The condition is executed by this configuration's linter callback based on the current file path before calling `lint.try_lint()`.

Current linters with project configuration conditions:

- ESLint: takes effect only when an ESLint configuration file is found.
- Oxlint: takes effect only when `.oxlintrc.json` is found.

These conditions are located in:

```text
lua/toolchain/lint/specs/eslint.lua
lua/toolchain/lint/specs/oxlint.lua
```

When changing linter configuration file detection rules, modify only the corresponding tool specification. Do not write the condition logic back into `lua/plugins/linter.lua`. The latter is responsible for merging configuration, filtering tools, and triggering linting.

These conditions apply to CLI formatters and linters. Same-named LSPs have separate root/configuration rules in `lsp/<name>.lua`; update those files too when changing both behaviors. For example, Oxlint LSP recognizes `oxlint.config.ts`, while the CLI condition only recognizes `.oxlintrc.json`; Oxfmt LSP does not share the formatter's no-configuration fallback.

Conform still uses the default behavior of the formatter list: if multiple formatter conditions are satisfied and `stop_after_first = true` is not set when calling it, Conform may execute multiple formatters in sequence. Tool specifications only decide whether a tool is available; they do not change this execution strategy.

Whether a formatter is installed is determined by the Mason package list, while whether a formatter is effective for the current project is determined by Conform's `condition`; these two decisions are independent. A formatter declared by a language specification does not mean that it will run in every project.

GraphQL and Handlebars currently have no formatter mapping. Luau uses `stylua` through its language specification. Zsh uses `shfmt` and the shared Bash language server; ShellCheck does not support zsh, so its native `zsh -n` syntax check is used instead.

## Current Language List

The table below lists the Conform formatter, CLI linter, and LSP declarations in the specifications; `—` in the formatter column means no Conform mapping. Manual formatting can still fall back to an attached LSP that supports formatting. These declarations remain subject to tool availability, the service's own filetype/root requirements, and installation conditions. The Web formatting combination means `prettier → biome → oxfmt`.

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
| java / java | — | — | jdtls (native LSP, isolated project workspace) |
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
5. If the tool needs a configuration file condition, add or modify the corresponding specification in `toolchain/format/specs/` or `toolchain/lint/specs/`.
6. For tools that Mason should install automatically, add explicit name mappings in `lua/toolchain/mason.lua`, even when the runtime and package names are identical.
7. Open a file in that language and verify LSP, formatting, linting, and Treesitter behavior.

Adding a language does not require modifying the language list or manually adding an fzf source; `<leader>cL` automatically displays the new language specification.

## Modifying Existing Configuration

- Change the relationship between a language and filetypes: modify `filetypes` in `toolchain/lang/specs/*.lua`.
- Change which tools a language uses: modify `formatters` or `linters` in the language specification.
- Change whether a formatter or linter is available: modify its `formatter` or `linter` field in `toolchain/format/specs/<tool>.lua` or `toolchain/lint/specs/<tool>.lua`.
- Change the LSP command, root, or settings: modify `lsp/<name>.lua`.
- Change the Treesitter parser/filetype: modify `treesitter` / `filetypes` in the language specification.
- Change the Treesitter startup, installation, and retry mechanism: modify `lua/plugins/highlight/treesitter.lua`.
- Add a formatter association: declare it in the language specification.

Do not write project paths into language or tool specifications; these specifications must be reusable across different workspaces.

## Mason Automatic Installation

After the Mason registry refresh at `VeryLazy`, open buffers and subsequent `FileType` events call `toolchain.get_mason_packages(ft)`. Installation is limited to mapped LSPs, formatters, linters and debug adapters for that filetype, plus auxiliary packages. Mason package names and runtime names may differ, for example:

| Runtime name | Mason package name |
| --- | --- |
| `rust_analyzer` | `rust-analyzer` |
| `clang_format` | `clang-format` |
| `golangcilint` | `golangci-lint` |
| `ruff_format` | `ruff` |

Name mappings are located in `lua/toolchain/mason.lua`. Every LSP, formatter, or linter that Mason should install automatically needs an explicit entry in this mapping, even when its runtime name matches the Mason package name. Unmapped tools are still declared for use, but are not added to the automatic installation list unless listed in `extra_packages`.

Debug adapter mappings are `delve -> delve`, `debugpy -> debugpy`, and `js-debug -> js-debug-adapter`. GDB has no Mason mapping. `require("toolchain").mason.extra_packages` is an empty list by default and can contain additional literal package names; those are included even for unknown filetypes. When a Mason registry refresh fails or a package does not exist, Mason itself reports the installation failure; this does not prevent language specifications from loading.

LSPs are enabled by `FileType`: when a name mapping exists, the package must first be installed in Mason; without a mapping, `is_installed()` directly returns true, after which availability still depends on whether the command is executable. After installation succeeds, already-open buffers' services are retried. `dartls` has no Mason mapping and requires the Dart SDK; `rustfmt` is also unmapped and should be prepared separately. ESLint has no package name mapping, so CLI linting requires the project or PATH to provide it. `bacon-ls` has an explicit Mason mapping. The zsh filetype shares the `bash-language-server` package mapping with bash.

Language filetypes trigger the first `vim.lsp.enable(name)` call; the server is then enabled globally. Its own filetypes and root rules determine later attachments. For example, opening Go first enables gopls, which can then attach to `gomod`, `gowork`, and `gotmpl` buffers even though those types are not in the Go language specification.

`lsp/emmylua.lua`, `lsp/nushell.lua`, and `lsp/stylua.lua` are not currently enabled by language specifications. Java uses native `vim.lsp` with layered multi-module/single-module roots, shared cache configuration, and a distinct hashed `-data` workspace per absolute project root. `JDTLS_JVM_ARGS` is forwarded as space-separated `--jvm-arg` values. `nvim-jdtls` is not installed; java-debug/vscode-java-test bundles and their Java-specific commands are not configured.

## Debugging

Debug specs in `lua/toolchain/debug/specs/*.lua` define an adapter table or factory, configurations, and optional DAP `type` (defaults to spec filename). Language `debug` accepts adapter ID strings or `{ adapter, defaults = false, configurations }`; defaults append unless disabled, and explicit configs append/replace accordingly. C, C++, and Rust share GDB.

`setup_debug(opts)` preserves native entries and is idempotent; `{ override = true }` overrides conflicts. `{ launch_json = false }` restores the previous provider, including the native current-working-directory provider. User-supplied providers are preserved by default. It reads nearest `.vscode/launch.json` per request, expands workspace variables, aliases `node` to `pwa-node`, and accepts both the standard `python`/`go` types and the legacy internal `debugpy`/`delve` names; it does not implement VS Code tasks/extensions or browser defaults. Toolchain prompts abort on empty/canceled input. Native launch.json inputs retain nvim-dap behavior: canceled prompts are not consistently converted to `dap.ABORT`. VS Code command variables, compounds, tasks and extension-specific launch fields are not implemented.

GDB 14.1+ with Python/DAP support is required from the system, not Mason. GDB version validation and debugpy import validation are bounded by 3 seconds; missing or invalid adapters raise a clear error instead of leaving an asynchronous callback pending. Python chooses active `VIRTUAL_ENV`/`CONDA_PREFIX`, then project `.venv`/`venv`/`.env`/`env`, then system Python. Launch configurations also load the project `.env` file unless `envFile` overrides it. JS uses command wrappers or project `@vscode/js-debug`; TypeScript prompts for compiled JS. Jest file/test-name configurations require project-local Jest. Vue supports attach only; start npm/pnpm inspector scripts manually. Rust-analyzer's `debugSingle` builds the selected Cargo runnable with JSON output and launches the resulting executable through GDB.

Mason derives packages per filetype from language maps; `extra_packages` defaults to empty. Only `nvim-dap` and `nvim-dap-view` plugins are added; no test-result or coverage framework is implemented.

The debug mappings include `<leader>dc` continue/start, `dl` run last, `dp` pause, `dr` restart, `dt` terminate, `db` breakpoint, `dB` conditional breakpoint, `di` step into, `do` step over, `dO` step out, `dg` run to cursor, `du` toggle UI, `de` REPL, and `dh` hover.

### Declarations and extension

```lua
-- lang/specs/go.lua
return { filetypes = { "go" }, debug = { "delve" } }

-- Append a language-specific configuration; use defaults = false to replace.
return {
    filetypes = { "c" },
    debug = {
        { adapter = "gdb", configurations = {
            { name = "My binary", request = "launch", program = "/path/to/build/app" },
        } },
    },
}
```

Adapter IDs and DAP types are distinct: the `js-debug` spec registers `pwa-node`. Each adapter is registered once; configurations are copied independently for each filetype. A language can list multiple adapters. Languages without `debug` do not receive automatic configurations.

To add an adapter, create `debug/specs/<id>.lua` returning `adapter` (a native executable/server/pipe table or callback factory), `configurations` (a list), and optional `type`. Add its ID to language `debug` declarations and an explicit Mason mapping if installation is desired. No index update is needed. Add languages through `lang/specs/` as before, with an optional `debug` field.

Formatter specs return `FormatSpec` with a `formatter` override; linter specs return `LintSpec` with a `linter` override. Their existing conditions and language associations are unchanged. Tools with suitable built-in Conform/nvim-lint behavior need no override spec.

### Manual and mixed configuration

```lua
local dap = require("dap")
dap.adapters.custom = { type = "executable", command = "custom-dap" }
dap.configurations.c = {
    { name = "Custom", type = "custom", request = "launch", program = "/path/to/app" },
}
require("toolchain").setup_debug() -- retains these and appends defaults
-- vim.list_extend(dap.configurations.c, { another_config }) appends explicitly.
-- Assign dap.configurations.c = {...} after setup to replace that filetype.
-- require("toolchain").setup_debug({ override = true }) replaces declared defaults/conflicts.
```

Existing manual entries remain first; exact duplicate configurations are not appended. Distinct configurations sharing a display name remain distinct. Toolchain-owned configurations are refreshed on repeated setup; edit language declarations or add native entries to customize them persistently. User adapter/provider entries take priority unless `override = true` is explicit. `setup_debug` does not wrap DAP session operations.

### Initial support and limits

| Language | Adapter | Configurations |
| --- | --- | --- |
| C / C++ | GDB | Select executable, attach process, select a built CTest command |
| Rust | GDB | Shared defaults, manual Cargo artifact selection, rust-analyzer `debugSingle` build |
| Go | Delve | Package, current file, package tests, current test, local process attach |
| Python | debugpy | Current file, file with arguments, module, doctest, dynamic host/port attach |
| JavaScript / TypeScript, including React filetypes | vscode-js-debug | Node launch/attach, source maps, Jest file/test-name launch |
| Vue / Nuxt | vscode-js-debug | Node Inspector attach only |

GDB is the common Linux default for C/C++/Rust; LLDB can offer better macOS integration and Rust visualizers but needs a separate adapter spec. Compile native artifacts with debug symbols. The manual Cargo configuration selects existing metadata artifacts; rust-analyzer `debugSingle` instead builds its runnable and parses Cargo `compiler-artifact` JSON, but does not load Rust pretty printers. CTest discovery reads `ctest --show-only=json-v1` and launches the selected command directly, so it does not reproduce CTest fixtures, dependencies, or environment properties. Go current-file debugging only works for self-contained files; package tests run the package rather than discovering individual tests. Attach depends on OS permissions and adapter capabilities.

Node attach prompts for the Inspector port (default 9229). Start the server with an appropriate `node --inspect` command or npm/pnpm script first. Nearest `package.json` determines package cwd in a monorepo; specify project cwd/env/args/runtime in launch.json where needed. Jest launch searches upward for `node_modules/jest/bin/jest.js`, runs the current saved file, and optionally accepts a test-name regular expression; `<leader>dl` repeats the last selection. TypeScript breakpoint accuracy still depends on the project's transform/source-map setup. JSX is not transpiled automatically. Vue SFCs are never launched as Node files; browser debugging is not configured.

The Python adapter process and target interpreter are separate: a Mason `debugpy-adapter` can debug a project's selected Python. Interpreter choice is active `VIRTUAL_ENV`/`CONDA_PREFIX`, project `.venv`/`venv`/`.env`/`env`, then PATH Python; override `pythonPath` or `python` for other environments. Program and module arguments use the shared DAP argument parser, which accepts empty input and preserves quoted values. Local JS discovery accepts an existing built `node_modules/@vscode/js-debug/src/dapDebugServer.js`; it does not build source checkouts. Mason's exported wrapper is preferred over internal package paths.

The launch.json provider reloads on every new selection, without mutating `dap.configurations`. It uses the nearest ancestor containing `.vscode` and leaves configuration selection to nvim-dap. Workspace variables resolve to that directory; other native DAP variables remain native. It does not infer adapter types from display names, execute preLaunchTask, or supply remote path mappings. Users must provide adapter-compatible fields, environment, arguments and compiled paths.

Default Go launch configurations set `outputMode = "remote"` to forward stdout/stderr through DAP; add this field to custom Go launch.json entries to see output in REPL. Attach does not capture an existing process's output. The UI defaults to REPL so adapter output events are visible as they arrive; programs requesting a separate terminal use dap-view's terminal window. With focus in the debug window, press `R` for REPL output, `S` for scopes, or `W` for watches. UI opens/closes through dap-view's native `auto_toggle = true`, with its last-session close guard; manual toggle uses `<leader>du`. Listener keys are managed by the plugin and do not accumulate on setup.

## Verification

```sh
stylua --check lua/toolchain lua/plugins/highlight/treesitter.lua lua/sources/language.lua
git diff --check
nvim --headless -u NONE -l tests/language_debug.lua
```

A live Go/C session uses the actual harness environment, for example:

```sh
TOOLCHAIN_DEBUG_LANGUAGE=go \
TOOLCHAIN_DEBUG_SOURCE=/path/to/main.go \
TOOLCHAIN_DEBUG_PROGRAM=/path/to/go/package \
TOOLCHAIN_DEBUG_LINE=5 \
nvim --headless -u NONE -l tests/debug_session.lua
```

Check specification loading and aggregation:

```sh
nvim --headless -u NONE \
  '+lua vim.opt.rtp:prepend(vim.fn.stdpath("config"))' \
  '+lua local tc=require("toolchain"); assert(#tc.lang.source_items() > 0); assert(tc.get_formatter_configs().prettier); print("toolchain specs passed")' \
  '+qa!'
```

`<leader>cL` displays language names and filetypes; the preview displays the language specification source, and the default selection directly opens the corresponding `toolchain/lang/specs/<language-name>.lua` file.

`tests/language_debug.lua` checks Jest resolution/cancellation, CTest JSON command mapping, JDTLS workspace isolation, Rust Cargo JSON artifact conversion, and preservation of callable configurations through toolchain aggregation. The actual Go Package, Current File, Package Tests, C GDB and Rust GDB sessions previously passed full breakpoint, continue, termination, and dap-view UI lifecycle checks. debugpy, js-debug-adapter, JDTLS, and representative Jest/CTest projects were unavailable, so the new integrations have not been exercised in live sessions.

The manual Rust Cargo configuration still invokes `cargo metadata --no-deps --format-version 1` with a 3-second timeout and selects an existing artifact. The rust-analyzer `debugSingle` handler uses the runnable's exact Cargo arguments, adds JSON output and `--no-run` for tests, then launches the produced executable. The Go adapter starts Delve with the selected configuration's `cwd`.

## Relationship with Other Modules

- `lua/config/lsp.lua` calls `toolchain.setup()` and handles LSP buffer attachment, diagnostics, keymaps, and supported hint features.
- `lua/plugins/formatter.lua` uses the formatter aggregate results and tool conditions; it currently configures only manual formatting.
- `lua/plugins/linter.lua` uses the linter aggregate results and triggers linting when reading files, writing files, and leaving insert mode.
- `lua/plugins/highlight/treesitter.lua` uses the parser aggregate results and triggers installation and retries when a parser is missing.
- `lua/plugins/lsp/mason.lua` uses the Mason package aggregate results and installs missing packages after the Mason registry refreshes.
- `lua/sources/language.lua` reads the language specification list and does not need to maintain a language index manually.
