--- 加载 LSP 相关自定义设置.
require("lsp._user_handlers")  -- overwrite 默认 handlers 设置
require("lsp.diagnostic")   -- 加载 diagnostic 设置
require("lsp.auto_format")  -- save(:w) 时 format

--- `:help vim.lsp.set_log_level()`, 影响 `:LspLog`.
--- BUG: 默认为 "WARN", 但 vim.lsp 还未实现 sumneko_lua 中的 workspace/diagnostic/refresh handler,
--- 会写入大量 WARN log.
if __Debug_Neovim.lspconfig or __Debug_Neovim.null_ls then
  vim.lsp.set_log_level("DEBUG")
else
  vim.lsp.set_log_level("ERROR")
end

--- NOTE: `:help lsp-events` 可以使用 lsp 专用 autocmd events.



