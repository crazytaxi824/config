--- nvim-treesitter 提供的 fold 方法 'nvim_treesitter#foldexpr()', 不是很稳定.

local M = {}

M.set_foldexpr = function(bufnr, win_id)
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

  vim.api.nvim_win_call(win_id, function ()
    vim.opt_local.foldexpr = 'nvim_treesitter#foldexpr()'
    vim.opt_local.foldtext = 'v:lua.require("user.fold.foldtext").foldtext()'
    vim.opt_local.foldmethod = 'expr'
  end)

  return true  -- 设置成功
end

return M
