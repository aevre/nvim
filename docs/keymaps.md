# Keymap Reference

[English](keymaps.md) | [简体中文](keymaps.zh-CN.md)

[Back to README](../README.md)

Both `<leader>` and `<localleader>` are Space. The table lists mappings provided by this configuration; `n` is normal, `i` insert, `x` visual, `o` operator-pending, `t` terminal, `c` command-line, and `s` select; `v` means visual and select modes. The default mode when unspecified is `n`. Suffixes in grouped abbreviations share the prefix, for example `<leader>wh/wj/wk/wl`. Some plugin mappings require the plugin and its external tools to be available.

## Editing and Movement

| Key | Mode | Action |
| --- | --- | --- |
| `jk` | `i` | Return to normal mode |
| `j` / `k`, `<Down>` / `<Up>` | `n,x` | Move up and down by screen line (preserves the original action when a count is given) |
| `<A-h/j/k/l>` | `i` | Move the cursor while inserting |
| `<A-h/l>` | `c` | Move left and right in the command line |
| `<A-h/j/k/l>` | `t` | Send arrow keys in the terminal |
| `<C-j>` / `<C-k>` | `n,i,v` | Move the current line or selection down / up |
| `gV` | `n` | Reselect the text from the most recent change, paste, or copy |
| `g/` | `x` | Search within the visual selection |
| `<` / `>` | `x` | Indent while keeping the selection |
| `gco` / `gcO` | `n` | Add a commented line below / above |
| `<Esc>` | `i,n,s` | Exit and clear search highlighting |
| `n` / `N` | `n,x,o` | Jump to the next / previous result in the search direction |
| `,`, `.`, `;` | `i` | Create undo breakpoints |
| `<C-s>` | `i,x,n,s` | Save the file |
| `<leader>ur` | `n` | Clear highlights, update diff, and redraw |
| `<leader>K` | `n` | Execute `keywordprg` |

Source: [general.lua](../lua/config/keymaps/general.lua). Neovim 0.12's built-in mappings such as `gra/gri/grn/grr/grt/grx/gO`, insert-mode `<C-s>`, and `an/in` are deleted.

## Files, Buffers, Windows, and Tabs

