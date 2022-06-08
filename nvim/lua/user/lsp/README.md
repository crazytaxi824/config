# project local LSP settings

设置文件地址 `proj_root/.nvim/settings.lua`

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

# LSP 插件关系

## lspconfig 官方插件

"neovim/nvim-lspconfig"

主要作用:
```lua
lspconfig.{lsp_server}.setup({
  on_init = function(lsp_client)  -- 在 lsp 启动的时候执行.
  on_attach = function(lsp_client, bufnr)  -- 在 lsp client 成功 attach 到 buffer 的时候执行.
  capabilities = cmp_nvim_lsp.update_capabilities()  -- 将 lsp completion 返回给 cmp-nvim-lsp.
})
```

## cmp-nvim-lsp 是 nvim-cmp 的代码 completion 插件.

"hrsh7th/nvim-cmp"

"hrsh7th/cmp-nvim-lsp"



