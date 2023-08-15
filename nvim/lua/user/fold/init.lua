local expr_lsp = require("user.fold.fold_lsp")
local expr_ts = require("user.fold.fold_treesitter")

local bufvar_fold = "my_fold"  -- 记录 fold 是否设置成功

--- 使用 lsp 来 fold, 如果 lsp_fold 设置成功则返回 true.
local function fold_lsp(client, bufnr, win_id)
  --- lsp 不支持 foldingRange
  if not client.server_capabilities or not client.server_capabilities.foldingRangeProvider then
    return
  end

  --- init foldexpr
  expr_lsp.set_fold(bufnr, win_id)

  --- update foldexpr
  --- 文件 save 后重新计算 foldexpr.
  local g_id = vim.api.nvim_create_augroup('my_lsp_fold_' .. bufnr, {clear=true})
  vim.api.nvim_create_autocmd("BufWritePost", {
    group = g_id,
    buffer = bufnr,
    callback = function(params)
      --- set_fold() 时会重新设置 `set foldexpr` 会触发 foldexpr 重新计算.
      expr_lsp.set_fold(params.buf, vim.api.nvim_get_current_win())
    end,
    desc = "set foldexpr for lsp textDocument/foldingRange"
  })

  --- delete foldexpr cache & augroup
  vim.api.nvim_create_autocmd("BufWipeout", {
    group = g_id,
    buffer = bufnr,
    callback = function(params)
      expr_lsp.clear_cache(params.buf)
      vim.api.nvim_del_augroup_by_id(g_id)
    end,
    desc = "delete foldexpr textDocument/foldingRange augroup"
  })

  return true
end

--- 使用 treesitter 来 fold, 如果 treesitter_fold 设置成功则返回 true.
local function fold_treesitter(bufnr, win_id)
  return expr_ts.set_foldexpr(bufnr, win_id)
end

--- lsp 加载速度太慢的情况下, 在 LspAttach 时覆盖 treesitter 的设置 --------------------------------
--- NOTE: 重复设置 foldexpr 会造成多次 foldexpr 的计算.
--- 所以尽量避免设置 foldexpr = treesitter 之后再设置 foldexpr = lsp
vim.api.nvim_create_autocmd("LspAttach", {
  pattern = {"*"},
  callback = function(params)
    local win_id = vim.api.nvim_get_current_win()
    local client = vim.lsp.get_client_by_id(params.data.client_id)

    --- 两种情况:
    --- - foldmethod 未被设置. LspAttach 在 defer_fn 之前触发.
    --- - foldexpr 是 nvim-treesitter 设置. LspAttach 在 fold-treesitter 设置之后触发.
    if vim.wo[win_id].foldmethod == 'manual' or vim.b[params.buf][bufvar_fold] == 'treesitter' then
      if fold_lsp(client, params.buf, win_id) then
        vim.b[params.buf][bufvar_fold] = client.name
        return
      end
    end
  end,
  desc = "Fold: fold-lsp when LspAttach",
})

--- fallback to nvim-treesitter foldexpr 延迟触发 --------------------------------------------------
--- 保证 lsp 不存在的情况下设置为 fold-treesitter.
vim.api.nvim_create_autocmd("BufWinEnter", {
  pattern = {"*"},
  callback = function(params)
    local win_id = vim.api.nvim_get_current_win()
    vim.defer_fn(function()
      --- 执行 `set foldxxx` 时判断 win_id 是否存在.
      if not vim.api.nvim_win_is_valid(win_id) then
        return
      end

      --- window 中加载的 buffer 没有改变.
      if vim.api.nvim_win_get_buf(win_id) ~= params.buf then
        return
      end

      --- foldmethod ~= manual 说明其他插件已经设置过 foldmethod.
      if vim.wo[win_id].foldmethod ~= 'manual' then
        return
      end

      --- fold 已经设置成功.
      if vim.b[params.buf][bufvar_fold] then
        return
      end

      --- try fold-treesitter
      if fold_treesitter(params.buf, win_id) then
        vim.b[params.buf][bufvar_fold] = 'treesitter'
      end
    end, 800)  -- (ms)
  end,
  desc = "Fold: fallback to fold-treesitter",
})

--- 手动强制重新设置 fold --------------------------------------------------------------------------
local function fold(win_id)
  local bufnr = vim.api.nvim_win_get_buf(win_id)
  local clients = vim.lsp.get_active_clients({bufnr=bufnr})
  for _, client in ipairs(clients) do
    if fold_lsp(client, bufnr, win_id) then
      vim.b[bufnr][bufvar_fold] = client.name
      return
    end
  end

  if fold_treesitter(bufnr, win_id) then
    vim.b[bufnr][bufvar_fold] = 'treesitter'
  end
end

--- user command
vim.api.nvim_create_user_command("Fold", function()
  fold(vim.api.nvim_get_current_win())
end, {bang=true, bar=true})



