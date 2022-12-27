--- Auto Format ------------------------------------------------------------------------------------
--- NOTE: save 时格式化文件. 自动格式化放在 Lsp 加载成功后.
--- null-ls 也是一个 Lsp client, 可以提供 formatting 功能. 可以通过 `:LspInfo` 查看.

local function lsp_format(bufnr)
  bufnr = bufnr or vim.api.nvim_get_current_buf() or vim.fn.bufnr()

  --- get all attached/active lsp clients attached to bufnr
  local lsp_clients = vim.lsp.get_active_clients({ bufnr = bufnr })

  local format_client
  for _, client in ipairs(lsp_clients) do
    --- 首先 lsp 要支持 format. 如果 lsp 支持 format 但是功能被手动禁用, 这里也会返回 false.
    --- null-ls 会根据不同的文件类型返回是否支持 formatting.
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

--- 定义 `:Format` command. NOTE: 有些文件类型 (markdown, lua ...) 需要手动执行 Format 命令.
--vim.cmd [[command! Format lua vim.lsp.buf.formatting_sync()]]  -- 基本原理
vim.api.nvim_create_user_command("Format", function() lsp_format() end, {bang=true, bar=true})

--- BufWritePre 在写入文件之前执行 Format.
vim.api.nvim_create_autocmd('BufWritePre', {
  pattern = {
    '*.go','go.mod','go.work',
    '*.css','*.less','*.scss','*.html','*.htm',
    '*.js','*.jsx','*.cjs','*.mjs',
    '*.ts','*.tsx','*.cts','*.ctsx','*.mts','*.mtsx',
    '*.vue','*.svelte','*.graphql',
    '*.json','*.jsonc',
    '*.py','*.sh','*.proto',
  },
  callback = function(params)
    lsp_format(params.buf)
  end
})

--- VVI: goimports-reviser 一定要在 goimports 后面执行 ---------------------------------------------
--- 因为 goimports-reviser 只会对文件当前的 imports(...) 排序,
--- 如果在 goimports 之前执行, 则排序时有可能有些 import 还未被导入.
vim.api.nvim_create_autocmd("BufWritePost", {
  pattern = {"*.go"},
  callback = function(params)
    --- 分类&排序 -imports-order (default "std,general,company,project")
    --- 即(默认): 标准包, github.com, local/src/...
    --- 将排序后的结果写入文件 -output file, 如果有错误则不写入.
    local r = vim.fn.system('goimports-reviser -output file ' .. params.file)
    if vim.v.shell_error ~= 0 then
      --Notify(r, "ERROR")  -- NOTE: go 语法错误会触发这里的 error, 可以不打印.
      return
    end

    --- 文件写入后需要 checktime 刷新 buffer 内容.
    vim.cmd('checktime')
  end,
  desc = "goimports-reviser organize imports",
})



