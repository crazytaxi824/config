--- sort table list, compare table item sequentially.
--- textDocument/documentHighlight response:
-- {{
--   kind = 1,
--   range = {
--     end = {
--       character = 4,
--       line = 12
--     },
--     start = {
--       character = 1,
--       line = 12
--     }
--   }
-- }, ...}

--- 官方设置方法, `:help vim.lsp.buf.document_highlight()` ------------------------------------ {{{
---   NOTE: Usage of |vim.lsp.buf.document_highlight()| requires the
---   following highlight groups to be defined or you won't be able
---   to see the actual highlights. |LspReferenceText|
---   |LspReferenceRead| |LspReferenceWrite|
--
-- local function lsp_highlight(client)
--   --- TODO: CursorHold 过程中不要 clear_references(), 在判断 word 改变之后再 clear.
--   --- Set autocommands conditional on server_capabilities
--   if client.resolved_capabilities.document_highlight then
--     vim.cmd [[
--       augroup lsp_document_highlight
--         autocmd! * <buffer>
--         "autocmd ModeChanged * lua vim.lsp.buf.clear_references()
--         autocmd CursorHold <buffer> lua vim.lsp.buf.clear_references() vim.lsp.buf.document_highlight()
--         autocmd CursorHoldI <buffer> lua vim.lsp.buf.clear_references() vim.lsp.buf.document_highlight()  -- insert mode
--         "autocmd CursorMoved <buffer> lua vim.lsp.buf.clear_references()
--         "autocmd CursorMovedI <buffer> lua vim.lsp.buf.clear_references()   -- insert mode
--       augroup END
--     ]]
--   end
-- end
--
-- -- }}}

--- sort response list 方便 compare. VVI: 需要 compare kind, start.line & start.character
local function sort_table(list)
  table.sort(list, function(i, j)  -- compare kind
    return i.kind < j.kind
  end)
  table.sort(list, function(i, j)  -- compare start.line
    return i.range.start.line < j.range.start.line
  end)
  table.sort(list, function(i, j)  -- compare start.character
    return i.range.start.character < j.range.start.character
  end)
end

--- 判断两个 list 是否相同
local function compare_sorted_table(t1, t2)
  if #t1 ~= #t2 then
    -- print('lists length are not the same')
    return
  end

  for i=1,#t1,1 do
    if t1.kind ~= t2.kind then
      -- print('kind value not the same')
      return
    end
    --- 这里不需要检查 end, 因为一个 highlight 的 start~end 不会和另一个 highlight 有任何重叠部分.
    --- 也不会有两个 highlight 出现在同一个 start position 上.
    for key, _ in pairs(t1[i].range.start) do
      if t1[i].range.start[key] ~= t2[i].range.start[key] then
        -- print(key, 'value not the same')
        return
      end
    end
  end

  return true  -- 认为两个 list 相同
end

--- cache 上一次的 documentHighlight 结果.
local prev_doc_hi_pos = {}

local function handler(_, result, ctx, config)
  --- VVI: 没有结果的情况下, 有些 lsp 会返回 nil, 有些会返回 empty table {}. eg: cursor 在空白行.
  if not result or #result == 0 then
    prev_doc_hi_pos = {}  -- 清空结果
    vim.lsp.buf.clear_references()  -- clear previous highlight
    return
  end

  sort_table(result)
  local r = compare_sorted_table(prev_doc_hi_pos, result)

  --- cache result to prev_doc_hi_pos
  prev_doc_hi_pos = result

  if not r then
    -- print('changed')  -- documentHighlight position changed
    vim.lsp.buf.clear_references()  -- clear previous highlight
    vim.lsp.buf.document_highlight()  -- new highlight
  end

  -- print('same')  -- documentHighlight same as previous highlight
end

--- 发送 documentHighlight 请求
local method = 'textDocument/documentHighlight'

local function highlight_references()
  local param = vim.lsp.util.make_position_params()
  vim.lsp.buf_request(0, method, param, handler)
end

--- 返回 documentHighlight 方法 --------------------------------------------------------------------
local M = {}

--- HACK: 解决的问题: CursorHold 过程中不要 clear_references(), 在判断 word 改变之后再 clear.
M.lsp_highlight = function (client, bufnr)
  --- Set autocommands conditional on server_capabilities
  --- 也可以使用 if client.resolved_capabilities.document_highlight 来判断.
  if client.supports_method(method) then
    local group_id = vim.api.nvim_create_augroup('lsp_document_highlight', {
      clear = true,
    })
    vim.api.nvim_create_autocmd({"CursorHold", "CursorHoldI"}, {
      group = group_id,
      buffer = bufnr,
      callback = highlight_references,
    })

    --- 在 cursor 进入另外一个 window 前, 或者在 window 加载其他的 buffer 前, 清除 clear highlight.
    vim.api.nvim_create_autocmd({"WinLeave", "BufWinLeave"}, {
      group = group_id,
      buffer = bufnr,
      callback = function(params)
        prev_doc_hi_pos = {}  -- 清空结果
        vim.lsp.buf.clear_references()  -- clear previous highlight
      end
    })
  end
end

return M
