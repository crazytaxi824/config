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

