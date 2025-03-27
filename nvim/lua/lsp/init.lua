--- 加载 LSP 相关自定义设置.
require("lsp.builtin.diagnostic")   -- 加载 diagnostic 设置
--require("lsp.builtin.auto_format")  -- save(:w) 时 format, NOTE: 目前使用 Conform.nvim

--- `:help vim.lsp.set_log_level()`, 影响 `:LspLog`.
if __Debug_Neovim.lspconfig or __Debug_Neovim.null_ls then
  vim.lsp.set_log_level("DEBUG")
else
  vim.lsp.set_log_level("OFF")
end

vim.api.nvim_create_user_command("LspSetLogLevel", function(params)
  vim.lsp.set_log_level(params.args)
end, {bang=true, nargs=1})

--- NOTE: `:help lsp-events` 可以使用 lsp 专用 autocmd events.



