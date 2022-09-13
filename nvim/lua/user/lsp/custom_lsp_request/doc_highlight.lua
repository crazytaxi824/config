--- HACK: PROBLEM: CursorMove 触发 clear_references() & CursorHold 触发 document_highlight(),
--- cursor 在同一个 document_highlight 的内部移动时造成闪烁.
---
--- SOLUTION: 重写 lsp.buf.document_highlight() 方法, 在其 handler 中对 lsp 返回的 result 进行
--- 有条件的 highlight_references() / clear_references().
---
--- handler 具体条件:
--- 缓存上一次 lsp 返回的 highlight result 结果, 和下一次的 result 进行对比,
--- 如果结果完全相同, 则直接返回, 不进行任何 highlight / clear 处理;
--- 如果结果不同则清除之前的 clear_references() highlight, 重新 document_highlight()
---
--- builtin vs custom document_highlight() 区别:
--- builtin 的 vim.lsp.buf.document_highlight() 方法中 handler 主要是对 lsp 返回的 result 进行 highlight;
--- custom 的 document highlight 方法中 handler 对 result 进行了有条件的 highlight_references() 和 clear_references()

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

--- sort response list 方便 compare -------------------------------------------- {{{
--- VVI: sort kind & start.line & start.character
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

local function sort_table(list)
  if #list < 1 then
    return
  end

  --- NOTE: some lsp response DO NOT have 'kind'.
  if list[1].kind then
    table.sort(list, function(i, j)  -- sort kind
      return i.kind < j.kind
    end)
  end
  table.sort(list, function(i, j)  -- sort start.line
    return i.range.start.line < j.range.start.line
  end)
  table.sort(list, function(i, j)  -- sort start.character, 同一行中多个 var 排序.
    return i.range.start.character < j.range.start.character
  end)
end
-- -- }}}

--- 判断两个 list 是否相同 ----------------------------------------------------- {{{
local function compare_sorted_table(t1, t2)
  if #t1 ~= #t2 then
    -- print('lists length are not the same')
    return
  end

  for i=1, #t1, 1 do
    --- NOTE: some lsp response DO NOT have 'kind'.
    if t1.kind and t1.kind ~= t2.kind then
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
-- -- }}}

local M = {}

--- cache 上一次的 documentHighlight 结果.
local prev_doc_hi_pos = {}

--- `:help lsp-handler`
--- custom lsp.buf_request() handler -------------------------------------------
local function doc_hl_handler(err, result, req, config)
  if err then
    require("user.lsp.custom_lsp_request.error_logger").log(err)
    Notify("doc_highlight_handler error", "ERROR")
    return
  end

  --- VVI: 没有结果的情况下, 有些 lsp 会返回 nil, 有些会返回 empty table {}. eg: cursor 在空白行.
  if not result or #result == 0 then
    --- clear cached result
    prev_doc_hi_pos = {}

    --- VVI: 这里不要使用 vim.lsp.buf.clear_references() 方法,
    --- 这个方法只能清除当前 buffer 的 highlight.
    vim.lsp.util.buf_clear_references(req.bufnr)  -- clear previous highlight
    return
  end

  sort_table(result)
  local r = compare_sorted_table(prev_doc_hi_pos, result)

  --- cache result to prev_doc_hi_pos
  prev_doc_hi_pos = result

  if not r then
    -- print('changed')  -- documentHighlight position changed

    --- VVI: 这里不要使用 vim.lsp.buf.clear_references() 方法,
    --- 这个方法只能清除当前 buffer 的 highlight.
    vim.lsp.util.buf_clear_references(req.bufnr)  -- clear previous highlight

    --- 为了获取 offset_encoding
    local client = vim.lsp.get_client_by_id(req.client_id)
    if not client then
      return
    end

    --- VVI: 这里不要使用 vim.lsp.buf.document_highlight(),
    --- 因为 document_highlight() 会重新发送 vim.lsp.buf_request('textDocument/documentHighlight').
    --- 而 vim.lsp.util.buf_highlight_references() 只渲染已获取的 result 结果.
    vim.lsp.util.buf_highlight_references(req.bufnr, result, client.offset_encoding)
  end

  -- print('same')  -- documentHighlight same as previous highlight
end

--- NOTE: 本函数相当于重写 vim.lsp.buf.document_highlight() 方法
--- vim.lsp.buf.document_highlight() 源代码 ------------------------------------ {{{
--- https://github.com/neovim/neovim/blob/master/runtime/lua/vim/lsp/buf.lua
--- function M.document_highlight()
---   local params = util.make_position_params()
---   request('textDocument/documentHighlight', params)
--- end
--- -- }}}
M.doc_highlight = function(bufnr)
  local param = vim.lsp.util.make_position_params()  -- lsp request's cursor position.
  vim.lsp.buf_request(bufnr, 'textDocument/documentHighlight', param, doc_hl_handler)
end

--- VVI: 这里不要使用 vim.lsp.buf.clear_references() 方法, 这个方法只能清除当前 buffer 的 highlight.
M.doc_clear = function(bufnr)
  --- clear cached result
  prev_doc_hi_pos = {}

  --- clear previous highlight
  vim.lsp.util.buf_clear_references(bufnr)
end

return M
