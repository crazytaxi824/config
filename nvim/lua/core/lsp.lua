--- 加载 LSP 相关自定义设置.
--- `:help vim.lsp.set_log_level()`, 影响 `:LspLog`.
if __Debug_Neovim.lsp or __Debug_Neovim.null_ls then
  vim.lsp.set_log_level("DEBUG")
else
  vim.lsp.set_log_level("OFF")
end



