--- 以下命令行工具可以通过 mason.nvim 安装, 也可以通过 brew 安装到 $PATH 中.
--- filetypes: 可以通过 `:LspInfo` 查看. 用于 autocmd.
--- lspconfig_name: filetype

local M = {}

M.list = {
  lua_ls = {
    cmd = "lua-language-server",
    mason = "lua-language-server",
    filetypes = {'lua'}
  },
  tsserver = {
    cmd = "typescript-language-server",
    mason = "typescript-language-server",
    filetypes = {
      'javascript', 'javascriptreact', 'javascript.jsx',
      'typescript', 'typescriptreact', 'typescript.tsx',
    }
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
  pyright = {
    cmd = "pyright",
    mason = "pyright",
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
  bufls = {  -- protobuf lsp
    cmd = "bufls",
    mason = "buf-language-server",
    filetypes = {'proto'},
  }
}

M.filetype_lsp = {}
for lsp_svr, v in pairs(M.list) do
  for _, ft in ipairs(v.filetypes) do
    M.filetype_lsp[ft] = lsp_svr
  end
end

return M
