# Features, Dependencies, and Troubleshooting

[English](configuration.md) | [简体中文](configuration.zh-CN.md)

[Back to README](../README.md) · [Keymaps](keymaps.md) · [Toolchain](toolchain.md)

## Plugin Loading and Features

Lazy imports `plugins` and the `coding`, `colorschemes`, `deps`, `editor`, `highlight`, `lsp`, `qol`, and `ui` categories. Use `:Lazy` to view plugin status.

| Feature | Current implementation and trigger |
| --- | --- |
| Search | fzf-lua loads at startup and provides file, grep, Git, LSP, and custom sources |
| File browsing | Oil loads at startup and takes over as the default explorer; mini.files is triggered by `<leader>e`; Oil diagnostics and Git extensions load for the `oil` filetype |
| Completion | blink.cmp loads on `InsertEnter` / `CmdlineEnter`, using LSP, LuaSnip, path, buffer, ripgrep, and Minuet sources |
| Snippets | LuaSnip + friendly-snippets, plus Lua snippets from `snippets/` |
| Editing | blink.pairs, mini.ai/jump/move/splitjoin/surround, ts-comments, and ts-autotag mostly load on `BufEdit`; Dial provides increment/decrement operations |
| Navigation | Flash loads on `VeryLazy`; Treesitter textobjects load on `BufEdit` |
| Formatting and linting | Conform and nvim-lint load on `BufEdit`, with tool associations supplied by toolchain |
| Git | mini.git and mini.diff load on `BufEdit`; CodeDiff loads through commands/keymaps; Lazygit uses a local terminal wrapper |
| Outline and documentation comments | Aerial loads through `<leader>cs`; Neogen loads through commands/keymaps |
| Sessions | session.nvim loads on `BufReadPre`; autosave is enabled, automatic restoration and saving on session switch are disabled; keymaps restore, select, or save sessions |
| Search and replace | grug-far loads through commands/keymaps |
| UI | Alpha loads on `VimEnter`, Heirline on `UIEnter`; Incline, indent guides, and Treesitter context load on `BufEdit` |
| Messages and diagnostics | cmdline.nvim and notify.nvim load at startup for command-line/message UI and notifications; notify.nvim also handles LSP progress; tiny-inline-diagnostic loads on `LspAttach` and disables native virtual text |
| Other | Which-key loads on `VeryLazy`; Yanky and Screenkey are triggered by keymaps; WakaTime loads on `BufEdit` |
| HTTP | nvim-http-client loads through `VeryLazy`, `http/rest`, or keymaps; it searches upward for `http-client.env.json` |
| AI | Minuet and llm.nvim are both configured to load on `BufEdit`; Minuet is also a dependency of blink.cmp |

Explicitly disabled specs: persistence.nvim, noice.nvim, nvim-notify, refactoring.nvim, mini.pairs, rainbow-delimiters.nvim, tiny-cmdline.nvim, transparent.nvim, mini.clue, neoscroll.nvim, snacks.nvim, and treesitter-parser-registry. `lspconfig.lua` returns an empty table; LSP is currently configured without the nvim-lspconfig plugin. Transparency comes from the local theme module and is unrelated to the disabled transparent.nvim.

cmdline.nvim enables the command-line popup, message/search notification views, and the NUI popup menu. notify.nvim routes matching save confirmations (`saved …`, `written`, or `已写入`) to its Fidget view; other `vim.notify()` and `msg.show.*` messages go to regular notifications. `<leader>n` opens notification history and `<leader>fn` opens Fidget history. `NVIM_PLUGIN_MODE=dev` also enables notify.nvim debug output.

## Actual Toolchain Behavior

LSP uses `lsp/<name>.lua` and `vim.lsp.enable()`. Language specs are read when a filetype is opened. Servers with a Mason name mapping are enabled only if the corresponding Mason package is installed; names without a mapping pass this check directly. Having a server with the same name in PATH does not bypass the Mason requirement for mapped servers. Servers must also meet their own filetype, root, and command requirements.

Mason refreshes its registry and installs missing packages on `VeryLazy`; after a successful installation, it retries LSP for buffers that are already open. The current custom `config` uses the Mason registry directly and does not call mason-lspconfig's `setup()`. Java uses native `vim.lsp` with multi-module/single-module root markers, shared JDTLS cache configuration, and a distinct hashed `-data` workspace per project. `JDTLS_JVM_ARGS` accepts space-separated JVM arguments. `nvim-jdtls` is not installed; Java debugging, test discovery, classfile buffers, and extended refactorings require separate java-debug/vscode-java-test integration.

Conform's `<leader>cf` formats asynchronously, with a default timeout configured to 3000ms and LSP fallback allowed. No `format_on_save` is configured. Web formatters are filtered for availability and run in their declared order, `prettier → biome → oxfmt`; this is not a strict choice of just one of the three. Python similarly declares `ruff_format → isort → yapf`, and Go declares `goimports → gofumpt`.

nvim-lint registers callbacks with a 100ms debounce on `BufReadPost`, `BufWritePost`, and `InsertLeave`. ESLint and Oxlint must satisfy the configuration file requirements in their tool specs. The React filetypes for JavaScript/TypeScript are excluded from these two CLI lint mappings, though LSP may still provide diagnostics.

