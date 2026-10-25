# Neovim Configuration

[English](README.md) | [简体中文](README.zh-CN.md)

A personal Neovim configuration for everyday development, using lazy.nvim for plugins, native Neovim LSP, blink.cmp for completion, Conform for formatting, nvim-lint for linting, and nvim-treesitter. Language and tool definitions live in `lua/toolchain/`; the theme is implemented locally in `lua/theme/`.

The configuration runs on **Neovim 0.12.5**. The configuration uses newer APIs such as `vim.lsp.get_configs()`, `vim.lsp.codelens.enable()`, and `vim.pack.update()`. Neovim 0.12 is recommended; compatibility with older versions is not guaranteed.

- [Keymap reference](docs/keymaps.md)
- [Features, dependencies, and troubleshooting](docs/configuration.md)
- [Languages and toolchain configuration](docs/toolchain.md)

## Installation

Back up your existing Neovim configuration first. To install at the default Linux/macOS configuration path:

```sh
git clone https://github.com/immortal521/nvim.git ~/.config/nvim
nvim
```

The destination must not already exist. If you use a custom `XDG_CONFIG_HOME`, use its `nvim` directory instead. On Windows, use the directory reported by `:echo stdpath('config')`. The configuration has Windows branches, but some behavior still depends on external commands and the platform; see the dependency notes.

On first launch, Git clones the stable branch of lazy.nvim, which then installs plugins. During `VeryLazy`, the Mason registry is refreshed and missing tools with package mappings are installed, along with extra packages. This covers all declared tools, not just the current language. Treesitter requests parser installation when a supported filetype needs it. Network access, compilers, and language runtimes must be prepared separately.

Basic requirements:

| Dependency | Purpose |
| --- | --- |
| Neovim 0.12, Git | Editor, plugin installation, and Git features |
| `zsh`; `nu` on Windows | The explicitly configured shell; `$SHELL` is not used directly |
| `rg`, `fzf` | Text search, pickers, and ripgrep completion source |
| C toolchain, `tree-sitter` CLI | Building Treesitter parsers; the CLI is in Mason's extra package list |
| Node.js/npm, Python, Go, Rust, Java, etc. | As required by your languages and Mason packages; Mason does not install every language runtime |
| Nerd Font | File, diagnostic, and statusline icons; the GUI font is `Maple Mono NF CN:h14` |
| System clipboard provider | Local `unnamedplus` integration; use `:checkhealth` to identify required tools |

blink.cmp includes a native component build step. If it fails, inspect the logs in `:Lazy` and prepare the Rust toolchain required by the installed plugin version. See the [feature guide](docs/configuration.md) for optional commands such as `lazygit`, `gh`, `zoxide`, and `rmpc`.

After installation, check:

```vim
:Lazy
:Mason
:checkhealth
:ConformInfo
```

Open a real project file, use `<leader>cl` to inspect LSP, and `<leader>cL` to inspect language definitions. Both `<leader>` and `<localleader>` are Space.

## Everyday entry points

These are common normal-mode mappings. See the [keymap reference](docs/keymaps.md) for modes and loading conditions.

| Key | Action |
| --- | --- |
| `<leader><space>` / `<leader>ff` | Find files |
| `<leader>/` | Search project text |
| `<leader>,` | Select a buffer |
| `<leader>e` | Open mini.files; Oil handles default directory browsing |
| `<leader>gg` | Lazygit |
| `<leader>tf` | Floating terminal |
| `<leader>cf` | Format manually |
| `<leader>cd` | Current-line diagnostics |
| `gd` / `gr` / `K` | LSP definition, references, hover (registered after attach) |
| `<leader>ca` / `<leader>cr` | LSP code action / rename |
| `<leader>L` / `<leader>cm` | Lazy / Mason |
| `<leader>?` | Current-buffer keymap hints |

autosave.nvim uses a 1000ms delay, disables save notifications, and excludes Oil buffers. **Conform format-on-save is not configured.** Defaults include two-space indentation, relative line numbers, and persistent undo. Under SSH, `unnamedplus` system clipboard integration is disabled.

## Layout

```text
init.lua                   Loads config
lua/config/                Options, autocmds, global keys, LSP, plugin bootstrap
lua/plugins/               Lazy specs by feature and plugin implementation modules
lua/toolchain/             Language specs, tool conditions, Mason package mappings
lsp/                       Native LSP commands, roots, and settings
lua/theme/                 Palette, highlights, and transparency
palette.json               JSON overrides for the current theme
lua/sources/               Language, LSP, notification, and icon sources for fzf
lua/utils/                 Shared helpers
snippets/                  Local LuaSnip snippets for Go, Java, and Vue
after/ftplugin/            Filetype additions for Vue, Oil, and mini.files
docs/                      English and Chinese reference guides
lazy-lock.json             Plugin version lockfile
```

Startup order: theme → options → filetype detection → autocmds → keymaps → LSP/toolchain → lazy.nvim bootstrap → custom events → plugin manager. `BufEdit` is a local Lazy event alias covering `BufReadPost`, `BufNewFile`, and `BufWritePre`.

## Customization

- Editing behavior and shell: [lua/config/options.lua](lua/config/options.lua).
- Global keys: [lua/config/keymaps/](lua/config/keymaps/). Plugin keys usually live in their own specs.
- Add or adjust languages: see the [toolchain guide](docs/toolchain.md); `<leader>cL` opens a definition directly.
- LSP parameters: [lsp/](lsp/). A file's presence does not enable a server: the language declaration, installation, and root conditions must also be satisfied.
- Theme: [lua/theme/](lua/theme/) and [palette.json](palette.json). Startup applies the local theme directly; it does not run `colorscheme tokyonight`. `:TransparentToggle` toggles and persists transparency.
- Local plugin development: set `NVIM_PLUGIN_MODE=dev` to load the nine personal plugins (`win`, `animate`, `scroll`, `terminal`, `lazygit`, `notify`, `cmdline`, `autosave`, `session`) from `~/Projects/lib`; unset it or use another value to load their Codeberg repositories. `NVIM_DEV_DIR` remains Lazy's separate generic local-plugin matcher.

Use `:Lazy update` to update plugins, or `:Lazy restore` to restore versions from the committed lockfile. `<leader>pu` calls native Neovim `vim.pack.update()`; it does not update Lazy-managed plugins.
