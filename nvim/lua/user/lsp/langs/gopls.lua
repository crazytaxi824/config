-- 官方文档
-- https://github.com/golang/tools/blob/master/gopls/doc/settings.md
-- https://github.com/golang/tools/blob/master/gopls/doc/vim.md#neovim-config
return {
  --cmd = { "gopls" },
  --filetypes = {"go", "gomod"},
  settings = {
    gopls = {
      ["ui.completion.usePlaceholders"] = true,
      ["ui.diagnostic.staticcheck"] = false,
    },
  },
}
