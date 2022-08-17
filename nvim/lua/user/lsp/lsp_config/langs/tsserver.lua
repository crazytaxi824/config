-- https://github.com/neovim/nvim-lspconfig/blob/master/doc/server_configurations.md#tsserver
return {
  --cmd = { "typescript-language-server", "--stdio" },
  --filetypes = { "javascript", "javascriptreact", "javascript.jsx", "typescript", "typescriptreact", "typescript.tsx" },
  init_options = {
    --hostInfo = "neovim",
    npmLocation = "npm",  -- VVI: FIX `:LspLog` [tsserver] ERROR, https://github.com/Microsoft/TypeScript/issues/23924
  },
}
