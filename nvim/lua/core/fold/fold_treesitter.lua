--- nvim-treesitter 提供的 fold 方法 'nvim_treesitter#foldexpr()', 不是很稳定.

local M = {}

M.foldexpr_str = 'nvim_treesitter#foldexpr()'
M.foldtext_str = 'v:lua.require("core.fold.foldtext").foldtext()'

M.set_fold = function(bufnr, win_id)
  --- 获取所有 parsers
  local nvim_ts_ok, nvim_ts_parsers = pcall(require, "nvim-treesitter.parsers")
  if not nvim_ts_ok then
    return
  end

  --- treesitter 是否有对应的 parser.
  local has_parser = nvim_ts_parsers.has_parser(nvim_ts_parsers.get_buf_lang(bufnr))
  if not has_parser then
    return
  end

  --- VVI: 可能在异步函数中执行, 必须检查 window 中的 buffer 是否已经被改变.
  if vim.api.nvim_win_is_valid(win_id) and vim.api.nvim_win_get_buf(win_id) == bufnr then
    vim.api.nvim_set_option_value('foldexpr', M.foldexpr_str, { scope = 'local', win = win_id })
    vim.api.nvim_set_option_value('foldtext', M.foldtext_str, { scope = 'local', win = win_id })
    vim.api.nvim_set_option_value('foldmethod', 'expr', { scope = 'local', win = win_id })
  end
end

return M
