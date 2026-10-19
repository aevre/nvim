# 快捷键参考

[English](keymaps.md) | [简体中文](keymaps.zh-CN.md)

[返回 README](../README.zh-CN.md)

`<leader>` 和 `<localleader>` 都是空格。下表只记录本配置显式注册的映射；`n` 普通、`i` 插入、`x` 可视、`o` 操作符等待、`t` 终端、`c` 命令行、`s` 选择；`v` 表示可视及选择模式。未标注时为 `n`。组合缩写中的后缀共用前缀，例如 `<leader>wh/wj/wk/wl`。插件快捷键需要相应插件加载完成；部分功能还需要外部工具。

## 编辑与移动

| 按键 | 模式 | 用途 |
| --- | --- | --- |
| `jk` | `i` | 返回普通模式 |
| `j` / `k`、`<Down>` / `<Up>` | `n,x` | 按屏幕行上下移动（有计数时保持原动作） |
| `<A-h/j/k/l>` | `i` | 插入时移动光标 |
| `<A-h/l>` | `c` | 命令行左右移动 |
| `<A-h/j/k/l>` | `t` | 终端中发送方向键 |
| `<C-j>` / `<C-k>` | `n,i,v` | 下移 / 上移当前行或选区 |
| `gV` | `n` | 重新选择最近改动、粘贴或复制的文本 |
| `g/` | `x` | 在可视选区内搜索 |
| `<` / `>` | `x` | 缩进并保持选区 |
| `gco` / `gcO` | `n` | 在下方 / 上方新增注释行 |
| `<Esc>` | `i,n,s` | 退出并清除搜索高亮 |
| `n` / `N` | `n,x,o` | 按搜索方向跳到下一个 / 上一个结果 |
| `,`、`.`、`;` | `i` | 建立撤销断点 |
| `<C-s>` | `i,x,n,s` | 保存文件 |
| `<leader>ur` | `n` | 清除高亮、更新 diff、重绘 |
| `<leader>K` | `n` | 执行 `keywordprg` |

来源：[general.lua](../lua/config/keymaps/general.lua)、[init.lua](../lua/config/init.lua)。Neovim 0.12 的 `gra/gri/grn/grr/grt/grx/gO`、插入态 `<C-s>` 和 `an/in` 等内置映射会被删除。

## 文件、缓冲区、窗口与标签页

