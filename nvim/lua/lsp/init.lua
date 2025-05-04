--- 加载 LSP 相关自定义设置.
--- `:help vim.lsp.set_log_level()`, 影响 `:LspLog`.
if __Debug_Neovim.lspconfig or __Debug_Neovim.null_ls then
  vim.lsp.set_log_level("DEBUG")
else
  vim.lsp.set_log_level("OFF")
end

--- NOTE: `:help lsp-events` 可以使用 lsp 专用 autocmd events.
--- LspAttach
--- LspDetach



