-- 加载 LSP 相关自定义设置.
-- `:help vim.lsp.set_log_level()`, 影响 `:LspLog`.
if __Debug.lsp or __Debug.null_ls then
  vim.lsp.log.set_level("DEBUG")
else
  vim.lsp.log.set_level("OFF")
end



