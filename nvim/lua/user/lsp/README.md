# project local LSP settings

设置文件地址
`proj_root/.nvim/settings.lua`

```lua
-- 以下所有设置都可以缺省, 只用设置需要覆盖 default setting 的项.
-- 如果一个项目中有多个不同的 filetype 对应多个不同的 lsp, linter, formatter, 可以在不同的 section 中设置多个 tool.
return {
  -- nvim-lspconfig 设置
  settings = {
    gopls = {
      ["ui.completion.usePlaceholders"] = true,
      ["ui.diagnostic.staticcheck"] = false,
    },
    tsserver = {
      ...
    },
    pyright = { ... },
    sumneko_lua = { ... },
    html = { ... },
    cssls = { ... },
    bashls = { ... },
  },

  -- null-ls linter/diagnostics 设置
  -- eg: null_ls.diagnostics.xxx.with() 设置.
  lint = {
    golangci_lint = {
      command = "/path/to/golangci-lint",
      cwd = "path/to/current_working_dir",
      args = { "run", ... },  -- overwrite default settings.
      extra_args = { "--config", '~/.config/lints/.golangci.yml' },
      filetypes = { "go" },
    },
    eslint = { ... },
    flake8 = { ... },
    buf = { ... },
  },

  -- null-ls formatter 设置
  -- eg: null_ls.formatting.xxx.with() 设置.
  format = {
    prettier = { ... },
    stylua = { ... },
    autopep8 = { ... },
    buf = { ... },
  },
}
```
