local expr_lsp = require("user.fold.fold_lsp")
local expr_ts = require("user.fold.fold_treesitter")

local M = {}

M.lsp_fold = function(bufnr)
  expr_lsp.set_foldexpr(bufnr)
end

M.treesitter_fold = function(bufnr)
  if expr_ts then
    return expr_ts.set_foldexpr(bufnr)
  end
end

M.indent_fold = function(bufnr)
  vim.api.nvim_buf_call(bufnr, function()
    vim.opt_local.foldmethod = 'indent'
  end)
end

return M