| Key | Mode | Action |
| --- | --- | --- |
| `<leader>fs` | `n` | Reload the current file |
| `<leader>fe` | `n` | Change the current working directory |
| `<S-h>` / `<S-l>`, `[b` / `]b` | `n` | Previous / next buffer |
| `<leader>bb` / `` <leader>` `` | `n` | Switch to another buffer |
| `<leader>bD` | `n` | Delete the buffer and its window |
| `<leader>bd` | `n` | Delete the buffer |
| `<leader>bo` | `n` | Keep only the current buffer |
| `<leader>wh/wj/wk/wl` | `n` | Move to the left / bottom / top / right window |
| `<leader>-` / `<leader>\|` | `n` | Horizontal split below / vertical split to the right |
| `<leader>wd` | `n` | Close the current window |
| `<leader>+` / `<leader>_` | `n` | Increase / decrease window height |
| `<leader>>` / `<leader><` | `n` | Increase / decrease window width |
| `<leader><tab><tab>` | `n` | Create a new tab |
| `<leader><tab>[` / `]` | `n` | Previous / next tab |
| `<leader><tab>d` | `n` | Close the tab |
| `<leader><tab>f` / `l` | `n` | First / last tab |
| `<leader><tab>o` | `n` | Keep only the current tab |

Source: [file.lua](../lua/config/keymaps/file.lua), [buffer.lua](../lua/config/keymaps/buffer.lua), [window.lua](../lua/config/keymaps/window.lua), [tab.lua](../lua/config/keymaps/tab.lua).

Window dimensions change by 2 rows or columns at a time; a count can multiply the adjustment. `file.lua` also defines `<leader>fn` for a new file, but the startup-loaded fzf spec reuses it for Fidget history; use `:enew` to create an empty buffer.

## Search, File Finding, and Replacement

The following are fzf-lua's top-level Lazy `keys`; the plugin sets `lazy = false` and loads at startup:

| Key | Mode | Action |
| --- | --- | --- |
| `<leader><space>`, `<leader>ff` | `n` | Find files |
| `<leader>fc` | `n` | Find Neovim configuration files |
| `<leader>fr` / `<leader>fR` | `n` | Recent files / recent files in the current directory |
| `<leader>fb` / `<leader>,`; `<leader>fB` | `n` | Buffers; including unloaded buffers |
| `<leader>fg` | `n` | Git files |
| `<leader>fz` | `n` | zoxide |
| `<leader>/` | `n` | Live grep |
| `<leader>sw` / `<leader>sW` | `n,x` | Search the word under the cursor / WORD or visual selection |
| `<leader>sg` / `<leader>sG` | `n` | grep (native / normal) |
| `<leader>sB` / `<leader>sb` | `n` | Project grep / lines in loaded buffers (`lines()`) |
| `<leader>sr` | `n,x` | grug-far search and replace |
| `<leader>:` | `n` | Command history |
| `<leader>s/` | `n` | Search history |
| `<leader>sC` / `<leader>sc` | `n` | Command list / command history |
| `<leader>sh` / `<leader>sH` | `n` | Help pages / highlight groups |
| `<leader>n` / `<leader>fn` | `n` | Notification history / Fidget history |
| `<leader>cL` | `n` | Language configuration |
| `<leader>sk` | `n` | Show keymaps |
| `<leader>sd` / `<leader>sD` | `n` | Workspace / current document diagnostics |
| `<leader>sq` / `<leader>sl` | `n` | quickfix / location list |
| `<leader>su` / `<leader>sm` | `n` | Undo tree / marks |
| `<leader>sR` | `n` | Resume the last fzf picker |
| `<leader>st` | `n` | Find TODO/FIXME/NOTE/WARN |
| `<leader>s"` | `n` | Registers |
| `<leader>sa` / `<leader>sj` | `n` | autocmd / jumps |
| `<leader>si` / `<leader>sM` | `n` | Icons / man pages |
| `<leader>uC` | `n` | Choose a colorscheme |
| `<leader>gb` / `<leader>gs` / `<leader>gS` | `n` | Git branches / status / stash |
| `<leader>gf` | `n` | Git log for the current file |
| `<leader>gd` / `<leader>gD` | `n` | Diff hunks / diff against origin |
| `<leader>gi` / `<leader>gI` | `n` | GitHub issues (open / all) |
| `<leader>gp` / `<leader>gP` | `n` | GitHub PRs (open / all) |

Source: [fzf.lua](../lua/plugins/qol/fzf.lua), [grug-far.lua](../lua/plugins/qol/grug-far.lua). fzf-lua is configured with `lazy = false`, so these mappings are available after startup.

## Diagnostics and LSP

| Key | Mode | Action |
| --- | --- | --- |
| `<leader>cd` | `n` | Open a diagnostic float for the current line |
| `[d` / `]d` | `n` | Previous / next diagnostic |
| `[e` / `]e` | `n` | Previous / next error |
| `[w` / `]w` | `n` | Previous / next warning |
| `<leader>cl` | `n` | LSP information picker |
| `gd` / `gD` | `n` | Definition / declaration |
| `gr` | `n` | References |
| `gI` | `n` | Implementation |
| `gy` | `n` | Type definition |
| `K` | `n` | Hover documentation |
| `gK` | `n` | Signature help (when supported by the client) |
| `<leader>ca` | `n,x` | Code Action |
| `<leader>cr` | `n` | Rename symbol |
| `<leader>cR` | `n` | Delete the old file after `saveas` to a new path; not an LSP file rename |
| `<leader>ld` | `n` | Current document LSP diagnostics |
| `<leader>co` | `n` | Organize imports |
| `gai` / `gao` | `n` | Incoming / outgoing calls |
| `<leader>ss` / `<leader>sS` | `n` | Document / workspace symbols |
| `<leader>uh` | `n` | Toggle inlay hints (when supported by the client) |
| `<leader>cc` | `n` | Run codelens (when supported by the client) |
| `<leader>cA` | `n` | Source Action |

