--- `:hi WinBar`, `:hi WinBarNC`

--- buffer -----------------------------------------------------------------------------------------
vim.api.nvim_set_hl(0, "MyWinBarLineBuffer", {
  ctermfg=Colors.g246.c, fg=Colors.g246.g,
  ctermbg=Colors.g236.c, bg=Colors.g236.g,
})

vim.api.nvim_set_hl(0, "MyWinBarLineBufferModified", {
  ctermfg=Colors.cyan.c, fg=Colors.cyan.g,
  ctermbg=Colors.g236.c, bg=Colors.g236.g,
})

--- cursor 在当前 window 时, buffer filename 颜色
vim.api.nvim_set_hl(0, "MyWinBarLineBufferSelected", {
  ctermfg=Colors.gold_fn.c, fg=Colors.gold_fn.g,
  ctermbg=Colors.black.c, bg=Colors.black.g,
  bold = true,
})

vim.api.nvim_set_hl(0, "MyWinBarLineBufferSelectedModified", {
  ctermfg=Colors.cyan.c, fg=Colors.cyan.g,
  ctermbg=Colors.black.c, bg=Colors.black.g,
  bold = true,
})


--- indicator --------------------------------------------------------------------------------------
vim.api.nvim_set_hl(0, "MyWinBarLineIndicatorSelected", {
  ctermfg=Colors.cyan.c, fg=Colors.cyan.g,
  ctermbg=Colors.black.c, bg=Colors.black.g,
})
vim.api.nvim_set_hl(0, "MyWinBarLineIndicatorVisible", {
  ctermfg=Colors.cyan.c, fg=Colors.cyan.g,
  ctermbg=Colors.black.c, bg=Colors.black.g,
})


--- separator --------------------------------------------------------------------------------------
vim.api.nvim_set_hl(0, "MyWinBarLineTab", {
  ctermfg=Colors.black.c, fg=Colors.black.g,
  ctermbg=Colors.yellow.c, bg=Colors.yellow.g,
})

--- diagnostic -------------------------------------------------------------------------------------
vim.api.nvim_set_hl(0, "MyWinBarLineDiagnosticError", {
  ctermfg=Colors.red.c, fg=Colors.red.g,
  ctermbg=Colors.g236.c, bg=Colors.g236.g,
  bold = true,
})

vim.api.nvim_set_hl(0, "MyWinBarLineDiagnosticWarn", {
  ctermfg=Colors.orange.c, fg=Colors.orange.g,
  ctermbg=Colors.g236.c, bg=Colors.g236.g,
  bold = true,
})

vim.api.nvim_set_hl(0, "MyWinBarLineDiagnosticInfo", {
  ctermfg=Colors.blue.c, fg=Colors.blue.g,
  ctermbg=Colors.g236.c, bg=Colors.g236.g,
  bold = true,
})

vim.api.nvim_set_hl(0, "MyWinBarLineDiagnosticHint", {
  ctermfg=Colors.hint_grey.c, fg=Colors.hint_grey.g,
  ctermbg=Colors.g236.c, bg=Colors.g236.g,
  bold = true,
})


