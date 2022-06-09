--- NOTE: 以下并没有用到, 作为 go Auto Format 备选方案.
--- Auto goimports ---------------------------------------------------------------------------------
--- README: 使用 code_action 执行 organizeImports, 不会询问.
---         该方法只针对 golang 有效, 其他语言无法使用该方法进行 OrganizeImports, eg: tsx
--- NOTE:   目前在 null-ls 中使用 formatting.goimports 替代.
--- https://cs.opensource.google/go/x/tools/+/refs/tags/gopls/v0.8.3:gopls/doc/vim.md#neovim-imports
--- https://github.com/neovim/nvim-lspconfig/issues/115
function OrganizeImports(wait_ms)
  local params = vim.lsp.util.make_range_params()
  params.context = { only = {"source.organizeImports"} }
  local result = vim.lsp.buf_request_sync(0, "textDocument/codeAction", params, wait_ms)
  for _, res in pairs(result or {}) do
    for _, r in pairs(res.result or {}) do
      if r.edit then
        vim.lsp.util.apply_workspace_edit(r.edit, "utf-16")
      else
        vim.lsp.buf.execute_command(r.command)
      end
    end
  end
end

--- BufWritePre 在写入文件之前执行上面的函数.
--autocmd BufWritePre *.go :lua OrganizeImports(3000)

--- 以下设置 always prompt, 总是会提示选择.
--autocmd BufWritePre *.go :silent lua vim.lsp.buf.code_action({ only = { "source.organizeImports" } })

