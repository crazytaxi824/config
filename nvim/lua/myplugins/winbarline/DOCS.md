# use overline instead of indicator

目前 overline 无法自定义颜色, 所以还不能作为 active buffer indicator 使用.

```lua
vim.api.nvim_set_hl(0, "MyOverlineText", {
  fg = "#98c379",
  sp = "#0000FF",   -- 对 underline 起作用, 但是对 overline 不起作用
  overline = true,
})

vim.opt.showtabline = 2
vim.o.tabline = "%#MyOverlineText# ┃ 文字 ┃ %#FormatReset#"
```

