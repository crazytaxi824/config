--- 以下命令行工具可以通过 mason.nvim 安装, 也可以通过 brew 安装到 $PATH 中.
--- filetypes: 可以通过 `:LspInfo` 查看. 用于 autocmd.
--- lspconfig <-> mason: https://github.com/williamboman/mason-lspconfig.nvim/blob/main/doc/server-mapping.md
--- lspconfig config: https://github.com/neovim/nvim-lspconfig/blob/master/doc/configs.md

local M = {}

--- @type table<string, { cmd: string, install?: string, mason?: string }>
M.list = {
  lua_ls = {
    cmd = "lua-language-server",
    mason = "lua-language-server",
  },
  ts_ls = {
    cmd = "typescript-language-server",
    mason = "typescript-language-server",
  },
  bashls = {
    cmd = "bash-language-server",
    mason = "bash-language-server",
  },
  gopls = {
    cmd = "gopls",
    mason = "gopls",
    install = "go install golang.org/x/tools/gopls@latest",
  },
  --- pyrightconfig.json: https://github.com/microsoft/pyright/blob/main/docs/configuration.md
  --- pyproject.toml: https://github.com/microsoft/pyright/blob/main/docs/configuration.md#sample-pyprojecttoml-file
  pyright = {  --- for textDocument/hover ...
    cmd = "pyright",
    mason = "pyright",
  },
  --- pyproject.toml & ruff.toml: https://docs.astral.sh/ruff/tutorial/#configuration
  --- 'ruff' can be used to replace Flake8, Black, isort, pydocstyle, pyupgrade, autoflake ...
  ruff = {
    cmd = "ruff",
    mason = "ruff",
  },
  html = {
    cmd = "vscode-html-language-server",
    mason = "html-lsp",
  },
  cssls = {
    cmd = "vscode-css-language-server",
    mason = "css-lsp",
  },
  jsonls = {
    cmd = "vscode-json-language-server",
    mason = "json-lsp",
  },
  --- VVI: need `npm install eslint`, `npm init @eslint/config`. 会生成 "eslint.config.mjs" 配置文件.
  --- 没有 "eslint.config.mjs" 配置文件 eslint-lsp 无法找到 root, 因此无法启动.
  eslint = {
    cmd = "vscode-json-language-server",
    mason = "eslint-lsp",
  },
  gdscript = {
    cmd = "nc", -- system builtin: TCP and UDP connections and listens
    install = "system builtin",
  },
  sourcekit = {
    cmd = "sourcekit-lsp",
    install = "`brew install sourcekit-lsp` or `xcode-select --install`",
  },
}

return M