| 按键 | 模式 | 用途 |
| --- | --- | --- |
| `<leader>fn` | `n` | 新建空文件 |
| `<leader>fs` | `n` | 重新载入当前文件 |
| `<leader>fe` | `n` | 修改当前工作目录 |
| `<S-h>` / `<S-l>`、`[b` / `]b` | `n` | 上一个 / 下一个缓冲区 |
| `<leader>bb` / `` <leader>` `` | `n` | 切换到另一个缓冲区 |
| `<leader>bD` | `n` | 删除缓冲区及窗口 |
| `<leader>bd` | `n` | 删除缓冲区 |
| `<leader>bo` | `n` | 只保留当前缓冲区 |
| `<leader>wh/wj/wk/wl` | `n` | 移到左 / 下 / 上 / 右窗口 |
| `<leader>-` / `<leader>\|` | `n` | 下方水平 / 右侧垂直分屏 |
| `<leader>wd` | `n` | 关闭当前窗口 |
| `<leader>+` / `<leader>_` | `n` | 增大 / 减小窗口高度 |
| `<leader>>` / `<leader><` | `n` | 增大 / 减小窗口宽度 |
| `<leader><tab><tab>` | `n` | 新建标签页 |
| `<leader><tab>[` / `]` | `n` | 上一个 / 下一个标签页 |
| `<leader><tab>d` | `n` | 关闭标签页 |
| `<leader><tab>f` / `l` | `n` | 第一个 / 最后一个标签页 |
| `<leader><tab>o` | `n` | 只保留当前标签页 |

来源：[file.lua](../lua/config/keymaps/file.lua)、[buffer.lua](../lua/config/keymaps/buffer.lua)、[window.lua](../lua/config/keymaps/window.lua)、[tab.lua](../lua/config/keymaps/tab.lua)。

窗口尺寸每次调整 2 行或列，可加计数倍增。

## 搜索、文件查找与替换

以下是 fzf-lua 的顶层 Lazy `keys`；该插件设置 `lazy = false`，随启动加载：

| 按键 | 模式 | 用途 |
| --- | --- | --- |
| `<leader><space>`、`<leader>ff` | `n` | 查找文件 |
| `<leader>fc` | `n` | 查找 Neovim 配置文件 |
| `<leader>fr` / `<leader>fR` | `n` | 最近文件 / 当前目录最近文件 |
| `<leader>fb` / `<leader>,`；`<leader>fB` | `n` | 缓冲区；包括未加载的缓冲区 |
| `<leader>fg` | `n` | Git 文件 |
| `<leader>fz` | `n` | zoxide |
| `<leader>/` | `n` | 实时 grep |
| `<leader>sw` / `<leader>sW` | `n,x` | 搜索光标词 / WORD 或可视选择 |
| `<leader>sg` / `<leader>sG` | `n` | grep（native / 普通） |
| `<leader>sB` / `<leader>sb` | `n` | 项目 grep / 已加载缓冲区行（`lines()`） |
| `<leader>sr` | `n,x` | grug-far 搜索替换 |
| `<leader>:` | `n` | 命令历史 |
| `<leader>s/` | `n` | 搜索历史 |
| `<leader>sC` / `<leader>sc` | `n` | 命令列表 / 命令历史 |
| `<leader>sh` / `<leader>sH` | `n` | 帮助页 / 高亮组 |
| `<leader>n` / `<leader>cL` | `n` | 通知历史 / 语言配置 |
| `<leader>sk` | `n` | 查看键位 |
| `<leader>sd` / `<leader>sD` | `n` | 工作区 / 当前文档诊断 |
| `<leader>sq` / `<leader>sl` | `n` | quickfix / location list |
| `<leader>su` / `<leader>sm` | `n` | undo 树 / marks |
| `<leader>sR` | `n` | 恢复上次 fzf picker |
| `<leader>st` | `n` | 查找 TODO/FIXME/NOTE/WARN |
| `<leader>s"` | `n` | 寄存器 |
| `<leader>sa` / `<leader>sj` | `n` | autocmd / jumps |
| `<leader>si` / `<leader>sM` | `n` | 图标 / man 页面 |
| `<leader>uC` | `n` | 选择配色 |
| `<leader>gb` / `<leader>gs` / `<leader>gS` | `n` | Git 分支 / 状态 / stash |
| `<leader>gf` | `n` | 当前文件 Git 日志 |
| `<leader>gd` / `<leader>gD` | `n` | diff hunks / 与 origin diff |
| `<leader>gi` / `<leader>gI` | `n` | GitHub issue（open / all） |
| `<leader>gp` / `<leader>gP` | `n` | GitHub PR（open / all） |

来源：[fzf.lua](../lua/plugins/qol/fzf.lua)、[grug-far.lua](../lua/plugins/qol/grug-far.lua)。选择器内的操作可通过 fzf-lua 帮助查看。

## 诊断与 LSP

| 按键 | 模式 | 用途 |
| --- | --- | --- |
| `<leader>cd` | `n` | 打开当前行诊断浮窗 |
| `[d` / `]d` | `n` | 上一个 / 下一个诊断 |
| `[e` / `]e` | `n` | 上一个 / 下一个错误 |
| `[w` / `]w` | `n` | 上一个 / 下一个警告 |
| `<leader>cl` | `n` | LSP 信息选择器 |
| `gd` / `gD` | `n` | 定义 / 声明 |
| `gr` | `n` | 引用 |
| `gI` | `n` | 实现 |
| `gy` | `n` | 类型定义 |
| `K` | `n` | 悬停文档 |
| `<leader>ca` | `n,x` | Code Action |
| `<leader>cr` | `n` | 符号重命名 |
| `<leader>cR` | `n` | `saveas` 新路径后删除旧文件，不是 LSP 文件重命名 |
| `<leader>ld` | `n` | 当前文档 LSP 诊断 |
| `<leader>co` | `n` | 整理 imports |
| `gai` / `gao` | `n` | incoming / outgoing calls |
| `<leader>ss` / `<leader>sS` | `n` | 文档 / 工作区 symbols |
| `<leader>uh` | `n` | 切换 inlay hints（client 支持时） |
| `<leader>cc` | `n` | 运行 codelens（client 支持时） |
| `<leader>cA` | `n` | Source Action |

