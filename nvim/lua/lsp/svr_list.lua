-- 以下命令行工具可以通过 mason.nvim 安装, 也可以通过 brew 安装到 $PATH 中.
-- filetypes: 可以通过 `:LspInfo` 查看. 用于 autocmd.
-- lspconfig <-> mason: https://github.com/williamboman/mason-lspconfig.nvim/blob/main/doc/server-mapping.md
-- lspconfig config: https://github.com/neovim/nvim-lspconfig/blob/master/doc/configs.md

local M = {}


---@alias ToolProps { cmd: string|string[], install?: string, mason?: string }


---@type table<string, ToolProps>
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
  -- pyrightconfig.json: https://github.com/microsoft/pyright/blob/main/docs/configuration.md
  -- pyproject.toml [tool.pyright] : https://github.com/microsoft/pyright/blob/main/docs/configuration.md#sample-pyprojecttoml-file
  -- 无 semantic token, 微软开发, TS 语言编写
  -- pyright = {
  --   cmd = "pyright-langserver",
  --   mason = "pyright",
  -- },
  -- pyproject.toml [tool.basedpyright]: https://docs.basedpyright.com/latest/configuration/config-files/
  -- 在 pyright 基础上加入了 semantic token, 社区维护, TS 语言编写
  -- 开销: 最大
  -- 无注释代码类型推断: 低, 大量 Unknown/Any
  -- 泛型推断: 最高
  -- basedpyright = {
  --   cmd = "basedpyright-langserver",
  --   mason = "basedpyright",
  -- },
  -- pyrefly.toml [tool.pyrefly]: https://pyrefly.org/en/docs/configuration/
  -- Meta(facebook) 开发, Rust 语言编写
  -- 开销: 比 ty 大 (CPU, MEM), 适合中大型项目
  -- 类型推断: 激进隐式推断，对非注解代码友好
  -- 无注释代码类型推断: 最高
  -- 泛型推断: 高
  -- pyrefly = {
  --   cmd = "pyrefly",
  --   mason = "pyrefly",
  -- },
  -- ty.toml [tool.ty.analysis]: https://docs.astral.sh/ty/reference/configuration/
  -- Astral(OpenAI) 开发, Rust 语言编写
  -- 开销: 最小, 适合中小型项目
  -- 类型推断: 渐进保证，错误提示极其清晰, 配合自家的 uv ruff 工具链
  -- 无注释代码类型推断: 中, 不激进推断
  -- 泛型推断: 低
  ty = {
    cmd = "ty",
    mason = "ty",
  },
  -- pyproject.toml [tool.ruff] & ruff.toml: https://docs.astral.sh/ruff/tutorial/#configuration
  -- 'ruff' can be used to replace Flake8, Black, isort, pydocstyle, pyupgrade, autoflake ...
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
  tombi = {
    cmd = "tombi",
    mason = "tombi",
  },
  yamlls = {
    cmd = "yaml-language-server",
    mason = "yaml-language-server",
  },
  -- VVI: need `npm install eslint`, `npm init @eslint/config`. 会生成 "eslint.config.mjs" 配置文件.
  -- 没有 "eslint.config.mjs" 配置文件 eslint-lsp 无法找到 root, 因此无法启动.
  eslint = {
    cmd = "vscode-eslint-language-server",
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