Treesitter uses the `main` branch and loads on `BufReadPre`, `BufNewFile`, or `VeryLazy`. Startup callbacks are registered only for filetypes whose language specs declare `treesitter`. It first attempts to start an existing parser; if that fails, it requests installation of the corresponding parser and retries every 100ms, reporting failure after 300 attempts. On success, it sets Treesitter indentation and the fold expression for currently visible windows. Standalone CSS and HTML files do not start Treesitter automatically. The Vue spec additionally declares CSS/SCSS parsers.

Debugging uses the toolchain's DAP specs and adds only `nvim-dap` plus `nvim-dap-view`; GDB 14.1+ is provided by the system, while Delve, debugpy, and JS debug adapter packages are selected per filetype. See [Toolchain Configuration](toolchain.md#debugging) for adapter behavior, launch.json support, limitations, and tests.

## Integrations You Need to Prepare Yourself

| Tool or configuration | Use case |
| --- | --- |
| `lazygit` | `<leader>gg` |
| `rmpc` | `<leader>tm` music terminal |
| `zoxide` | fzf's directory history entry |
| `gh` and GitHub authentication | GitHub issue / PR queries |
| `curl` | External requests required by HTTP/API plugins |
| `rustfmt` | Rust formatting; currently has no Mason name mapping and is usually installed through rustup |
| Dart SDK | `dartls` invokes `dart language-server`; no Mason mapping |
| Qt/QML environment | `qmlls` and the Qt tools required by the project |
| Input method commands | The non-Windows branch checks `fcitx5-remote`, `fcitx-remote`, and `ibus` in order; if none is found, it warns and falls back to the fcitx5 command name |
| WakaTime account configuration | The WakaTime plugin is enabled; you need to complete authentication yourself |
| `OPENROUTER_TOKEN` | Minuet completion and llm.nvim's current OpenRouter model |
| `TAVILY_TOKEN` | llm.nvim web search |

The current model for Minuet and llm.nvim is `cohere/north-mini-code:free`; its continued availability depends on the service provider. Definitions for other providers in `llm/models.lua` are not included in the current `models` list and do not indicate that those providers are enabled by default. Chat history is saved in `stdpath('cache')/llm-history`. LLM extensions cover Q&A, code explanation, translation, test/documentation generation, commit messages, and BashRunner. Read the corresponding extension before invoking it, especially BashRunner's command execution behavior.

## Filetypes and Theme

`after/ftplugin/` provides additional behavior for Vue, Oil, and mini.files. Local LuaSnip files are `snippets/go/go.lua`, `snippets/java/java.lua`, and `snippets/vue/vue.lua`; snippet availability also depends on LuaSnip and friendly-snippets being loaded.

`lua/config/filetype.lua` extends filename detection for shell dotfiles, Git configuration files, `Taskfile`, `Brewfile`, and other listed names, including their `.tmpl` and chezmoi-prefixed variants (such as `dot_zshrc` and `private_dot_zshrc.tmpl`).

Autocommands set `*.env` / `.env.*` to `sh`, `*.ejs` / `*.ejs.t` to `embedded_template`, and `*.code-snippets` to `json`. JSON/JSONC do not conceal text. Several special windows register `q` to close them and are hidden from the buffer list. On `FileType`, `c/r/o` are removed from `formatoptions`, disabling automatic comment formatting and continuation.

The theme gets its base colors from `lua/theme/palette.lua` and merges in `palette.json`; the default `variant = "auto"` follows `background`. Transparency has one persisted state in `stdpath('data')/transparent`: terminals remove theme background highlights, while Neovide keeps the theme background and switches between the configured `g.neovide_opacity` and `1.0`. `:TransparentToggle` updates the same state from either frontend, and SIGUSR1 reloads and applies it.

## Troubleshooting

| Symptom | Checks |
| --- | --- |
| Startup or plugin installation fails | Check `:messages` and `:Lazy` logs; verify Git, network access, the Neovim version, and the build environment |
| Terminal or external command fails | Check `:set shell?` and verify `zsh` / `nu`; then check whether the specific command is in PATH |
| LSP does not attach | `:set ft?` → `<leader>cL` to confirm the declaration → `:Mason` to confirm the package → `<leader>cl` to inspect status → check root and cmd in `lsp/`; you can also run `:checkhealth vim.lsp` |
| Formatting does not run | Use `:ConformInfo` to inspect current formatters, executables, and logs; confirm that project configuration meets the requirements; saving alone does not invoke Conform |
| Lint diagnostics are missing | Check `:lua vim.print(require('lint').linters_by_ft[vim.bo.filetype])`, the configuration file requirements, and whether the CLI is executable |
| No Treesitter highlighting | Confirm the parser/filetype in the language spec, then check `:messages` and `:checkhealth nvim-treesitter`; the first installation requires waiting |
| Garbled icons or clipboard failure | Use a Nerd Font and run `:checkhealth`; system clipboard synchronization is explicitly disabled over SSH |
| Keymaps differ from expectations | Use `:verbose nmap <key>` / `:verbose imap <key>` to inspect the final definition and its source; lazy loading and LSP attachment can affect registration order |
