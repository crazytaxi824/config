--- Auto Format ------------------------------------------------------------------------------------
--- NOTE: save 时格式化文件. 自动格式化放在 Lsp 加载成功后.
---       null-ls 也是一个 Lsp client, 可以提供 formatting 功能. 可以通过 `:LspInfo` 查看.
---
---  VVI: 使用 vim.lsp.buf.formatting_sync() 进行 format 时, 如果有多个 Lsp 提供 format 功能, 则会 prompt.
---       使用 vim.lsp.buf.formatting_seq_sync(nil, 3000, {"null-ls"}) 时, 会按顺序执行各个 LSP 的 format,
---       formatting_seq_sync(...{"null-ls"}) 中指定的 Lsp client 最后执行, 但其他的 Lsp 也会执行 format.
---       如果 null-ls 没有设置对应的 format tool, formatting_seq_sync(...{"null-ls"}) 也不会报错.

--- 如果有 LSP client 支持格式化 current buffer 则运行 vim.lsp.buf.formatting_seq_sync(); 否则 return.
local function lspFormat()
  local clients = vim.tbl_values(vim.lsp.buf_get_clients())
  for _, client in ipairs(clients) do
    --if client.resolved_capabilities.document_formatting then  -- 应该也可以用 resolved_capabilities 判断.
    if client.supports_method('textDocument/formatting') then
      --vim.lsp.buf.formatting_sync()  -- 如果有多个 Lsp 提供 format 功能, 则会 prompt.
      vim.lsp.buf.formatting_seq_sync(nil, 3000, {"null-ls"})  -- 最后执行 null-ls format, 其他的 Lsp 也会执行 format.
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
--vim.cmd [[command! Format lua vim.lsp.buf.formatting_sync()]]  -- 基本原理
vim.api.nvim_create_user_command("Format", lspFormat, {bang=true, bar=true})

--- BufWritePre 在写入文件之前执行 Format.
--- NOTE: yaml, markdown, lua 不在 autocmd 中, 这些文件可以手动执行 `:Format` 命令.
vim.cmd([[
  autocmd BufWritePre *.go,go.mod,go.work,
    \*.css,*.less,*.scss,*.html,*.htm,
    \*.js,*.jsx,*.cjs,*.mjs,
    \*.ts,*.tsx,*.cts,*.ctsx,*.mts,*.mtsx,
    \*.vue,*.svelte,*.graphql,
    \*.json,*.jsonc,*.py,*.sh
    \ Format
]])