来源：[lsp.lua](../lua/config/lsp.lua)、[diagnostic.lua](../lua/config/keymaps/diagnostic.lua)。导航、重命名和 code action 等映射在 LSP 连接后全局注册。Inlay hints 和 codelens 需要语言服务支持。

## 终端、Git、插件与会话

| 按键 | 模式 | 用途 |
| --- | --- | --- |
| `<leader>tf` | `n` | 浮动终端 |
| `<leader>tm` | `n` | 浮动 `rmpc` |
| `<leader>gg` | `n` | Lazygit |
| `<leader>pu` | `n` | 调用 `vim.pack.update()`（不是 Lazy 更新） |
| `jk` | `t` | 本配置的浮动终端 / rmpc 返回普通模式 |
| `<leader>L` | `n` | Lazy |
| `<leader>qs` / `<leader>qS` | `n` | 恢复 / 选择会话 |
| `<leader>ql` | `n` | 恢复最近会话 |
| `<leader>qd` | `n` | 不保存当前会话 |
| `<leader>v` | `n,x` | Yank 历史 |
| `[y` / `]y` | `n` | 循环 Yank 历史 |
| `y`、`p`、`P`、`gp`、`gP` | `n,x` | Yanky 复制与粘贴 |
| `<leader>uk` | `n` | 切换 Screenkey |
| `<leader>cm` | `n` | Mason |
| `<leader>cf` | `n` | 格式化 |
| `<leader>cD` | `n` | CodeDiff |

来源：[terminal.lua](../lua/config/keymaps/terminal.lua)、[lazy.lua](../lua/config/lazy.lua)、[persistence.lua](../lua/plugins/qol/persistence.lua)、[yanky.lua](../lua/plugins/qol/yanky.lua)、[screenkey.lua](../lua/plugins/ui/screenkey.lua)、[mason.lua](../lua/plugins/lsp/mason.lua)、[formatter.lua](../lua/plugins/formatter.lua)、[codediff.lua](../lua/plugins/editor/codediff.lua)。终端插件提供 `q` 隐藏、`gf` 打开光标文件；浮窗配置使用 `jk` 退出终端模式。

## 编码、补全与文本对象

| 按键 | 模式 | 用途 |
| --- | --- | --- |
| `<CR>` | `i` | 接受补全，否则回退 |
| `<Tab>` / `<S-Tab>` | `i` | 下一个 / 上一个补全或 snippet 跳转 |
| `<S-space>` | `i` | 显示补全 / 文档 |
| `<C-h>` | `i` | 隐藏 / 显示补全 |
| `<C-b>` / `<C-f>` | `i` | 补全文档向上 / 向下滚动 |
| `<A-1>`…`<A-0>` | `i` | 接受第 1…10 项补全 |
| `s` / `S` | `n,x,o` | Flash 跳转 / Treesitter 跳转 |
| `r` | `o` | Flash remote |
| `R` | `o,x` | Treesitter 搜索 |
| `gl` | `n,x,o` | Flash 到行首 |
| `<C-Space>` | `n,o,x` | Treesitter 增量选择；再按 `<C-Space>` / `<BS>` 前进 / 后退 |
| `<C-s>` | `c` | 切换 Flash 搜索 |
| `;` / `,` | `n,x,o` | 重复上次 Treesitter 移动的正向 / 反向动作 |
| `]f` / `[f`、`]F` / `[F` | `n,x,o` | 下一个 / 上一个函数起点或终点 |
| `]c` / `[c`、`]C` / `[C` | `n,x,o` | 下一个 / 上一个 class 起点或终点 |
| `]a` / `[a`、`]A` / `[A` | `n,x,o` | 下一个 / 上一个参数起点或终点 |
| `]z` | `n,x,o` | 下一个 fold 点 |
| `]=` / `[=`、`]r` / `[r` | `n` | 下一个 / 上一个 assignment、return |
| `>a` / `<a`、`>f` / `<f` | `n` | 交换参数 / 函数 |
| `gsa` | `n,x` | 添加环绕（普通模式后接动作） |
| `gsd` / `gsr` | `n` | 删除 / 替换环绕 |
| `gsf` / `gsF` / `gsh` | `n` | 向右找 / 向左找 / 高亮环绕 |
| `<C-a>` / `<C-x>` | `n,v` | 增大 / 减小数字、日期、布尔值等 |
| `g<C-a>` / `g<C-x>` | `n,x` | 对选区逐项增大 / 减小 |

