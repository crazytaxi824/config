-- 官方文档
-- https://github.com/neovim/nvim-lspconfig/blob/master/doc/server_configurations.md#gopls
-- https://github.com/golang/tools/blob/master/gopls/doc/settings.md
-- https://github.com/golang/tools/blob/master/gopls/doc/vim.md#neovim-config

-- `$ go env GOROOT` | `$ go env GOMODCACHE`
local function go_env(v)
  local result = vim.fn.system('go env '..v)
  if vim.v.shell_error ~= 0 then  --- 判断 system() 结果是否错误
    Notify(result, "ERROR")
    return
  end

  return string.match(result, '[%S ]*')
end

--- NOTE: ignore following folds as workspace root directory.
local ignore_workspace_folders = { go_env("GOROOT"), go_env("GOMODCACHE") }

return {
  --cmd = { "gopls" },
  filetypes = { "go", "gomod", "gowork", "gotmpl" },  -- 默认没有 gowork

  --- NOTE: lspconfig.util.root_pattern() 只能在这里使用, 不能在 project_lsp_config 中使用.
  --- project_lsp_config 中设置 root_dir 直接使用 string. eg: root_dir = "/a/b/c"; root_dir = vim.fn.getcwd().
  --- 设置参考 https://github.com/neovim/nvim-lspconfig -> lua/lspconfig/server_configurations/gopls.lua
  root_dir = function(fname)  -- fname == :echo expand('%:p') 当前文件绝对路径.
    --- NOTE: 如果文件在 ignore dir 中, 则返回当前路径 vim.fn.getcwd()
    for _, ignored in ipairs(ignore_workspace_folders) do
      if string.match(fname, vim.fn.expand(ignored)) then
        return vim.fn.getcwd()  -- 返回当前 current working directory = pwd
      end
    end

    local util = require("lspconfig.util")
    --- NOTE: 优先获取 go.work 文件夹位置, 如果不存在则获取 go.mod / .git 文件夹位置.
    local root = util.root_pattern('go.work')(fname) or util.root_pattern('go.mod', '.git')(fname)

    --- 如果没找到 root 则返回 pwd/cwd
    if not root then
      Notify(
        {"'go.mod' file not found in current directory or any parent directory.",
          "Please run 'go mod init xxx'."},
        "WARN",
        {title={"LSP", "gopls.lua"}, timeout = false}
      )
      return vim.fn.getcwd()  -- 返回当前 current working directory = pwd
    end

    --- 如果找到 root 则返回 root
    return root
  end,

  settings = {
    gopls = {
      ["ui.completion.usePlaceholders"] = true,
      ["ui.diagnostic.staticcheck"] = false,
    },
  },
  single_file_support = true,  -- 默认开启.
}
