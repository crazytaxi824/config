--- 官方文档
--- https://github.com/neovim/nvim-lspconfig/blob/master/doc/server_configurations.md#gopls
--- https://github.com/golang/tools/blob/master/gopls/doc/settings.md
--- https://github.com/golang/tools/blob/master/gopls/doc/vim.md#neovim-config

--- BUG: https://github.com/golang/go/issues/50750
--- 使用 workspace 'go.work' 的情况下, `:LspLog` 打印错误 `go mod tidy` Error.
--- "finding module for package xxx: cannot find module providing package xxx: module lookup disabled by GOPROXY=off"

return {
  --cmd = { "gopls" },
  --filetypes = { "go", "gomod", "gowork", "gotmpl" },

  --- NOTE: lspconfig.util.root_pattern() 只能在这里使用, 不能在 project_lsp_config 中使用.
  --- project_lsp_config 中设置 root_dir 直接使用 string. eg: root_dir = "/a/b/c"; root_dir = vim.uv.cwd().
  --- 设置参考 https://github.com/neovim/nvim-lspconfig/blob/master/lua/lspconfig/server_configurations/gopls.lua
  root_dir = function(fname)  -- fname == :echo expand('%:p') 当前文件绝对路径.
    --- FIXED: https://github.com/neovim/nvim-lspconfig/issues/2285
    --- 修复 lsp goto_definition 出现的问题. eg: golang 中 goto_definition 后, 因源文件的 root_dir/workspace 不同,
    --- 导致无法继续向下 goto_definition. "github.com/hashicorp/consul" 问题最严重.
    --- VSCODE: 实现方式 https://code.visualstudio.com/docs/editor/multi-root-workspaces
    -- for _, ignored in ipairs(ignore_workspace_folders) do
    --   if string.match(fname, vim.fn.expand(ignored)) then
    --     return vim.uv.cwd()  -- 返回当前 current working directory = pwd
    --   end
    -- end

    --- NOTE: 优先获取 go.work 文件夹位置, 如果不存在则获取 go.mod 文件夹位置.
    local root = vim.fs.root(0, 'go.work') or vim.fs.root(0, 'go.mod')
    if root then
      --- 如果找到 root 则返回 root
      return root
    end

    --- 如果没找到 root 则返回 pwd/cwd
    Notify(
      {"'go.mod' & 'go.work' NOT found in current or any parent directory.",
        "Please run 'go mod init xxx'."},
      "WARN",
      {title={"LSP", "gopls.lua"}, timeout = false}
    )
    return vim.uv.cwd()
  end,

  settings = {
    gopls = {
      semanticTokens = true,  -- 默认 false.
      -- semanticTokenTypes = {  -- allows disabling types
      --   string = false,
      --   number = false,
      -- },

      usePlaceholders = true,
      staticcheck = false,
      vulncheck = "Imports",  -- check Go Vulnerability Database check known Vulnerability in your dependencies.
    },
  },
}
