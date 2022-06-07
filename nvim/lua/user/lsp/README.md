# project local LSP settings

设置文件地址
`proj_root/.nvim/settings.lua`

```lua
-- 以下所有设置都可以缺省, 只用设置需要覆盖 default setting 的项.
return {
  -- nvim-lspconfig 设置
  lsp = {
    cmd = { "gopls" },
    filetypes = { "go", "gomod", "gowork" },
    root_dir = "",  -- 默认动态获取 go.mod, go.work. .git 所在文件夹, 忽略 $GOROOT, $GOMODCACHE 文件夹.
    -- eg: gopls 设置
    settings = {
      gopls = {
        ["ui.completion.usePlaceholders"] = true,
        ["ui.diagnostic.staticcheck"] = false,
      }
    }
  },

  -- null-ls linter/diagnostics 设置
  -- eg: null_ls.diagnostics.golangci_lint.with() 设置.
  lint = {
    command = "/path/to/golangci-lint",
    cwd = "path/to/current_working_dir",
    args = { "run", ... },  -- overwrite default settings.
    extra_args = { "--config", '~/.config/lints/.golangci.yml' },
    filetypes = { "go" },
  },

  -- TODO null-ls format 设置
  -- eg: null_ls.formatting.prettier.with() 设置.
  format = {},  -- 还未实现, 目前用不上.
}
```
