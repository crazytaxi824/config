local hl = {
  --- base color
  default = {
    ctermfg=Colors.g246.c, fg=Colors.g246.g,
    ctermbg=Colors.g236.c, bg=Colors.g236.g,
  },
  selected = {
    ctermfg=Colors.gold_fn.c, fg=Colors.gold_fn.g,
    ctermbg=Colors.black.c, bg=Colors.black.g,
    bold = true,
  },
  tabnr = {
    ctermfg=Colors.black.c, fg=Colors.black.g,
    ctermbg=Colors.yellow.c, bg=Colors.yellow.g,
    bold = true,
  },

  --- override base color
  indicator = {
    ctermfg=Colors.cyan.c, fg=Colors.cyan.g,
  },
  modified = {
    ctermfg=Colors.cyan.c, fg=Colors.cyan.g,
    bold = true,
  },
  diagnostic_error = {
    ctermfg=Colors.red.c, fg=Colors.red.g,
    bold = true,
  },
  diagnostic_warn = {
    ctermfg=Colors.orange.c, fg=Colors.orange.g,
    bold = true,
  },
  diagnostic_info = {
    ctermfg=Colors.blue.c, fg=Colors.blue.g,
    bold = true,
  },
  diagnostic_hint = {
    ctermfg=Colors.hint_grey.c, fg=Colors.hint_grey.g,
    bold = true,
  },
}


vim.api.nvim_set_hl(0, "MyWinBarLineBufferSelected",  hl.selected)
vim.api.nvim_set_hl(0, "MyWinBarLineBufferSelectedIndicator", vim.tbl_extend('force', hl.selected, hl.indicator))
vim.api.nvim_set_hl(0, "MyWinBarLineBufferSelectedModified", vim.tbl_extend('force', hl.selected, hl.modified))
vim.api.nvim_set_hl(0, "MyWinBarLineBufferSelectedError", vim.tbl_extend('force', hl.selected, hl.diagnostic_error))
vim.api.nvim_set_hl(0, "MyWinBarLineBufferSelectedWarn",  vim.tbl_extend('force', hl.selected, hl.diagnostic_warn))
vim.api.nvim_set_hl(0, "MyWinBarLineBufferSelectedInfo",  vim.tbl_extend('force', hl.selected, hl.diagnostic_info))
vim.api.nvim_set_hl(0, "MyWinBarLineBufferSelectedHint",  vim.tbl_extend('force', hl.selected, hl.diagnostic_hint))

vim.api.nvim_set_hl(0, "MyWinBarLineBuffer", hl.default)
vim.api.nvim_set_hl(0, "MyWinBarLineBufferIndicator", vim.tbl_extend('force', hl.default, hl.indicator))
vim.api.nvim_set_hl(0, "MyWinBarLineBufferModified", vim.tbl_extend('force', hl.default, hl.modified))
vim.api.nvim_set_hl(0, "MyWinBarLineBufferError", vim.tbl_extend('force', hl.default, hl.diagnostic_error))
vim.api.nvim_set_hl(0, "MyWinBarLineBufferWarn",  vim.tbl_extend('force', hl.default, hl.diagnostic_warn))
vim.api.nvim_set_hl(0, "MyWinBarLineBufferInfo",  vim.tbl_extend('force', hl.default, hl.diagnostic_info))
vim.api.nvim_set_hl(0, "MyWinBarLineBufferHint",  vim.tbl_extend('force', hl.default, hl.diagnostic_hint))

vim.api.nvim_set_hl(0, "MyWinBarLineTab", hl.tabnr)





