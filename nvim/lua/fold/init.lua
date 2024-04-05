local expr_lsp = require("fold.fold_lsp")
local expr_ts = require("fold.fold_treesitter")

local lsp_list = require("lsp.lsp_config.lsp_list")

--- map[filetype] = lsp, 用于判断使用 lsp fold OR treesitter fold.
local filetype_lsp = {}
for lsp_svr, v in pairs(lsp_list) do
  for _, ft in ipairs(v.filetypes) do
    filetype_lsp[ft] = lsp_svr
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

--- lsp 加载速度太慢的情况下, 在 LspAttach 时覆盖 treesitter 的设置 --------------------------------
--- NOTE: 重复设置 foldexpr 会造成多次 foldexpr 的计算.
--- 所以尽量避免设置 foldexpr = treesitter 之后再设置 foldexpr = lsp
vim.api.nvim_create_autocmd("LspAttach", {
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

--- 手动强制重新设置 fold --------------------------------------------------------------------------
--- 先尝试 fold-lsp, 如果不存在则尝试 fold-treesitter
-- local function fold(win_id)
--   local bufnr = vim.api.nvim_win_get_buf(win_id)
--   local clients = vim.lsp.get_active_clients({bufnr=bufnr})
--   for _, client in ipairs(clients) do
--     if fold_lsp(client, bufnr, win_id) then
--       buf_lsp[bufnr].fold = "lsp"
--       return
--     end
--   end
--
--   if fold_treesitter(bufnr, win_id) then
--     buf_lsp[bufnr].fold = "treesitter"
--   end
-- end
--
-- --- user command
-- vim.api.nvim_create_user_command("Fold", function()
--   fold(vim.api.nvim_get_current_win())
-- end, {bang=true, bar=true})



