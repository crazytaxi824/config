local M = {}

--- NOTE: `:help vim.lsp.foldexpr()`
M.foldexpr_str = 'v:lua.vim.lsp.foldexpr()'

--- 给 bufnr, win 设置
--- `foldexpr = v:lua.vim.lsp.foldexpr()`
--- `foldmethod = expr`
---
--- @param bufnr integer
--- @param win_id integer
M.set_fold = function(bufnr, win_id)
  --- VVI: 可能在异步函数中执行, 必须检查 window 中的 buffer 是否已经被改变.
  if not vim.api.nvim_win_is_valid(win_id) or vim.api.nvim_win_get_buf(win_id) ~= bufnr then
    return
  end

  vim.api.nvim_set_option_value('foldexpr', M.foldexpr_str, { scope = 'local', win = win_id })
  vim.api.nvim_set_option_value('foldmethod', 'expr', { scope = 'local', win = win_id })
end

return M

