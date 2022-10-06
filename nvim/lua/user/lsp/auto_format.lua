--- Auto Format ------------------------------------------------------------------------------------
--- NOTE: save 时格式化文件. 自动格式化放在 Lsp 加载成功后.
--- null-ls 也是一个 Lsp client, 可以提供 formatting 功能. 可以通过 `:LspInfo` 查看.

local lsp_format
if vim.fn.has('nvim-0.8') == 1 then
  --- 如果 null-ls 可以格式化则使用 null-ls, 如果不行则使用其他 lsp client.
  lsp_format = function()
    local bufnr = vim.fn.bufnr()

    --- 获取所有 attached lsp clients
    local lsp_clients = vim.lsp.get_active_clients({ bufnr = bufnr })

    local format_client
    for _, client in ipairs(lsp_clients) do
      --- 首先 lsp 要支持 format.
      if client.supports_method('textDocument/formatting') then
        if client.name == 'null-ls' then
          --- 如果 null-ls 存在, 则使用 null-ls.
          format_client = client
          break
        else
          --- 如果 null-ls 不存在, 则选择其他可以 format 的 lsp.
          format_client = client
        end
      end
    end

    --- format 文件.
    if format_client then
      vim.lsp.buf.format({ timeout_ms = 3000, bufnr = bufnr, name = format_client.name })
      return
    end

    --- 如果没有任何 LSP 支持 formating 则提醒.
    Notify(
      'no LSP support Formatting "' .. vim.bo[bufnr].filetype .. '". please check `:LspInfo`',
      "WARN"
    )
  end
else
  --- 使用所有 lsp 进行 format (同步运行), 设置 null-ls 为最后一个进行 format 的 lsp.
  lsp_format = function() vim.lsp.buf.formatting_seq_sync(nil, 3000, {"null-ls"}) end
end


--- 定义 `:Format` command. NOTE: 有些文件类型 (markdown, lua ...) 需要手动执行 Format 命令.
--vim.cmd [[command! Format lua vim.lsp.buf.formatting_sync()]]  -- 基本原理
vim.api.nvim_create_user_command("Format", lsp_format, {bang=true, bar=true})

--- BufWritePre 在写入文件之前执行 Format.
--- NOTE: yaml, markdown, lua 不在 autocmd 中, 这些文件可以手动执行 `:Format` 命令.
vim.cmd([[
  autocmd BufWritePre *.go,go.mod,go.work,
    \*.css,*.less,*.scss,*.html,*.htm,
    \*.js,*.jsx,*.cjs,*.mjs,
    \*.ts,*.tsx,*.cts,*.ctsx,*.mts,*.mtsx,
    \*.vue,*.svelte,*.graphql,
    \*.json,*.jsonc,*.py,*.sh,*.proto
    \ Format
]])



