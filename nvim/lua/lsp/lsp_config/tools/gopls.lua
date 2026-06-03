-- 官方文档
-- https://github.com/neovim/nvim-lspconfig/blob/master/doc/configs.md#gopls
-- https://github.com/golang/tools/blob/master/gopls/doc/editor/vim.md#neovim-config

---@type vim.lsp.Config
return {
  -- root_dir: https://github.com/neovim/nvim-lspconfig/blob/e7380ece256d1fb1df3b3a3c619ee3b9b52ae2b3/lsp/gopls.lua#L88

  -- NOTE: semantic tokens setting: gopls < v0.22: in settings, >= v0.22: in init_options
  init_options = {
    semanticTokens = true,  -- 默认 false.
  },

  -- https://github.com/golang/tools/blob/master/gopls/doc/settings.md
  settings = {
    gopls = {
      usePlaceholders = true,
      staticcheck = false,
      vulncheck = "Imports",  -- check Go Vulnerability Database check known Vulnerability in your dependencies.
    },
  },
}
