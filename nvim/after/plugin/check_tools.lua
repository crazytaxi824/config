--- NOTE: after/plugin 只会运行一次, after/ftplugin 每次打开 buffer 都会运行.

--- check Golang tools -----------------------------------------------------------------------------
--- tools: goimports, gomodifytags, gotests, impl, gopls, dlv, golangci-lint ...
--      go install golang.org/x/tools/cmd/goimports@latest
--      go install github.com/fatih/gomodifytags@latest
--      go install github.com/cweill/gotests/gotests@latest
--      go install github.com/josharian/impl@latest
local function check_go_tools()
  local gotools = {
    go = "       https://go.dev/",
    dlv = "      go install github.com/go-delve/delve/cmd/dlv@latest", -- delve
    impl = "     go install github.com/josharian/impl@latest",
    gotests = "  go install github.com/cweill/gotests/gotests@latest",
    --goimports = "go install golang.org/x/tools/cmd/goimports@latest",  -- null-ls 中有检查.
    --gopls = "    go install golang.org/x/tools/gopls@latest",  -- lsp-installer 安装

    ["gomodifytags"] = " go install github.com/fatih/gomodifytags@latest",
    --["golangci-lint"] = "go install github.com/golangci/golangci-lint/cmd/golangci-lint@latest", -- null-ls 中有检查.
  }

  Check_cmd_tools(gotools)
end

vim.api.nvim_create_autocmd("Filetype", {
  pattern = {"go"},
  callback = check_go_tools,
  once = true,  -- VVI: Run check once only.
})



