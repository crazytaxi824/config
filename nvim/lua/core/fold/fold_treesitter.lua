--- nvim-treesitter 提供的 fold 方法 'nvim_treesitter#foldexpr()', 不是很稳定.

local M = {}

M.foldexpr_str = 'v:lua.vim.treesitter.foldexpr()'
M.foldtext_str = 'v:lua.require("core.fold.foldtext").foldtext()'

M.set_fold = function(bufnr, win_id)
  --- VVI: 可能在异步函数中执行, 必须检查 window 中的 buffer 是否已经被改变.
  if not vim.api.nvim_win_is_valid(win_id) or vim.api.nvim_win_get_buf(win_id) ~= bufnr then
    return
  end

  --- treesitter 是否有对应的 parser.
  local status_ok, lang_tree = pcall(vim.treesitter.get_parser, bufnr)
  if not status_ok then
    return
  end

  vim.api.nvim_set_option_value('foldexpr', M.foldexpr_str, { scope = 'local', win = win_id })
  vim.api.nvim_set_option_value('foldtext', M.foldtext_str, { scope = 'local', win = win_id })
  vim.api.nvim_set_option_value('foldmethod', 'expr', { scope = 'local', win = win_id })
end

return M
