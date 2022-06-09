--- check Golang tools -----------------------------------------------------------------------------
--- tools: goimports, gomodifytags, gotests, impl, gopls, dlv, golangci-lint ...
--      go install golang.org/x/tools/cmd/goimports@latest
--      go install github.com/fatih/gomodifytags@latest
--      go install github.com/cweill/gotests/gotests@latest
--      go install github.com/josharian/impl@latest
local function check_go_tools()
  local gotools = {
    gotests = "  go install github.com/cweill/gotests/gotests@latest",
    impl = "     go install github.com/josharian/impl@latest",
    dlv = "      go install github.com/go-delve/delve/cmd/dlv@latest", -- vimspector
    --goimports = "go install golang.org/x/tools/cmd/goimports@latest",  -- null-ls 中有检查.
    --gopls = "    go install golang.org/x/tools/gopls@latest",  -- lsp-installer 安装

    ["gomodifytags"] = " go install github.com/fatih/gomodifytags@latest",
    --["golangci-lint"] = "go install github.com/golangci/golangci-lint/cmd/golangci-lint@latest", -- null-ls 中有检查.
  }

  Check_Cmd_Tools(gotools)
end

vim.api.nvim_create_autocmd("Filetype", {
  pattern = {"go"},
  callback = check_go_tools,
  once = true,  -- VVI: Run check once only.
})