来源：[blink-cmp.lua](../lua/plugins/coding/blink-cmp.lua)、[flash.lua](../lua/plugins/qol/flash.lua)、[treesitter-textobjects.lua](../lua/plugins/editor/treesitter-textobjects.lua)、[mini-surround.lua](../lua/plugins/editor/mini-surround.lua)、[dial.lua](../lua/plugins/editor/dial.lua)。`f/F/t/T` 也在 `n,x,o` 模式被包装以支持重复移动。Blink 的表描述插入态显式键位；命令行补全另有配置，不能将整张表直接视为命令行映射。`mini-pairs` 已禁用。

[mini-ai.lua](../lua/plugins/editor/mini-ai.lua) 在 `x,o` 模式提供 `a/i`、`an/in`（下一个）、`al/il`（上一个）文本对象前缀，`g[/g]` 在 `n,x,o` 跳到对象左/右边界。自定义对象：`o` 块/条件/循环、`f` 函数、`c` 类、`a` 参数、`d` 数字、`e` 大小写词段、`g` 整个缓冲区、`u/U` 函数调用。例如 `dif` 删除函数内部、`yaa` 复制带分隔符的参数、`yag` 复制整个缓冲区；`ap/ip` 保留 mini.ai 的段落对象。启动时删除的内置 `an/in` 不妨碍 mini.ai 加载后重新注册。Treesitter 交换使用 `<leader>ma/mA` 交换下一个/上一个参数，使用 `<leader>mf/mF` 交换下一个/上一个函数，从而避开通知使用的 `<leader>n` 前缀，也不覆盖原生 `>a` 和 `<a` 缩进组合。

[blink-pairs.lua](../lua/plugins/editor/blink-pairs.lua) 配置 `<C-b>` / `<C-S-b>` 包裹动作以移动闭合 / 开启括号（插入态，并启用命令行映射）；插入态 `<C-b>` 与 Blink 补全文档滚动重叠，实际优先级取决于注册顺序。

[Yanky](../lua/plugins/qol/yanky.lua) 还显式设置普通模式：`]p/]P`、`[p/[P` 在后/前粘贴并对齐缩进；`>p/<p`、`>P/<P` 在后/前粘贴并右/左缩进；`=p/=P` 在后/前粘贴并过滤。

[mini-diff.lua](../lua/plugins/ui/mini-diff.lua)：`gh/gH`（`n,x`）应用/重置 hunk，`gh`（`o`）为 hunk 文本对象。

生成注释 `<leader>cn`（`n`，[neogen.lua](../lua/plugins/coding/neogen.lua)）；切换代码大纲 `<leader>cs`（`n`，[aerial.lua](../lua/plugins/coding/aerial.lua)）。

## 文件浏览器与特殊窗口

| 按键 | 模式 | 用途 |
| --- | --- | --- |
| `-` | `n` | 打开 Oil 父目录 |
| `g?` | Oil `n` | 帮助 |
| `<CR>` / `\` / `\|` / `<C-t>` | Oil `n,v,o` | 当前项打开 / 水平 / 垂直 / 新标签页 |
| `<C-r>` / `<C-p>` | Oil `n,v,o` | 刷新 / 预览 |
| `<C-c>` / `-` | Oil `n` | 关闭 |
| `zh` / `gh` | Oil `n` / `n,v,o` | 切换隐藏文件可见性 / 自定义 dotfile 与 gitignored 过滤 |
| `` ` `` / `~` | Oil `n` | 切换到目录 / tab 目录 |
| `gs` / `gx` / `<BS>` / `gd` | Oil `n` / `n,v,o` / `n,v,o` / `n,v,o` | 排序 / 外部打开 / 父目录 / 文件详情 |
| `<leader>e` | `n` | 用 MiniFiles 打开当前文件路径 |
| `q` | 特殊窗口 `n` | 关闭特殊窗口 |
| `jk` | fzf terminal `t` | 离开 fzf terminal 模式 |