Source: [lsp.lua](../lua/config/lsp.lua), [diagnostic.lua](../lua/config/keymaps/diagnostic.lua). These mappings are set when an LSP attaches. Signature help, inlay hints, and codelens mappings require client support.

## Terminal, Git, Plugins, and Sessions

| Key | Mode | Action |
| --- | --- | --- |
| `<leader>ts` | `n` | Select a terminal |
| `<leader>tf` | `n` | Toggle floating terminal |
| `<leader>tk/tj/th/tl` | `n` | Toggle top / bottom / left / right terminal |
| `<leader>tm` | `n` | Floating `rmpc` |
| `<leader>gg` | `n` | Lazygit |
| `<leader>pu` | `n` | Call `vim.pack.update()` (not a Lazy update) |
| `jk` | `t` | Return to normal mode in this configuration's terminal windows / rmpc |
| `<leader>L` | `n` | Lazy |
| `<leader>qs` / `<leader>qS` | `n` | Restore / select a session |
| `<leader>ql` | `n` | Restore the most recent session |
| `<leader>qw` | `n` | Save the current session (`SessionSave`) |
| `<leader>qd` | `n` | Select and delete a session |
| `<leader>qD` | `n` | Delete the active session |
| `<leader>qr` | `n` | Rename the active session |
| `<leader>qR` | `n` | Select a session to rename |
| `<leader>v` | `n,x` | Yank history |
| `[y` / `]y` | `n` | Cycle through yank history |
| `y`, `p`, `P`, `gp`, `gP` | `n,x` | Yanky copy and paste |
| `<leader>uk` | `n` | Toggle Screenkey |
| `<leader>cm` | `n` | Mason |
| `<leader>cf` | `n` | Format |
| `<leader>cD` | `n` | CodeDiff |

Source: [terminal.lua](../lua/config/keymaps/terminal.lua), [lazy.lua](../lua/config/lazy.lua), [session.lua](../lua/plugins/qol/session.lua), [yanky.lua](../lua/plugins/qol/yanky.lua), [screenkey.lua](../lua/plugins/ui/screenkey.lua), [mason.lua](../lua/plugins/lsp/mason.lua), [formatter.lua](../lua/plugins/formatter.lua), [codediff.lua](../lua/plugins/editor/codediff.lua). All terminal positions configured here use `jk` to leave terminal mode.

## Coding, Completion, and Text Objects

| Key | Mode | Action |
| --- | --- | --- |
| `<CR>` | `i` | Accept completion, otherwise fall back |
| `<Tab>` / `<S-Tab>` | `i` | Next / previous completion or snippet jump |
| `<S-space>` | `i` | Show completion / documentation |
| `<C-h>` | `i` | Hide / show completion |
| `<C-b>` / `<C-f>` | `i` | Scroll completion documentation up / down |
| `<A-1>`…`<A-0>` | `i` | Accept completion item 1…10 |
| `s` / `S` | `n,x,o` | Flash jump / Treesitter jump |
| `r` | `o` | Flash remote |
| `R` | `o,x` | Treesitter search |
| `gl` | `n,x,o` | Flash to the start of the line |
| `<C-Space>` | `n,o,x` | Treesitter incremental selection; press `<C-Space>` / `<BS>` again to expand / shrink |
| `<C-s>` | `c` | Toggle Flash search |
| `;` / `,` | `n,x,o` | Repeat the last Treesitter movement forward / backward |
| `]f` / `[f`, `]F` / `[F` | `n,x,o` | Next / previous function start or end |
| `]c` / `[c`, `]C` / `[C` | `n,x,o` | Next / previous class start or end |
| `]a` / `[a`, `]A` / `[A` | `n,x,o` | Next / previous parameter start or end |
| `]z` | `n,x,o` | Next fold point |
| `]=` / `[=`, `]r` / `[r` | `n` | Next / previous assignment, return |
| `<leader>ma/mA`, `<leader>mf/mF` | `n` | Swap with next / previous parameter or function |
| `gsa` | `n,x` | Add a surround (follow with an action in normal mode) |
| `gsd` / `gsr` | `n` | Delete / replace a surround |
| `gsf` / `gsF` / `gsh` | `n` | Find right / find left / highlight a surround |
| `<C-a>` / `<C-x>` | `n,v` | Increment / decrement numbers, dates, booleans, etc. |
| `g<C-a>` / `g<C-x>` | `n,x` | Increment / decrement each item in a selection |

