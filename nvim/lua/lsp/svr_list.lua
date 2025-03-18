--- 以下命令行工具可以通过 mason.nvim 安装, 也可以通过 brew 安装到 $PATH 中.
--- filetypes: 可以通过 `:LspInfo` 查看. 用于 autocmd.
--- lspconfig <-> mason: https://github.com/williamboman/mason-lspconfig.nvim/blob/main/doc/server-mapping.md
--- lspconfig config: https://github.com/neovim/nvim-lspconfig/blob/master/doc/configs.md

local M = {}

--- map[lspconfig_name]: { cmd, mason_name, filetypes }
M.list = {
  lua_ls = {
    cmd = "lua-language-server",
    mason = "lua-language-server",
    filetypes = {'lua'}
  },
  ts_ls = {
    cmd = "typescript-language-server",
    mason = "typescript-language-server",
    filetypes = { "javascript", "javascriptreact", "javascript.jsx", "typescript", "typescriptreact", "typescript.tsx" }
  },
  bashls = {
    cmd = "bash-language-server",
    mason = "bash-language-server",
    filetypes = {'sh'}
  },
  gopls = {
    cmd = "gopls",
    mason = "gopls",
    install = "go install golang.org/x/tools/gopls@latest",
    filetypes = {'go', 'gomod', 'gowork', 'gotmpl'}
  },
  --- pyrightconfig.json: https://github.com/microsoft/pyright/blob/main/docs/configuration.md
  --- pyproject.toml: https://github.com/microsoft/pyright/blob/main/docs/configuration.md#sample-pyprojecttoml-file
  pyright = {  --- for textDocument/hover ...
    cmd = "pyright",
    mason = "pyright",
    filetypes = {'python'}
  },
  --- pyproject.toml & ruff.toml: https://docs.astral.sh/ruff/tutorial/#configuration
  --- 'ruff' can be used to replace Flake8, Black, isort, pydocstyle, pyupgrade, autoflake ...
  ruff = {
    cmd = "ruff",
    mason = "ruff",
    filetypes = {'python'}
  },
  html = {
    cmd = "vscode-html-language-server",
    mason = "html-lsp",
    filetypes = {'html'}
  },
  cssls = {
    cmd = "vscode-css-language-server",
    mason = "css-lsp",
    filetypes = {'css', 'scss', 'less'}
  },
  jsonls = {
    cmd = "vscode-json-language-server",
    mason = "json-lsp",
    filetypes = {'json', 'jsonc'}
  },
  --- VVI: need `npm install eslint`, `npm init @eslint/config`. 会生成 "eslint.config.mjs" 配置文件.
  --- 没有 "eslint.config.mjs" 配置文件 eslint-lsp 无法找到 root, 因此无法启动.
  eslint = {
    cmd = "vscode-json-language-server",
    mason = "eslint-lsp",
    filetypes = { "javascript", "javascriptreact", "javascript.jsx", "typescript", "typescriptreact", "typescript.tsx", "vue", "svelte", "astro" },
  },
  gdscript = {
    cmd = "nc", -- system builtin: TCP and UDP connections and listens
    install = "system builtin",
    filetypes = { 'gd', 'gdscript', 'gdscript3' },
  },
}

--- { javascript = { eslint, tsserver }, ... }
M.filetype_lsp = {}
for lsp_svr, v in pairs(M.list) do
  for _, ft in ipairs(v.filetypes) do
    M.filetype_lsp[ft] = M.filetype_lsp[ft] or {}
    table.insert(M.filetype_lsp[ft], lsp_svr)
  end
end

return M
