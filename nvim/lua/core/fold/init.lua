local expr_lsp = require("core.fold.fold_lsp")
local expr_ts = require("core.fold.fold_treesitter")
local ms = vim.lsp.protocol.Methods

--- 工具函数 ---------------------------------------------------------------------------------------

--- 检查当前 window 是否未被其他插件设置 fold
local function is_fold_unset(win_id)
  return vim.wo[win_id].foldmethod == "manual" and vim.wo[win_id].foldexpr == "0"
end

--- 检查当前 window 是否正在使用 treesitter fold
local function is_ts_fold(win_id)
  return vim.wo[win_id].foldmethod == "expr"
    and vim.wo[win_id].foldexpr == expr_ts.foldexpr_str
end

--- 在 buffer/window 上应用 fold 并重置 foldlevel
---
---@param set_fold_fn fun(bufnr: integer, win_id: integer)
---@param bufnr integer
---@param win_id integer
---@param reset_level boolean?
local function apply_fold(set_fold_fn, bufnr, win_id, reset_level)
  set_fold_fn(bufnr, win_id)
  if reset_level then
    vim.api.nvim_set_option_value("foldlevel", 0, { scope = "local", win = win_id })
  end
end

--- 从 clients 中找到第一个支持 foldingRange 的 client
---
---@param bufnr integer
---@return vim.lsp.Client?
local function get_fold_client(bufnr)
  for _, client in ipairs(vim.lsp.get_clients({ bufnr = bufnr })) do
    if client:supports_method(ms.textDocument_foldingRange, bufnr) then
      return client
    end
  end
end

--- Autocmd ----------------------------------------------------------------------------------------

--- FileType 在 LspAttach 前触发，优先尝试 treesitter fold
vim.api.nvim_create_autocmd("FileType", {
  group = vim.api.nvim_create_augroup("my_fold_ts", { clear = true }),
  pattern = "*",
  callback = function(params)
    for _, win_id in ipairs(vim.fn.win_findbuf(params.buf)) do
      if is_fold_unset(win_id) then
        apply_fold(expr_ts.set_fold, params.buf, win_id)
      end
    end
  end,
  desc = "Fold: fold-ts when FileType",
})

--- LspAttach 时，若 LSP 支持 foldingRange 则升级为 lsp fold
--- 若 lsp 不支持 foldingRange 则保持 treesitter fold
vim.api.nvim_create_autocmd("LspAttach", {
  group = vim.api.nvim_create_augroup("my_fold_lsp", { clear = true }),
  pattern = "*",
  callback = function(params)
    local client = vim.lsp.get_client_by_id(params.data.client_id)
    if not client or not client:supports_method(ms.textDocument_foldingRange, params.buf) then
      return
    end

    for _, win_id in ipairs(vim.fn.win_findbuf(params.buf)) do
      if is_fold_unset(win_id) then
        apply_fold(expr_ts.set_fold, params.buf, win_id)
      end
    end
  end,
  desc = "Fold: fold-lsp when LspAttach",
})

--- User Command -----------------------------------------------------------------------------------

local fold_subcmds = {
  --- 优先 lsp fold, fallback to treesitter fold
  auto = function(bufnr, win_id)
    local fn = get_fold_client(bufnr) and expr_lsp.set_fold or expr_ts.set_fold
    apply_fold(fn, bufnr, win_id, true)
  end,
  --- 仅 lsp fold
  lsp = function(bufnr, win_id)
    if get_fold_client(bufnr) then
      apply_fold(expr_lsp.set_fold, bufnr, win_id, true)
    end
  end,
  --- 仅 treesitter fold
  ts = function(bufnr, win_id)
    apply_fold(expr_ts.set_fold, bufnr, win_id, true)
  end,
}
fold_subcmds.treesitter = fold_subcmds.ts  -- alias

vim.api.nvim_create_user_command("Fold", function(params)
  local win_id = vim.api.nvim_get_current_win()
  local bufnr = vim.api.nvim_win_get_buf(win_id)
  local handler = fold_subcmds[params.args:lower()]
  if handler then
    handler(bufnr, win_id)
  else
    vim.notify(":Fold auto | lsp | ts", vim.log.levels.WARN)
  end
end, {
  nargs = 1,
  bang = true,
  bar = true,
  desc = "Fold: set foldmethod manually",
  complete = function()
    return { "auto", "lsp", "ts", "treesitter" }
  end,
})



