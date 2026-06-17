local bimap = require('myplugins.wbl.bimap')


-- 将 lsp rename 时修改的 buffer 加载到 current window
local ms = vim.lsp.protocol.Methods

local orig_handler = vim.lsp.handlers[ms.textDocument_rename]

vim.lsp.handlers[ms.textDocument_rename] = function(err, result, ctx, config)
  if result then
    -- NOTE: 使用 dict 去重
    ---@type table<integer, boolean>
    local affected_bufs = {}

    -- 旧 lsp response 格式
    local changes = result.changes or {}
    for uri, _ in pairs(changes) do
      affected_bufs[vim.uri_to_bufnr(uri)] = true
    end

    -- 新 lsp response 格式
    local document_changes = result.documentChanges or {}
    for _, change in ipairs(document_changes) do
      if change.textDocument then
        affected_bufs[vim.uri_to_bufnr(change.textDocument.uri)] = true
      end
    end

    -- 加载相关 buffer 到当前 window
    local curr_win = vim.api.nvim_get_current_win()
    for bufnr, _ in pairs(affected_bufs) do
      bimap.bind({ win_id=curr_win, bufnr=bufnr })
      -- NOTE: 之后会被 BufModifiedSet event 更新 winbar
    end
  end

  -- 继续执行原 handler
  if orig_handler then
    return orig_handler(err, result, ctx, config)
  end
end



