local expr_lsp = require("fold.fold_lsp")
local expr_ts = require("fold.fold_treesitter")
local filetype_lsp = require("lsp.lsp_config.lsp_list").filetype_lsp

--- cache map[bufnr] = { timer = defer_fn(), cancel = vim.lsp.buf_request_all() }
local buf_timer = {}

--- DOCS: `:help vim.defer_fn` & `:help uv.new_timer()`
local function clearInterval(bufnr)
  if not buf_timer[bufnr] then
    return
  end

  --- cancel vim.lsp.buf_request_all() if it's already started.
  local cancel = buf_timer[bufnr].cancel
  if cancel then cancel() end

  --- stop & abort timer
  local timer = buf_timer[bufnr].timer
  if timer then
    timer:stop()
    timer:close()
  end
end

--- 使用 lsp 来 fold, 如果 lsp_fold 设置成功则返回 true.
local function fold_lsp(client, bufnr, win_id)
  return expr_lsp.set_fold(client, bufnr, win_id)
end

--- 使用 treesitter 来 fold, 如果 treesitter_fold 设置成功则返回 true.
local function fold_treesitter(bufnr, win_id)
  return expr_ts.set_fold(bufnr, win_id)
end

--- create fold augroup
local g_id = vim.api.nvim_create_augroup('my_fold', {clear=true})

--- NOTE: 根据 "lsp.lsp_config.lsp_list".filetype_lsp 判断使用 lsp fold OR treesitter fold.
--- 如果 lsp 不支持 'textDocument/foldingRange' 则尝试 treesitter fold.
--- LspAttach 和 FileType 执行顺序不确定.
vim.api.nvim_create_autocmd("LspAttach", {
  group = g_id,
  pattern = {"*"},
  callback = function(params)
    local win_id = vim.api.nvim_get_current_win()

    --- 确保当前 focused window 没有加载其他 buffer.
    if vim.api.nvim_win_get_buf(win_id) ~= params.buf then
      return
    end

    --- foldmethod 可能是 marker, indent, expr...
    --- foldmethod ~= manual 说明其他插件已经设置过 foldmethod.
    if vim.wo[win_id].foldmethod ~= 'manual' then
      return
    end

    --- fold 已经设置成功了.
    if vim.wo[win_id].foldexpr ~= "0" then
      return
    end

    local client = vim.lsp.get_client_by_id(params.data.client_id)

    --- 如果 lsp 和 filetype 不对应则返回, 防止 null-ls 等 lsp 工具参与设置 fold.
    if filetype_lsp[vim.bo[params.buf].filetype] ~= client.name then
      return
    end

    --- try fold-lsp
    if not fold_lsp(client, params.buf, win_id) then
      --- try fold-treesitter
      fold_treesitter(params.buf, win_id)
    end
  end,
  desc = "Fold: fold-lsp when LspAttach",
})

vim.api.nvim_create_autocmd("FileType", {
  group = g_id,
  pattern = {"*"},
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
    if vim.wo[win_id].foldmethod ~= 'manual' then
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
vim.api.nvim_create_autocmd({"BufWritePost", "FileChangedShellPost"}, {
  group = g_id,
  pattern = {"*"},
  callback = function(params)
    local win_id = vim.api.nvim_get_current_win()

    --- 确保当前 focused window 没有加载其他 buffer.
    if vim.api.nvim_win_get_buf(win_id) ~= params.buf then
      return
    end

    --- 判断是 lsp fold 还是 treesitter fold
    if vim.wo[win_id].foldexpr == expr_lsp.foldexpr_str then
      --- VVI: `:help uv.new_timer()` 使用 clearInterval(timer) 利用延迟执行避免重复执行 foldexpr() 函数.
      clearInterval(params.buf)

      --- VVI: 重新向 lsp 请求 'textDocument/foldingRange', 请求结束后设置 foldmethod=exprgg
      buf_timer[params.buf] = {}
      buf_timer[params.buf].timer = vim.defer_fn(function()
        buf_timer[params.buf].cancel = expr_lsp.lsp_fold_request(params.buf, win_id)
        buf_timer[params.buf] = nil  --- VVI: clear timer cache
      end, 300)
      return
    end

    --- 其他 foldexpr 情况下, 重新设置 foldmethod 用于重新 update (treesitter) foldexpr
    if vim.wo[win_id].foldmethod == 'expr' then
      --- VVI: `:help uv.new_timer()` 使用 clearInterval(timer) 利用延迟执行避免重复执行 foldexpr() 函数.
      clearInterval(params.buf)

      --- 重新设置 foldmethod=expr 来 update foldexpr() 结果.
      buf_timer[params.buf] = {}
      buf_timer[params.buf].timer = vim.defer_fn(function()
        vim.api.nvim_set_option_value('foldmethod', 'expr', { scope = 'local', win = win_id })
        buf_timer[params.buf] = nil  --- VVI: clear timer cache
      end, 300)
    end
  end,
  desc = "Fold: update foldexpr()"
})

--- delete foldexpr cache, 避免内存使用无限扩大.
vim.api.nvim_create_autocmd("BufWipeout", {
  group = g_id,
  pattern = {"*"},
  callback = function(params)
    expr_lsp.clear_cache(params.buf)
  end,
  desc = "Fold: clear lsp-foldexpr cache"
})

--- User Command 手动强制重新设置 fold -------------------------------------------------------------
--- 先尝试 fold-lsp, 如果不存在则尝试 fold-treesitter
local function fold(win_id)
  local bufnr = vim.api.nvim_win_get_buf(win_id)
  local clients = vim.lsp.get_active_clients({bufnr=bufnr})

  local lsp_client
  for _, c in ipairs(clients) do
    if filetype_lsp[vim.bo[bufnr].filetype] == c.name then
      lsp_client = c
      break
    end
  end

  if lsp_client then
    --- try fold-lsp
    if not fold_lsp(lsp_client, bufnr, win_id) then
      --- try fold-treesitter
      fold_treesitter(bufnr, win_id)
    end
    return
  end

  --- try fold-treesitter
  fold_treesitter(bufnr, win_id)
end

--- user command
vim.api.nvim_create_user_command("Fold", function()
  fold(vim.api.nvim_get_current_win())
end, {bang=true, bar=true})



