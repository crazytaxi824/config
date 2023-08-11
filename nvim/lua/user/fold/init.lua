local expr_lsp = require("user.fold.fold_lsp")
local expr_ts = require("user.fold.fold_treesitter")

--- 使用 lsp 来 fold, 如果 lsp_fold 设置成功则返回 true.
local function lsp_fold(client, bufnr)
  return expr_lsp.set_foldexpr(client, bufnr)
end

--- 使用 treesitter 来 fold, 如果 treesitter_fold 设置成功则返回 true.
local function treesitter_fold(bufnr)
  if expr_ts then
    return expr_ts.set_foldexpr(bufnr)
  end
end

--- foldmethod=indent
local function indent_fold(bufnr)
  vim.api.nvim_buf_call(bufnr, function()
    vim.opt_local.foldmethod = 'indent'
  end)
end

--- TODO: 这里必须 lsp 才能触发 fold 设置.
vim.api.nvim_create_autocmd("LspAttach", {
  pattern = {"*"},
  callback = function(params)
    local client = vim.lsp.get_client_by_id(params.data.client_id)
    if not lsp_fold(client, params.buf)  -- try lsp_fold
      and not treesitter_fold(params.buf) -- try treesitter_fold
    then
      indent_fold(params.buf)  -- fallback to fold-indent
    end
  end,
  desc = "set fold when LspAttach"
})



