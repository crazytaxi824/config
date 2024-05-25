--- Auto Format
--- save 时格式化文件. 自动格式化放在 Lsp 加载成功后.
--- null-ls 也是一个 Lsp client, 可以提供 formatting 功能. 可以通过 `:LspInfo` 查看.

local function lsp_format(bufnr)
  bufnr = bufnr or vim.api.nvim_get_current_buf() or vim.fn.bufnr()

  --- get all attached/active lsp clients attached to bufnr
  local lsp_clients = vim.lsp.get_clients({ bufnr = bufnr })

  local format_client
  for _, client in ipairs(lsp_clients) do
    --- 首先 lsp 要支持 format. 如果 lsp 支持 format 但是功能被手动禁用, 这里也会返回 false.
    --- NOTE: null-ls 会根据不同的文件类型返回是否支持 formatting.
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
    vim.lsp.buf.format({ timeout_ms = 3000, bufnr = bufnr, id = format_client.id })
    return
  end

  --- 如果没有任何 LSP 支持 formating 则提醒.
  Notify(
    'no LSP support Formatting "' .. vim.bo[bufnr].filetype .. '". please check `:LspInfo`',
    "WARN"
  )
end

--- 定义 `:Format` command. NOTE: 有些文件类型 (markdown, lua ...) 需要手动执行 Format 命令.
vim.api.nvim_create_user_command("Format", function() lsp_format() end, {bang=true, bar=true})

--- BufWritePre 在写入文件之前执行 Format.
vim.api.nvim_create_autocmd('BufWritePre', {
  pattern = {"*"},
  callback = function(params)
    --- NOTE: exclude some of the filetypes to auto format
    local exclude_auto_format_filtypes = { "markdown", "yaml", "lua" }
    if vim.tbl_contains(exclude_auto_format_filtypes, vim.bo[params.buf].filetype) then
      return
    end

    lsp_format(params.buf)
  end,
  desc = "LSP: format file while saving",
})

--- VVI: goimports-reviser 一定要在 goimports 后面执行 ---------------------------------------------
--- 因为 goimports-reviser 只会对文件当前的 imports(...) 排序,
--- 如果 goimports-reviser 在 goimports 之前执行, 则排序时有可能有些 import 还未被导入.
vim.api.nvim_create_autocmd("BufWritePost", {
  pattern = {"*.go"},
  callback = function(params)
    --- 分类&排序 -imports-order (default "std,general,company,project")
    --- 即(默认): 标准包, github.com, local/src/...
    --- 将排序后的结果写入文件 -output file, 如果有错误则不写入.
    local result = vim.system({'goimports-reviser', '-output', 'file', params.file}, { text = true }):wait()
    if result.code ~= 0 then
      error(result.stderr ~= '' and result.stderr or result.code)
    end

    --- 文件写入后需要 checktime 刷新 buffer 内容.
    vim.cmd('checktime')
  end,
  desc = "Go: goimports-reviser organize imports",
})



