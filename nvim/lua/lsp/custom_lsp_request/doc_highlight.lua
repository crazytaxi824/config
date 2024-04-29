--- VVI: PROBLEM: CursorMove 触发 clear_references() & CursorHold 触发 document_highlight(),
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
---  - builtin 的 vim.lsp.buf.document_highlight() 方法中 handler 主要是对
---    lsp 返回的 result 进行 highlight;
---  - custom 的 document highlight 方法中 handler 对 result 进行了有条件的
---    highlight_references() 和 clear_references()

--- 官方设置方法, `:help vim.lsp.buf.document_highlight()` ------------------------------------ {{{
--- color: "LspReferenceText", "LspReferenceRead", "LspReferenceWrite"
--
--  vim.cmd [[
--    augroup lsp_document_highlight
--      autocmd! * <buffer>
--      autocmd CursorHold <buffer> lua vim.lsp.buf.clear_references() vim.lsp.buf.document_highlight()
--      autocmd CursorHoldI <buffer> lua vim.lsp.buf.clear_references() vim.lsp.buf.document_highlight()  -- insert mode
--      autocmd CursorMoved <buffer> lua vim.lsp.buf.clear_references()
--      autocmd CursorMovedI <buffer> lua vim.lsp.buf.clear_references()   -- insert mode
--      autocmd ModeChanged * lua vim.lsp.buf.clear_references()
--    augroup END
--  ]]
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
    --- line 相同时对比 character.
    if i.range.start.line == j.range.start.line then
      return i.range.start.character < j.range.start.character
    end
    --- line 不同时对比 line.
    return i.range.start.line < j.range.start.line
  end)
end
-- -- }}}

local M = {}

--- 缓存上一次的 documentHighlight 结果. {[bufnr] = hl_result}
local prev_doc_hl

--- `:help lsp-handler`
--- custom lsp.buf_request() handler -------------------------------------------
local function doc_hl_handler(err, result, req, config)
  if err then
    require("lsp.custom_lsp_request.error_logger").log("doc_highlight_handler", req, err)
    Notify("doc_highlight_handler error", "ERROR")
    return
  end

  --- VVI: 没有结果的情况下, 有些 lsp 会返回 nil, 有些会返回 empty table {}. eg: cursor 在空白行.
  if not result or #result == 0 then
    --- clear previous result
    prev_doc_hl = nil

    --- VVI: 这里不要使用 vim.lsp.buf.clear_references() 方法,
    --- 这个方法只能清除当前 buffer 的 highlight.
    vim.lsp.util.buf_clear_references(req.bufnr)  -- clear previous highlight
    return
  end

  --- 给结果排序
  sort_table(result)

  --- json_encode result
  local je = vim.fn.json_encode(result)

  --- compare previous result with new result
  local r = prev_doc_hl and prev_doc_hl[req.bufnr] == je

  --- cache new result
  prev_doc_hl = {[req.bufnr] = je}

  --- previous result 和 new result 不相同的情况.
  if not r then
    --- VVI: 这里不要使用 vim.lsp.buf.clear_references() 方法,
    --- 这个方法只能清除当前 buffer 的 highlight.
    vim.lsp.util.buf_clear_references(req.bufnr)  -- clear previous highlight

    --- 获取 client.offset_encoding
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
  --- VVI: vim.lsp.buf_request() 没有文档, 可以查看源代码.
  vim.lsp.buf_request(bufnr, 'textDocument/documentHighlight', param, doc_hl_handler)
end

--- clear previous highlight
M.doc_clear = function(bufnr)
  --- clear cached result
  prev_doc_hl = nil

  --- clear previous highlight
  --- VVI: 这里不要使用 vim.lsp.buf.clear_references() 方法, 这个方法只能清除当前 buffer 的 highlight.
  --- vim.lsp.util.buf_clear_references(bufnr) 清除指定 bufnr 的 highlight.
  vim.lsp.util.buf_clear_references(bufnr)
end

return M
