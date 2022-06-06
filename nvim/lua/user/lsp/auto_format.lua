--- Auto Format ------------------------------------------------------------------------------------
--- NOTE: save 时格式化文件. 自动格式化放在 Lsp 加载成功后.
---       null-ls 也是一个 Lsp client, 可以提供 formatting 功能. 可以通过 `:LspInfo` 查看.
---
---  VVI: 使用 vim.lsp.buf.formatting_sync() 进行 format 时, 如果有多个 Lsp 提供 format 功能, 则会 prompt.
---       使用 vim.lsp.buf.formatting_seq_sync(nil, 3000, {"null-ls"}) 时, 会按顺序执行各个 LSP 的 format,
---       formatting_seq_sync(...{"null-ls"}) 中指定的 Lsp client 最后执行, 但其他的 Lsp 也会执行 format.

--- 如果有 LSP client 支持格式化 current buffer 则运行 vim.lsp.buf.formatting_sync(); 否则 return.
local function lspFormat()
  local clients = vim.tbl_values(vim.lsp.buf_get_clients())
  for _, client in ipairs(clients) do
    if client.supports_method('textDocument/formatting') then
    --if client.resolved_capabilities.document_formatting then
      vim.lsp.buf.formatting_sync()
      return
    end
  end
  -- 如果没有任何 LSP 支持 formating 则提醒.
  Notify(
    {"no LSP support Formatting this file. please check:",
      "':lua print(vim.inspect(vim.tbl_values(vim.lsp.buf_get_clients())))'"},
    "WARN",
    {title={"lspFormat()","auto_format.lua"}}
  )
end

--- 定义 `:Format` command. NOTE: 有些文件类型 (markdown, lua ...) 需要手动执行 Format 命令.
--vim.cmd [[command! Format lua vim.lsp.buf.formatting_sync()]]
vim.api.nvim_create_user_command("Format", lspFormat, {bang=true, bar=true})

--- BufWritePre 在写入文件之前执行 Format.
--- yaml, markdown, lua 不在内.
vim.cmd([[
  autocmd BufWritePre *.css,*.less,*.scss,*.html,*.htm,
    \*.js,*.jsx,*.mjs,*.cjs,*.ts,*.tsx,*.cts,*.ctsx,*.mts,*.mtsx,*.vue,*.svelte,
    \*.json,*.jsonc,*.graphql,*.py Format
]])

-- *.go 需要使用 null-ls 的 goimports 进行 format.
-- go.mod 需要使用 gopls 来进行 format.
vim.cmd([[
  autocmd BufWritePre *.go lua vim.lsp.buf.formatting_seq_sync(nil, 3000, {"null-ls"})
  autocmd BufWritePre go.mod Format
]])



