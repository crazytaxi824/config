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
  if #list < 1 then
    return
  end

  --- NOTE: some lsp response DO NOT have 'kind'.
  if list[1].kind then
    table.sort(list, function(i, j)  -- compare kind
      return i.kind < j.kind
    end)
  end
  table.sort(list, function(i, j)  -- compare start.line
    return i.range.start.line < j.range.start.line
  end)
  table.sort(list, function(i, j)  -- compare start.character, 同一行中多个 var 排序.
    return i.range.start.character < j.range.start.character
  end)
end

--- 判断两个 list 是否相同
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

--- cache 上一次的 documentHighlight 结果.
local prev_doc_hi_pos = {}

--- `:help lsp-handler`
local function handler(err, result, req, config)
  if err then
    local debug = "error message:\n" .. vim.inspect(err) ..
      "lsp request:\n" .. vim.inspect(req) ..
      "result:\n" .. vim.inspect(result)
    Notify(debug, "ERROR")
    return
  end

  --- VVI: 没有结果的情况下, 有些 lsp 会返回 nil, 有些会返回 empty table {}. eg: cursor 在空白行.
  if not result or #result == 0 then
    prev_doc_hi_pos = {}  -- clear cached result

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

    --- VVI: 这里不要使用 vim.lsp.buf.document_highlight(),
    --- 因为这个方法会重新发送 buf_request('textDocument/documentHighlight').
    --- vim.lsp.util.buf_highlight_references() 只渲染结果.
    local client = vim.lsp.get_client_by_id(req.client_id)
    if not client then
      return
    end
    vim.lsp.util.buf_highlight_references(req.bufnr, result, client.offset_encoding)
  end

  -- print('same')  -- documentHighlight same as previous highlight
end

--- 发送 documentHighlight 请求
local method = 'textDocument/documentHighlight'

--- NOTE: 本函数相当于替代 vim.lsp.buf.document_highlight() 方法.
local function highlight_references(bufnr)
  local param = vim.lsp.util.make_position_params()
  vim.lsp.buf_request(bufnr, method, param, handler)
end

--- 返回自定义 documentHighlight 处理方法 ----------------------------------------------------------
--- NOTE: 主要是用于替代 vim.lsp.buf.document_highlight() 方法.
local M = {}

--- HACK: 问题: CursorMove 触发 clear_references() & CursorHold 触发 document_highlight(),
--- cursor 在同一个 document_highlight 的内部移动时造成闪烁.
--- 解决办法: 缓存上一次 lsp 返回的 highlight 结果, 和这一次的进行对比,
--- 如果结果完全相同, 则直接返回;
--- 如果结果不同则清除之前的 clear_references() highlight, 重新 document_highlight()
M.lsp_highlight = function (client, bufnr)
  --- Set autocommands conditional on server_capabilities
  --- 也可以使用 if client.resolved_capabilities.document_highlight 来判断.
  if client.supports_method(method) then
    vim.api.nvim_create_autocmd({"CursorHold", "CursorHoldI"}, {
      buffer = bufnr,
      callback = function(params)
        --- 使用自定义的 documentHighlight 请求处理, 代替 vim.lsp.buf.document_highlight()
        --- VVI: 千万不能使用 lsp_highlight(client, bufnr) 中传入的 bufnr,
        --- 因为 lsp_highlight() 只在 on_attach 的时候执行一次.
        highlight_references(params.buf)
      end,
    })

    --- 在 cursor 进入另外一个 window 前, 或者在 window 加载其他的 buffer 前, 清除 clear highlight.
    vim.api.nvim_create_autocmd({"WinLeave", "BufWinLeave"}, {
      buffer = bufnr,
      callback = function(params)
        prev_doc_hi_pos = {}  -- clear cached result

        --- NOTE: 这里不要使用 vim.lsp.buf.clear_references() 方法,
        --- 这个方法只能清除当前 buffer 的 highlight.
        --- VVI: 千万不能使用 lsp_highlight(client, bufnr) 中传入的 bufnr,
        --- 因为 lsp_highlight() 只在 on_attach 的时候执行一次.
        vim.lsp.util.buf_clear_references(params.buf)
      end
    })
  end
end

return M
