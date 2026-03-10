# statusline / tabline

主要是通过修改 `vim.wo[win].statusline`, `vim.go.tabline` 来实现.

```
%#hl_secA_start# SEC_A \
%#hl_secB_start# SEC_B \
%#hl_secCX_start# SEC_C %<%= SEC_X \
%#hl_secB_start# SEC_Y \
%#hl_secA_start# SEC_Z
```

## Seperator

left half  transition: `▌` U+258C. fg(left_color), bg(right_color)
right half transition: `▐` U+2590. fg(right_color), bg(left_color)

## symbol

- `%-`  左对齐, 默认右对齐
- `%#`  highlight group. `%#highlight#`
- `%<`  保留左侧内容, 丢弃右侧超出的部分. truncate line (from here) if too long.
- `%=`  Separation point between alignment sections.

- `%f`, `%F`  [filepath]|[full filepath]
- `%w`  [Preview]
- `%r`  [ReadOnly]
- `%h`  [Help]
- `%y`  [filetype]
- `%q`  [Quickfix List], [Location List]

### string

eg: `%-0{minwid}.{maxwid}{item}`
- `[%f]`    右对齐 `[filename]`
- `[%-f]`   左对齐 `[filename]`
- `[%60f]`   右对齐, minwidth 60 字符, `[     filename]`
- `[%-60f]`  左对齐, minwidth 60 字符, `[filename     ]`
- `[%.60f]`  右对齐, maxwidth 60 字符, `[filename]`
- `[%-.60f]` 左对齐, maxwidth 60 字符, `[filename]`
- `[%60.60f]`  右对齐, minwidth|maxwidth 60 字符, `[     filename]`
- `[%-60.60f]` 左对齐, minwidth|maxwidth 60 字符, `[filename     ]`

自定义 string:
- `[%60(abc%)]`  右对齐 `[     abc]`

### number

eg: `%-0{minwid}.{maxwid}{item}`
- `[%03p%%]`    右对齐, `0` 填充左侧, `3` minwidth=3, `p` line-percentage, `%%` 显示为百分号.

## events

只要发生以下操作，两者通常都会刷新：
- 光标移动: 当你移动光标（`CursorMoved`, `CursorMovedI`）时. 这是为了实时更新状态栏中的行号/列号
- 输入字符: 在插入模式下输入任何内容。
- 模式切换: 从 Normal 进入 Insert，或者进入 Visual 模式等
- 窗口/标签页操作: 创建新窗口、改变窗口大小`VimResized`, 切换标签页
- Buffer 改变: 保存文件`BufWritePost`, 修改内容导致 modified 标志位变化

statusline 特有刷新:
- 焦点切换: 当你在不同窗口间跳转时（`WinEnter`, `WinLeave`）。通常非活动窗口的 statusline 会切换到 nc (Non-current) 高亮
- 外部变量改变: 如果你在 statusline 中引用了全局变量或插件变量（如 Git 分支、LSP 诊断），当这些插件通过 vim.opt.statusline = ... 重新赋值时会刷新
- 强制刷新: 执行 `:redrawstatus` 命令时

tabline 特有刷新: (Tabline 是全局的，它的刷新频率通常低于 Statusline)
- 标签页增减: 执行 `:tabnew`, `:tabclose`, `:tabmove`
- Buffer 增减: 如果你使用的是类似 bufferline.nvim 的插件（将 tabline 当作 buffer 列表用），那么当 `BufAdd`, `BufDelete`, `BufWipeout` 发生时会触发刷新
- 强制刷新: 执行 `:redrawtabline` 命令时

## Components

### diagnostic

`:lua vim.print(vim.diagnostic.get(0))`  获取所有 HINT, INFO, WARN, ERROR 所有的 diagnostic.

`:lua vim.print(vim.diagnostic.get(0, {severity = vim.diagnostic.severity.ERROR}))`  只获取 ERROR diagnostic.

### mode

```
local mode_map = {
    n  = "NORMAL",
    no  = "O-PENDING",  -- eg: press `d` motion 后触发
    nov = "O-PENDING",
    noV = "O-PENDING",
    ["\22no"]   = "O-PENDING",  -- noCTRL-V
    niI = "NORMAL",  -- INSERT mode press `Ctrl-O`
    niR = "NORMAL",  -- REPLACE mode press `Ctrl-O`
    niV = "NORMAL",  -- Virtual-Replace mode `gR` press `Ctrl-O`, V-REPLACE 按屏幕显示宽度替换，考虑 tab、全角字符等占用的实际显示宽度.
    nt  = "NORMAL",  -- terminal normal mode, 按 `t_Ctrl-\_Ctrl-N` 退出 Terminal 模式.
    ntT = "NORMAL",  -- terminal `t_CTRL-\_CTRL-O` mode

    v  = "VISUAL",
    vs = "VISUAL",  -- Select 模式下 `Ctrl-O` 的临时 Visual
    V  = "V-LINE",
    Vs = "V-LINE",  -- S-LINE 模式下 `Ctrl-O` 的临时 V-LINE
    ["\22"]  = "V-BLOCK",  -- Ctrl-V
    ["\22s"] = "V-BLOCK",  -- Select mode 下 `Ctrl-V`

    s  = "SELECT",
    S  = "S-LINE",
    ["\19"] = "S-BLOCK",  -- Ctrl-S

    i  = "INSERT",
    ic = "INSERT",  -- completion, 按 `Ctrl-N` 或 `Ctrl-P` 触发补全时进入
    ix = "INSERT",  -- completion, 按 `Ctrl-X` 进入补全子模式，然后再按 `Ctrl-N/Ctrl-F/Ctrl-L` 等触发

    R   = "REPLACE",
    Rc  = "REPLACE",    -- completion
    Rx  = "REPLACE",    -- Ctrl-X completion
    Rv  = "V-REPLACE",
    Rvc = "V-REPLACE",  -- completion
    Rvx = "V-REPLACE",  -- Ctrl-X completion

    c  = "COMMAND",
    cr  = "COMMAND",    -- overstrike, Command 模式下按 Insert 键切换到 overstrike（覆盖输入）模式
    cv  = "EX",         -- Vim Ex mode, 按 `gQ` 进入 Vim Ex 模式
    cvr = "EX",         -- Ex mode overstrike, Ex 模式下按 Insert 键切换到 overstrike 模式

    t  = "TERMINAL",
}

local mode = mode_map[vim.fn.mode()] or vim.fn.mode()
```

