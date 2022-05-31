-- 官方文档
-- https://github.com/golang/tools/blob/master/gopls/doc/settings.md
-- https://github.com/golang/tools/blob/master/gopls/doc/vim.md#neovim-config

--- NOTE: ignore following folds as workspace root directory.
local ignore_workspace_folders = { "$GOROOT", "$GOPATH/pkg/mod/github.com/hashicorp/consul/api@v1.12.0" }

return {
  --cmd = { "gopls" },
  --filetypes = {"go", "gomod"},

  --- NOTE: lspconfig.util.root_pattern() 只能在这里使用, 不能在 project_lsp_config 中使用.
  --- project_lsp_config 中设置 root_dir 直接使用 string. eg: root_dir = "/a/b/c"; root_dir = vim.fn.getcwd().
  --- 以下是默认设置. https://github.com/neovim/nvim-lspconfig -> lua/lspconfig/server_configurations/gopls.lua
  root_dir = function(fname)  -- fname == :echo expand('%:p') 当前文件绝对路径.
    --- ignore workspace folders
    for _, ignored in ipairs(ignore_workspace_folders) do
      if string.match(fname, vim.fn.expand(ignored)) then
        return vim.fn.getcwd()  -- 返回当前 current working directory = pwd
      end
    end

    local util = require("lspconfig/util")
    return util.root_pattern('go.work')(fname) or util.root_pattern('go.mod', '.git')(fname)
  end,

  settings = {
    gopls = {
      ["ui.completion.usePlaceholders"] = true,
      ["ui.diagnostic.staticcheck"] = false,
    },
  },
}
