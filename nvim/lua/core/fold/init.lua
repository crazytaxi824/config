local expr_lsp = require("core.fold.fold_lsp")
local expr_ts = require("core.fold.fold_treesitter")
local filetype_lsp = require("lsp.svr_list").filetype_lsp

--- 使用 lsp 来 fold, 如果 lsp_fold 设置成功则返回 true.
local function fold_lsp(bufnr, win_id, opts)
  expr_lsp.lsp_fold_request(bufnr, win_id, opts)
end

--- 使用 treesitter 来 fold, 如果 treesitter_fold 设置成功则返回 true.
local function fold_treesitter(bufnr, win_id)
  expr_ts.set_fold(bufnr, win_id)
end

--- create fold augroup
local g_id = vim.api.nvim_create_augroup("my_fold", { clear = true })

--- NOTE: 根据 "lsp.lsp_config.lsp_list".filetype_lsp 判断使用 lsp fold OR treesitter fold.
--- 如果 lsp 不支持 'textDocument/foldingRange' 则尝试 treesitter fold.
--- LspAttach 和 FileType 执行顺序不确定.
vim.api.nvim_create_autocmd("LspAttach", {
  group = g_id,
  pattern = { "*" },
  callback = function(params)
    local win_id = vim.api.nvim_get_current_win()

    --- 确保当前 focused window 没有加载其他 buffer.
    if vim.api.nvim_win_get_buf(win_id) ~= params.buf then
      return
    end

    --- foldmethod 可能是 marker, indent, expr...
    --- foldmethod ~= manual 说明其他插件已经设置过 foldmethod.
    if vim.wo[win_id].foldmethod ~= "manual" then
      return
    end

    --- fold 已经设置成功了.
    if vim.wo[win_id].foldexpr ~= "0" then
      return
    end

    local client = vim.lsp.get_client_by_id(params.data.client_id)
    if not client then
      return
    end

    --- 如果 lsp 和 filetype 不对应则返回, 防止 null-ls 等 lsp 工具参与设置 fold.
    if
      vim.tbl_contains(filetype_lsp[vim.bo[params.buf].filetype], client.name)
      and client:supports_method("textDocument/foldingRange", params.buf)
    then
      fold_lsp(params.buf, win_id, { treesitter_fallback = true })
    end
  end,
  desc = "Fold: fold-lsp when LspAttach with treesitter_fallback",
})

vim.api.nvim_create_autocmd("FileType", {
  group = g_id,
  pattern = { "*" },
  callback = function(params)
    --- 如果是有 lsp 的 filetype 则等 LspAttach 时设置 fold.
    if vim.tbl_contains(vim.tbl_keys(filetype_lsp), vim.bo[params.buf].filetype) then
      return
    end

    local win_id = vim.api.nvim_get_current_win()

    --- 确保当前 focused window 没有加载其他 buffer.
    if vim.api.nvim_win_get_buf(win_id) ~= params.buf then
      return
    end

    --- foldmethod 可能是 marker, indent, expr...
    --- foldmethod ~= manual 说明其他插件已经设置过 foldmethod.
    if vim.wo[win_id].foldmethod ~= "manual" then
      return
    end

    --- fold 已经设置成功了.
    if vim.wo[win_id].foldexpr ~= "0" then
      return
    end

    --- try fold-treesitter
    fold_treesitter(params.buf, win_id)
  end,
  desc = "Fold: fold-treesitter when FileType",
})

--- 重新设置 foldmethod=expr 来 update foldexpr().
--- FileChangedShellPost 用于 formatter 或 linter 使用 shell cmd 修改文件内容后执行.
vim.api.nvim_create_autocmd({ "BufWritePost", "FileChangedShellPost" }, {
  group = g_id,
  pattern = { "*" },
  callback = function(params)
    local win_id = vim.api.nvim_get_current_win()

    --- 确保当前 focused window 没有加载其他 buffer.
    if vim.api.nvim_win_get_buf(win_id) ~= params.buf then
      return
    end

    --- 如果是 lsp fold 则重新计算 foldlevel.
    if vim.wo[win_id].foldexpr == expr_lsp.foldexpr_str then
      fold_lsp(params.buf, win_id) --- NOTE: 这里不使用 treesitter_fallback
      return
    end

    --- 其他 foldexpr 情况下, 重新设置 foldmethod 用于重新 update (treesitter) foldexpr
    if vim.wo[win_id].foldmethod == "expr" then
      --- VVI: 使用 schedule() 保证最后执行 `set foldmethod=expr`
      vim.schedule(function()
        vim.api.nvim_set_option_value("foldmethod", "expr", { scope = "local", win = win_id })
      end)
    end
  end,
  desc = "Fold: update foldexpr() when file content changes",
})

--- delete foldexpr cache, 避免内存使用无限扩大.
vim.api.nvim_create_autocmd("BufWipeout", {
  group = g_id,
  pattern = { "*" },
  callback = function(params)
    expr_lsp.clear_cache(params.buf)
  end,
  desc = "Fold: clear lsp-fold cache",
})

--- User Command 手动强制重新设置 fold -------------------------------------------------------------
vim.api.nvim_create_user_command("FoldReset", function()
  local win_id = vim.api.nvim_get_current_win()
  local bufnr = vim.api.nvim_win_get_buf(win_id)

  --- 如果有 lsp 则尝试 lsp fold, fallback to treesitter fold.
  local clients = vim.lsp.get_clients({ bufnr = bufnr })
  for _, client in ipairs(clients) do
    --- 如果 lsp 和 filetype 不对应则返回, 防止 null-ls 等 lsp 工具参与设置 fold.
    if
      vim.tbl_contains(filetype_lsp[vim.bo[bufnr].filetype], client.name)
      and client:supports_method("textDocument/foldingRange", bufnr)
    then
      fold_lsp(bufnr, win_id, { treesitter_fallback = true })
      vim.api.nvim_set_option_value('foldlevel', 0, { scope = 'local', win = win_id })
      return
    end
  end

  --- 没有 lsp 直接尝试 treesitter fold
  fold_treesitter(bufnr, win_id)
  vim.api.nvim_set_option_value('foldlevel', 0, { scope = 'local', win = win_id })
end, { bang = true, bar = true })