Source: [blink-cmp.lua](../lua/plugins/coding/blink-cmp.lua), [flash.lua](../lua/plugins/qol/flash.lua), [treesitter-textobjects.lua](../lua/plugins/editor/treesitter-textobjects.lua), [mini-surround.lua](../lua/plugins/editor/mini-surround.lua), [dial.lua](../lua/plugins/editor/dial.lua). `f/F/t/T` are also wrapped in `n,x,o` modes to support repeated movement. Blink's table describes explicit insert-mode keys; command-line completion has separate configuration, so the entire table cannot be treated as command-line mappings. `mini-pairs` is disabled. Flash provides the Treesitter search and incremental selection mappings. cmdline.nvim provides the command-line UI; noice.nvim and tiny-cmdline.nvim are disabled.

[mini-ai.lua](../lua/plugins/editor/mini-ai.lua) provides `a/i`, `an/in` (next), and `al/il` (previous) text-object prefixes in `x,o` modes; `g[/g]` jumps to the object's left/right boundary in `n,x,o`. Custom objects: `o` block/conditional/loop, `f` function, `c` class, `a` parameter, `d` number, `e` case-sensitive word segment, `g` entire buffer, `u/U` function call. For example, `dif` deletes inside a function, `yaa` copies a parameter with its separator, `yag` copies the entire buffer; `ap/ip` keep mini.ai's paragraph object. The built-in `an/in` mappings deleted at startup do not prevent mini.ai from registering them again after it loads. Treesitter swap mappings use `<leader>ma/mA` for next/previous parameters and `<leader>mf/mF` for next/previous functions.

[blink-pairs.lua](../lua/plugins/editor/blink-pairs.lua) configures `<C-b>` / `<C-S-b>` wrapping actions to move closing / opening brackets (insert mode, with command-line mappings enabled).

[Yanky](../lua/plugins/qol/yanky.lua) also explicitly sets normal-mode mappings: `]p/]P`, `[p/[P` paste after/before with aligned indentation; `>p/<p`, `>P/<P` paste after/before and indent right/left; `=p/=P` paste after/before and filter.

[mini-diff.lua](../lua/plugins/ui/mini-diff.lua): `gh/gH` (`n,x`) apply/reset a hunk, and `gh` (`o`) is a hunk text object.

Generate annotations with `<leader>cn` (`n`, [neogen.lua](../lua/plugins/coding/neogen.lua)); toggle the code outline with `<leader>cs` (`n`, [aerial.lua](../lua/plugins/coding/aerial.lua)).

## File Browser and Special Windows

| Key | Mode | Action |
| --- | --- | --- |
| `-` | `n` | Open the Oil parent directory |
| `g?` | Oil `n` | Help |
| `<CR>` / `\` / `\|` / `<C-t>` | Oil `n,v,o` | Open the current item / horizontal / vertical / new tab |
| `<C-r>` / `<C-p>` | Oil `n,v,o` | Refresh / preview |
| `<C-c>` / `-` | Oil `n` | Close |
| `zh` / `gh` | Oil `n` / `n,v,o` | Toggle hidden-file visibility / custom dotfile and gitignored filtering |
| `` ` `` / `~` | Oil `n` | Change to directory / tab directory |
| `gs` / `gx` / `<BS>` / `gd` | Oil `n` / `n,v,o` / `n,v,o` / `n,v,o` | Sort / open externally / parent directory / file details |
| `<leader>e` | `n` | Open the current file path with MiniFiles |
| `q` | Special window `n` | Close the special window |
| `jk` | fzf terminal `t` | Leave fzf terminal mode |