来源：[oil.lua](../lua/plugins/qol/oil.lua)、[mini-files.lua](../lua/plugins/qol/mini-files.lua)、[autocmds.lua](../lua/config/autocmds.lua)。Oil 使用 `use_default_keymaps = false`，表中只列显式配置。[oil.lua](../after/ftplugin/oil.lua) 和 [minifiles.lua](../after/ftplugin/minifiles.lua) 只设置补全变量；[vue.lua](../after/ftplugin/vue.lua) 只配置高亮与语言服务，三者都没有额外映射。

## LLM、HTTP 与预览

| 按键 | 模式 | 用途 |
| --- | --- | --- |
| `<leader>ac` | `n` | LLM 会话开关 |
| `<leader>aa` / `<leader>ak` | `n,v` | 多轮提问 / 提问 |
| `<leader>ae` / `<leader>aw` | `n,v` / `n,x` | 解释代码 / 单词翻译 |
| `<leader>at` | `n` | 翻译 |
| `<leader>aT` / `<leader>ao` / `<leader>ad` | `x` / `x` / `v` | 生成测试 / 优化比较 / docstring |
| `<leader>ag` / `<leader>au` | `n` | 生成 commit message / 查看账户 |
| `<leader>ab` / `<leader>ai` | `n,v` | Bash runner / 公式识别 |
| `<C-g>` / `<C-c>` / `<C-r>` | LLM 输入 `i,n` | 提交 / 取消 / 重发 |
| `<C-j>` / `<C-k>` | LLM 输入 `i,n` | 下一个 / 上一个历史 |
| `<C-S-J>` / `<C-S-K>` | LLM 输入 `i,n` | 下一个 / 上一个模型 |
| `i` / `<C-w>` | LLM 输出 `n` | 聚焦输入；输入区 `<C-w>`（`n,i`）聚焦输出 |
| `<C-c>` / `<C-r>` | LLM split 输出 `n` | 取消 / 重发 |
| `q` / `<Esc>` | LLM float `n` | 隐藏 / 关闭会话 |
| `<C-n>` / `<C-h>` | LLM float `n` | 新会话 / 会话历史 |
| `<C-b>` / `<C-f>`、`<C-u>` / `<C-d>` | LLM `i,n` | 翻页 / 半页滚动 |
| `gg` / `G` | LLM `n` | 跳到顶部 / 底部 |
| `<leader>Rc/Re/Rf/Rp/Rs/RS/Rq` | `n` | HTTP 复制 cURL / 环境 / 环境文件 / profiling / 执行 / dry-run / 停止 |
| `<leader>cps/cpc/cpp` | `n` | Live Preview 启动 / 关闭 / 选择 |
| `d`、`y/Y`、`n/N`、`<Esc>` | LLM Ask 窗口 `n` | 显示、接受、拒绝、关闭 |
| `<CR>` | LLM commit 窗口 `n` | 实际执行 `git commit -m ...`，然后打开 Lazygit |
| `<C-f>` | LLM 公式输入 `i` | 选择图片 |

来源：[llm/init.lua](../lua/plugins/qol/llm/init.lua)、[llm/keymaps.lua](../lua/plugins/qol/llm/keymaps.lua)、[llm/extensions/ask.lua](../lua/plugins/qol/llm/extensions/ask.lua)、[llm/extensions/commit_msg.lua](../lua/plugins/qol/llm/extensions/commit_msg.lua)、[llm/extensions/formula_recognition.lua](../lua/plugins/qol/llm/extensions/formula_recognition.lua)、[http-client.lua](../lua/plugins/coding/http-client.lua)、[live-preview.lua](../lua/plugins/qol/live-preview.lua)。

## 帮助与退出

- `<leader>?`（`n`）显示当前缓冲区局部映射：[which-key.lua](../lua/plugins/qol/which-key.lua)。其中 `spec` 只是提示分组，`icons.keys` 只是图标文本，不创建动作。
- `<leader>xl/xq`（`n`）切换 location/quickfix 窗口；`[q/]q` 跳转 quickfix；`<leader>qq` 退出所有窗口；`<leader>ui/uI` 检查位置/Treesitter 树：[general.lua](../lua/config/keymaps/general.lua)。
- Alpha 首页（`n`）的 `s/S/L/q` 恢复会话/选择会话/打开 Lazy/退出：[dashboard.lua](../lua/plugins/ui/dashboard.lua)。
- 遇到覆盖可运行 `:verbose nmap <按键>`、`:verbose imap <按键>` 或对应模式命令，检查当前映射与最后设置位置。
