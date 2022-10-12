# project local LSP settings

设置文件地址 `proj_root/.nvim/settings.lua`

```lua
--- 以下所有设置都可以缺省, 只用设置需要覆盖 default setting 的项.
--- 如果一个项目中有多个不同的 filetype 对应多个不同的 lsp, linter, formatter, 可以在不同的 section 中设置多个 tool.
return {
  --- nvim-lspconfig 设置
  lsp = {
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

  --- null-ls linter/diagnostics 设置
  --- eg: null_ls.diagnostics.xxx.with() 设置.
  linter = {
    golangci_lint = {
      command = "/path/to/golangci-lint",
      cwd = "path/to/current_working_dir",
      args = { "run", ... },  -- overwrite default settings.
      extra_args = {
		--- 指定 config 文件.
		"--config", vim.fn.getcwd() .. '/.golangci.yml',
		"--config", '~/.config/lints/.golangci.yml',

		--- 生产模式下增加的 linter, '-E' = '--enable'.
		"--enable", "unused",
		"-E", "unparam",
		"-E", "goconst",
		"-E", "whitespace",
		"-E", "decorder"
	  }
      filetypes = { "go" },
    },
    eslint = { ... },
    flake8 = { ... },
    buf = { ... },
  },

  --- null-ls formatter 设置
  --- eg: null_ls.formatting.xxx.with() 设置.
  formatter = {
    prettier = { ... },
    stylua = { ... },
    autopep8 = { ... },
    buf = { ... },
  },
}
```

<br />

# LSP 插件关系

## vim.lsp

vim.lsp 是 neovim 自带的 lsp client 实例, 实现了向 lsp server 请求 method 和 handler 用于处理 server 返回的 response.

lsp server 包括 gopls, tsserver, pyright ...

<br />

## lspconfig 官方插件

`lspconfig` 给 vim.lsp 提供 lsp server 设置.

`neovim/nvim-lspconfig`

主要设置:

```lua
local lspconfig = require("lspconfig")

lspconfig.{lsp_server}.setup({
  on_init = function(lsp_client)  -- 在 lsp 启动的时候执行.
  on_attach = function(lsp_client, bufnr)  -- 在 lsp client 成功 attach 到 buffer 的时候执行.
  capabilities = cmp_nvim_lsp.update_capabilities()  -- 将 lsp completion 返回给 cmp-nvim-lsp.
})

-- eg:
lspconfig.gopls.setup({
  ...
})
```

### lspconfig 依赖 "hrsh7th/cmp-nvim-lsp"

`hrsh7th/cmp-nvim-lsp` 是 `hrsh7th/nvim-cmp` 的代码补全 (completion) 插件.

`cmp-nvim-lsp` 向 `nvim-cmp` 提供 lsp 返回的代码补全 completion 内容.

<br />

## mason

`williamboman/mason.nvim`

`mason` 是一个命令行工具安装/管理插件, 包括 lsp, formatter, linter, dap 几种不同的命令行工具, eg: gopls, prettier, delve
这些工具可以不通过 mason 安装, 可以手动安装在 $PATH 中. eg: `brew install xxx`

`mason` 和 `nvim-lspconfig` 没有依赖关系, 也不是 lsp client.

`:Mason` 安装 LSP 时使用的名字和 `nvim-lspconfig` setup() 的名字有区别.

`mason` 安装的 tools 的名字可能和命令行工具的名字也不一样. eg: `delve` 的命令行工具文件名是 `dlv`

名字的对应 https://github.com/williamboman/mason-lspconfig.nvim/blob/main/doc/server-mapping.md

mason-lspconfig 对应文件 https://github.com/williamboman/mason-lspconfig.nvim/blob/main/lua/mason-lspconfig/mappings/server.lua

| 命令行工具(文件)名          | Mason Name                                 | "neovim/nvim-lspconfig" setup() Name         |
| --------------------------- | ------------------------------------------ | -------------------------------------------- |
| gopls                       | `:MasonInstall gopls`                      | require("lspconfig")["gopls"].setup(opts)    |
| vscode-json-language-server | `:MasonInstall json-lsp`                   | require("lspconfig")["jsonls"].setup(opts)   |
| typescript-language-server  | `:MasonInstall typescript-language-server` | require("lspconfig")["tsserver"].setup(opts) |
| dlv                         | `:MasonInstall delve`                      | N/A                                          |

功能:

- 指定安装位置
- 安装
- 卸载
- 更新

<br />

## null-ls

`jose-elias-alvarez/null-ls.nvim`

`null-ls` 是将 vim.lsp 中的 diagnostic, format, code_action ... 等请求翻译成各种 linter, formatter 的命令并执行, 然后将
执行结果翻译后返回给 vim.lsp 的一个工具.

简单来说是把 golangci, eslint ... 等工具变成了一个 lsp server, 通过 lsp protocal 的标准请求翻译成这些工具的命令.

`null-ls` 和 `lspconfig` 是独立的两个 plugin, 不存在依赖关系, 但都接入到了 vim.lsp 中. 可以通过 `:LspInfo` 查看到
两个 lsp client.

<br />