Source: [oil.lua](../lua/plugins/qol/oil.lua), [mini-files.lua](../lua/plugins/qol/mini-files.lua), [autocmds.lua](../lua/config/autocmds.lua). Oil uses `use_default_keymaps = false`; the table lists only explicit configuration. [oil.lua](../after/ftplugin/oil.lua) and [minifiles.lua](../after/ftplugin/minifiles.lua) only set completion variables; [vue.lua](../after/ftplugin/vue.lua) only configures highlighting and language services, and none of the three adds mappings.

## LLM, HTTP, and Preview

| Key | Mode | Action |
| --- | --- | --- |
| `<leader>ac` | `n` | Toggle the LLM session |
| `<leader>aa` / `<leader>ak` | `n,v` | Ask a multi-turn question / ask a question |
| `<leader>ae` / `<leader>aw` | `n,v` / `n,x` | Explain code / translate a word |
| `<leader>at` | `n` | Translate |
| `<leader>aT` / `<leader>ao` / `<leader>ad` | `x` / `x` / `v` | Generate tests / optimize comparison / docstring |
| `<leader>ag` / `<leader>au` | `n` | Generate a commit message / view account |
| `<leader>ab` / `<leader>ai` | `n,v` | Bash runner / formula recognition |
| `<C-g>` / `<C-c>` / `<C-r>` | LLM input `i,n` | Submit / cancel / resend |
| `<C-j>` / `<C-k>` | LLM input `i,n` | Next / previous history item |
| `<C-S-J>` / `<C-S-K>` | LLM input `i,n` | Next / previous model |
| `i` / `<C-w>` | LLM output `n` | Focus input; `<C-w>` in the input area (`n,i`) focuses output |
| `<C-c>` / `<C-r>` | LLM split output `n` | Cancel / resend |
| `q` / `<Esc>` | LLM float `n` | Hide / close the session |
| `<C-n>` / `<C-h>` | LLM float `n` | New session / session history |
| `<C-b>` / `<C-f>`, `<C-u>` / `<C-d>` | LLM `i,n` | Page / half-page scroll |
| `gg` / `G` | LLM `n` | Jump to top / bottom |
| `<leader>Rc/Re/Rf/Rp/Rs/RS/Rq` | `n` | HTTP copy cURL / environment / environment file / profiling / execute / dry-run / stop |
| `<leader>cps/cpc/cpp` | `n` | Live Preview start / close / select |
| `d`, `y/Y`, `n/N`, `<Esc>` | LLM Ask window `n` | Show, accept, reject, close |
| `<CR>` | LLM commit window `n` | Actually execute `git commit -m ...`, then open Lazygit |
| `<C-f>` | LLM formula input `i` | Select an image |

Source: [llm/init.lua](../lua/plugins/qol/llm/init.lua), [llm/keymaps.lua](../lua/plugins/qol/llm/keymaps.lua), [llm/extensions/ask.lua](../lua/plugins/qol/llm/extensions/ask.lua), [llm/extensions/commit_msg.lua](../lua/plugins/qol/llm/extensions/commit_msg.lua), [llm/extensions/formula_recognition.lua](../lua/plugins/qol/llm/extensions/formula_recognition.lua), [http-client.lua](../lua/plugins/coding/http-client.lua), [live-preview.lua](../lua/plugins/qol/live-preview.lua).

## Help, Exit, and Troubleshooting

- `<leader>?` (`n`) shows buffer-local mappings: [which-key.lua](../lua/plugins/qol/which-key.lua).
- `<leader>xl/xq` (`n`) toggles the location/quickfix windows; `[q/]q` jumps through quickfix; `<leader>qq` exits all windows; `<leader>ui/uI` inspects the location/Treesitter trees: [general.lua](../lua/config/keymaps/general.lua).
- Alpha dashboard keys (`n`): `f/g/r/c` find files / search text / recent files / config files; `s/S` restore / select a session; `L/q` open Lazy / quit: [dashboard.lua](../lua/plugins/ui/dashboard.lua).
- When a mapping is overridden, run `:verbose nmap <key>`, `:verbose imap <key>`, or the corresponding command for the mode to inspect the current mapping and its last set location.
