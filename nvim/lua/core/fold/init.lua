local expr_lsp = require("core.fold.fold_lsp")
local expr_ts = require("core.fold.fold_treesitter")
local ms = vim.lsp.protocol.Methods

--- NOTE: 根据 "lsp.lsp_config.lsp_list".filetype_lsp 判断使用 lsp fold OR treesitter fold.
--- 如果 lsp 不支持 'textDocument/foldingRange' 则尝试 treesitter fold.
--- FileType 在 LspAttach 前触发.
local g_id = vim.api.nvim_create_augroup("my_fold_lsp", { clear = true })
vim.api.nvim_create_autocmd("LspAttach", {
  group = g_id,
  pattern = { "*" },
  callback = function(params)
    local win_id = vim.api.nvim_get_current_win()

    --- foldmethod = "manual" | "marker" | "indent" | "expr" ...
    --- foldmethod ~= "manual" 说明其他插件已经设置过 foldmethod.
    --- foldexpr ~= "0" 说明 foldexpr 已经被设置.
    if vim.wo[win_id].foldmethod ~= "manual" or vim.wo[win_id].foldexpr ~= "0" then
      return
    end

    local client = vim.lsp.get_client_by_id(params.data.client_id)
    if not client or not client:supports_method(ms.textDocument_foldingRange, params.buf) then
      return
    end

    expr_lsp.set_fold(params.buf, win_id)
  end,
  desc = "Fold: fold-lsp when LspAttach",
})

--- User Command 手动强制重新设置 fold -------------------------------------------------------------
--- Fold auto | Fold lsp | Fold ts
vim.api.nvim_create_user_command("Fold", function(params)
  local win_id = vim.api.nvim_get_current_win()
  local bufnr = vim.api.nvim_win_get_buf(win_id)

  --- params.args: string
  --- params.fargs: list
  local arg = params.args:lower()
  if arg == "auto" then
    --- 如果有 lsp 则尝试 lsp fold, fallback to treesitter fold.
    local clients = vim.lsp.get_clients({ bufnr = bufnr })
    for _, client in ipairs(clients) do
      if client:supports_method(ms.textDocument_foldingRange, bufnr) then
        expr_lsp.set_fold(bufnr, win_id)
        vim.api.nvim_set_option_value('foldlevel', 0, { scope = 'local', win = win_id })
        return
      end
    end

    --- 没有 lsp 直接尝试 treesitter fold
    expr_ts.set_fold(bufnr, win_id)
    vim.api.nvim_set_option_value('foldlevel', 0, { scope = 'local', win = win_id })
    return

  elseif arg == "lsp" then
    local clients = vim.lsp.get_clients({ bufnr = bufnr })
    for _, client in ipairs(clients) do
      if client:supports_method(ms.textDocument_foldingRange, bufnr) then
        expr_lsp.set_fold(bufnr, win_id)
        vim.api.nvim_set_option_value('foldlevel', 0, { scope = 'local', win = win_id })
        return
      end
    end
    return

  elseif arg == "ts" or arg == "treesitter" then
    expr_ts.set_fold(bufnr, win_id)
    vim.api.nvim_set_option_value('foldlevel', 0, { scope = 'local', win = win_id })
    return
  end

  vim.notify("Fold auto | Fold lsp | Fold ts")
end, {
  nargs = 1,
  bang = true,
  bar = true,
  desc = "Fold: set foldmethod manually",
})



