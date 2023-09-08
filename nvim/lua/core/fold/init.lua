local expr_lsp = require("core.fold.fold_lsp")
local expr_ts = require("core.fold.fold_treesitter")

local bufvar_fold = "my_fold"  -- 记录 fold 是否设置成功

--- 使用 lsp 来 fold, 如果 lsp_fold 设置成功则返回 true.
local function fold_lsp(client, bufnr, win_id)
  return expr_lsp.set_fold(client, bufnr, win_id)
end

--- 使用 treesitter 来 fold, 如果 treesitter_fold 设置成功则返回 true.
local function fold_treesitter(bufnr, win_id)
  return expr_ts.set_fold(bufnr, win_id)
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
    --- - foldexpr 是 nvim-treesitter 设置. LspAttach 在 fold-treesitter 设置之后触发, 覆盖 treesitter 设置. 这种情况下会造成2次 fold 计算.
    if vim.wo[win_id].foldmethod == 'manual' or vim.b[params.buf][bufvar_fold] == 'treesitter' then
      if fold_lsp(client, params.buf, win_id) then
        vim.b[params.buf][bufvar_fold] = "lsp"
        return
      end
    end
  end,
  desc = "Fold: fold-lsp when LspAttach",
})

--- fallback to nvim-treesitter foldexpr 延迟触发 --------------------------------------------------
vim.api.nvim_create_autocmd("BufWinEnter", {
  pattern = {"*"},
  callback = function(params)
    local win_id = vim.api.nvim_get_current_win()

    --- NOTE: lsp_foldexpr 没有设置成功的情况
    if vim.b[params.buf][bufvar_fold] == "lsp" and vim.wo[win_id].foldmethod == 'manual' then
      vim.api.nvim_win_call(win_id, function()
        --- 每次 `set foldmethod=expr` 都会重新执行 foldexpr
        vim.opt_local.foldmethod = 'expr'
      end)
    end

    --- NOTE: defer_fn() 延迟 n(ms) 执行, 确保在 lsp 不存在的情况下设置为 fold-treesitter.
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
--- 先尝试 fold-lsp, 如果不存在则尝试 fold-treesitter
local function fold(win_id)
  local bufnr = vim.api.nvim_win_get_buf(win_id)
  local clients = vim.lsp.get_active_clients({bufnr=bufnr})
  for _, client in ipairs(clients) do
    if fold_lsp(client, bufnr, win_id) then
      vim.b[bufnr][bufvar_fold] = "lsp"
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



