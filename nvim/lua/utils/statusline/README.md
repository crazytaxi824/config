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
- `%<`  从左侧开始截断. truncate line (from here) if too long.
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
