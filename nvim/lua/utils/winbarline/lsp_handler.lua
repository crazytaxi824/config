--- 将 lsp rename 时修改的 buffer 加载到 current window
local ms = vim.lsp.protocol.Methods

local orig_handler = vim.lsp.handlers[ms.textDocument_rename]

vim.lsp.handlers[ms.textDocument_rename] = function(err, result, ctx, config)
  if result then
    local affected_bufs = {}

    --- 旧 lsp response 格式
    local changes = result.changes or {}
    for uri, _ in pairs(changes) do
      table.insert(affected_bufs, vim.uri_to_bufnr(uri))
    end

    --- 新 lsp response 格式
    local document_changes = result.documentChanges or {}
    for _, change in ipairs(document_changes) do
      if change.textDocument then
        table.insert(affected_bufs, vim.uri_to_bufnr(change.textDocument.uri))
      end
    end

    --- 加载相关 buffer 到当前 window
    local curr_win = vim.api.nvim_get_current_win()
    local curr_buf = vim.api.nvim_win_get_buf(curr_win)

    for _, bufnr in ipairs(affected_bufs) do
      vim.api.nvim_win_set_buf(curr_win, bufnr)
    end

    --- 最后显示原 buffer
    vim.api.nvim_win_set_buf(curr_win, curr_buf)
  end

  --- 继续执行原 handler
  return orig_handler(err, result, ctx, config)
end



