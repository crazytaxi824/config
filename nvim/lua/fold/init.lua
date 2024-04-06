local expr_lsp = require("fold.fold_lsp")
local expr_ts = require("fold.fold_treesitter")
local filetype_lsp = require("lsp.lsp_config.lsp_list").filetype_lsp

--- cache map[bufnr] = defer_fn timer object
local buf_timer = {}

--- DOCS: `:help vim.defer_fn` & `:help uv.new_timer()`
local function clearInterval(bufnr)
  local timer = buf_timer[bufnr]
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

local g_id = vim.api.nvim_create_augroup('my_fold', {clear=true})

--- lsp 加载速度太慢的情况下, 在 LspAttach 时覆盖 treesitter 的设置 --------------------------------
--- NOTE: 重复设置 foldexpr 会造成多次 foldexpr 的计算.
--- 所以尽量避免设置 foldexpr = treesitter 之后再设置 foldexpr = lsp
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

--- 如果 vim.b.lsp 不存在, 则直接使用 treesitter fold.
--- 如果 vim.b.lsp 存在, 则等 LspAttach 时候看 lsp client 是否支持 'textDocument/foldingRange',
--- 如果 lsp 支持则使用 lsp fold, 如果不支持则使用 treesitter fold.
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

--- update foldexpr
--- 文件 save 后重新计算 foldexpr.
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
      --- DOCS: `:help uv.new_timer()`
      --- VVI: 使用 clearInterval(timer) 利用延迟执行避免重复执行 foldexpr() 函数.
      clearInterval(params.buf)

      --- update lsp foldexpr
      buf_timer[params.buf] = vim.defer_fn(function()
        expr_lsp.lsp_fold_request(params.buf, win_id)
        buf_timer[params.buf] = nil  --- VVI: clear timer cache
      end, 300)
      return
    end

    --- 其他 foldexpr 情况下, 重新设置 foldmethod 用于重新 update (treesitter) foldexpr
    if vim.wo[win_id].foldmethod == 'expr' then
      --- DOCS: `:help uv.new_timer()`
      --- VVI: 使用 clearInterval(timer) 利用延迟执行避免重复执行 foldexpr() 函数.
      clearInterval(params.buf)

      --- VVI: 必须使用 vim.schedule() 才能 update treesitter foldexpr
      buf_timer[params.buf] = vim.defer_fn(function()
        vim.api.nvim_set_option_value('foldmethod', 'expr', { scope = 'local', win = win_id })
        buf_timer[params.buf] = nil  --- VVI: clear timer cache
      end, 300)
    end
  end,
  desc = "Fold: update foldexpr()"
})

--- delete foldexpr cache & augroup
vim.api.nvim_create_autocmd("BufWipeout", {
  group = g_id,
  pattern = {"*"},
  callback = function(params)
    expr_lsp.clear_cache(params.buf)
  end,
  desc = "Fold: clear lsp-foldexpr cache"
})

--- 手动强制重新设置 fold --------------------------------------------------------------------------
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


