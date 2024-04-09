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

  -- vim.api.nvim_win_call(win_id, function ()
  --   vim.opt_local.foldexpr = M.foldexpr_str
  --   vim.opt_local.foldtext = M.foldtext_str
  --   vim.opt_local.foldmethod = 'expr'
  -- end)
  local opts = { scope = 'local', win = win_id }
  vim.api.nvim_set_option_value('foldexpr', M.foldexpr_str, opts)
  vim.api.nvim_set_option_value('foldtext', M.foldtext_str, opts)
  vim.api.nvim_set_option_value('foldmethod', 'expr', opts)

  return true  -- 设置成功
end

return M