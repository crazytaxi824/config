local expr_lsp = require("user.fold.fold_lsp")
local expr_ts = require("user.fold.fold_treesitter")

local M = {}

--- 使用 lsp 来 fold, 如果 lsp_fold 设置成功则返回 true.
M.lsp_fold = function(client, bufnr)
  return expr_lsp.set_foldexpr(client, bufnr)
end

--- 使用 treesitter 来 fold, 如果 treesitter_fold 设置成功则返回 true.
M.treesitter_fold = function(bufnr)
  if expr_ts then
    return expr_ts.set_foldexpr(bufnr)
  end
end

--- foldmethod=indent
M.indent_fold = function(bufnr)
  vim.api.nvim_buf_call(bufnr, function()
    vim.opt_local.foldmethod = 'indent'
  end)
end

return M
