--- NOTE: after/plugin 只会运行一次, after/ftplugin 每次打开 buffer 都会运行.

--- check Golang tools -----------------------------------------------------------------------------
--- tools: goimports, gomodifytags, gotests, impl, gopls, dlv, golangci-lint ...
--      go install golang.org/x/tools/cmd/goimports@latest
--      go install github.com/fatih/gomodifytags@latest
--      go install github.com/cweill/gotests/gotests@latest
--      go install github.com/josharian/impl@latest
local function check_go_tools()
  local gotools = {
    {cmd="go",  install="https://go.dev/"},
    {cmd="dlv", install="go install github.com/go-delve/delve/cmd/dlv@latest", mason="delve"},
    {cmd="impl", install="go install github.com/josharian/impl@latest", mason="impl"},
    {cmd="gotests", install="go install github.com/cweill/gotests/gotests@latest", mason="gotests"},
    {cmd="gopls", install="go install golang.org/x/tools/gopls@latest", mason="gopls"},
    {cmd="gomodifytags", install="go install github.com/fatih/gomodifytags@latest", mason="gomodifytags"},

    --- 以下 cmd 在 null-ls 中有检查.
    {cmd="goimports", install="go install golang.org/x/tools/cmd/goimports@latest", mason="goimports"},
    {cmd="golangci-lint", install="go install github.com/golangci/golangci-lint/cmd/golangci-lint@latest", mason="golangci-lint"},
  }

  Check_cmd_tools(gotools, {title = "check go tools"})
end

vim.api.nvim_create_autocmd("FileType", {
  pattern = {"go"},
  once = true,  -- VVI: Run check once only.
  callback = check_go_tools,
})



