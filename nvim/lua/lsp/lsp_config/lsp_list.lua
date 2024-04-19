--- 以下命令行工具可以通过 mason.nvim 安装, 也可以通过 brew 安装到 $PATH 中.
--- filetypes: 可以通过 `:LspInfo` 查看. 用于 autocmd.
--- lspconfig <-> mason: https://github.com/williamboman/mason-lspconfig.nvim/blob/main/doc/server-mapping.md
--- lspconfig config: https://github.com/neovim/nvim-lspconfig/blob/master/doc/server_configurations.md

local M = {}

--- map[lspconfig_name]: { cmd, mason_name, filetypes }
M.list = {
  --- https://github.com/neovim/nvim-lspconfig/blob/master/doc/server_configurations.md#lua_ls
  lua_ls = {
    cmd = "lua-language-server",
    mason = "lua-language-server",
    filetypes = {'lua'}
  },
  --- https://github.com/neovim/nvim-lspconfig/blob/master/doc/server_configurations.md#tsserver
  tsserver = {
    cmd = "typescript-language-server",
    mason = "typescript-language-server",
    filetypes = {
      'javascript', 'javascriptreact', 'javascript.jsx',
      'typescript', 'typescriptreact', 'typescript.tsx',
    }
  },
  --- https://github.com/neovim/nvim-lspconfig/blob/master/doc/server_configurations.md#bashls
  bashls = {
    cmd = "bash-language-server",
    mason = "bash-language-server",
    filetypes = {'sh'}
  },
  --- https://github.com/neovim/nvim-lspconfig/blob/master/doc/server_configurations.md#gopls
  gopls = {
    cmd = "gopls",
    mason = "gopls",
    install = "go install golang.org/x/tools/gopls@latest",
    filetypes = {'go', 'gomod', 'gowork', 'gotmpl'}
  },
  --- https://github.com/neovim/nvim-lspconfig/blob/master/doc/server_configurations.md#pyright
  --- `pyrightconfig.json` 配置 https://github.com/microsoft/pyright/blob/main/docs/configuration.md
  pyright = {  --- for textDocument/hover ...
    cmd = "pyright",
    mason = "pyright",
    filetypes = {'python'}
  },
  --- https://github.com/neovim/nvim-lspconfig/blob/master/doc/server_configurations.md#ruff_lsp
  --- DOCS: ruff_lsp work with pyright. https://github.com/astral-sh/ruff-lsp/issues/384
  --- NOTE: lspconfig_name = ruff_lsp, cmd & mason_name = ruff-lsp
  ruff_lsp = {  --- for lint, code action, format ...
    cmd = "ruff-lsp",
    mason = "ruff-lsp",
    filetypes = {'python'}
  },
  --- https://github.com/neovim/nvim-lspconfig/blob/master/doc/server_configurations.md#ruff
  -- ruff = {  --- NOTE: in alpha version, will replace "ruff-lsp" in the future.
  --   cmd = "ruff",
  --   mason = "ruff",
  --   filetypes = {'python'}
  -- },
  --- https://github.com/neovim/nvim-lspconfig/blob/master/doc/server_configurations.md#html
  html = {
    cmd = "vscode-html-language-server",
    mason = "html-lsp",
    filetypes = {'html'}
  },
  --- https://github.com/neovim/nvim-lspconfig/blob/master/doc/server_configurations.md#cssls
  cssls = {
    cmd = "vscode-css-language-server",
    mason = "css-lsp",
    filetypes = {'css', 'scss', 'less'}
  },
  --- https://github.com/neovim/nvim-lspconfig/blob/master/doc/server_configurations.md#jsonls
  jsonls = {
    cmd = "vscode-json-language-server",
    mason = "json-lsp",
    filetypes = {'json', 'jsonc'}
  },
  --- https://github.com/neovim/nvim-lspconfig/blob/master/doc/server_configurations.md#eslint
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
