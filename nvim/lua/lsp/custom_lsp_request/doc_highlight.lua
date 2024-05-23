--- VVI: PROBLEM: CursorMove 触发 clear_references() & CursorHold 触发 document_highlight(),
--- cursor 在同一个 document_highlight 的内部移动时造成闪烁.
---
--- SOLUTION: 重写 lsp.buf.document_highlight() 方法, 在其 handler 中对 lsp 返回的 result 进行
--- 有条件的 highlight_references() / clear_references().
---
--- `vim.lsp.buf.clear_references()`, Removes document highlights from current buffer.
--- `vim.lsp.util.buf_clear_references(bufnr)`, Removes document highlights from a buffer.

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

--- custom lsp.buf_request() handler -------------------------------------------
--- copy from `M[ms.textDocument_documentHighlight] = function(_, result, ctx, _)`
--- https://github.com/neovim/neovim/blob/master/runtime/lua/vim/lsp/handlers.lua
--- `:help lsp-handler`, lsp-request handler 的第一个参数为 err, 这里省略不处理.
local function doc_hl_handler(_, result, req, config)
  --- VVI: 没有结果的情况下, 有些 lsp 会返回 nil, 有些会返回 empty table {}. eg: cursor 在空白行.
  if not result or #result == 0 then
    vim.lsp.util.buf_clear_references(req.bufnr)
    return
  end

  --- vim.lsp.util.buf_highlight_references() highlights results.
  local client = vim.lsp.get_client_by_id(req.client_id)
  if not client then
    return
  end
  --- 这里不要使用 vim.lsp.buf.document_highlight(), 会重新发送 vim.lsp.buf_request('textDocument/documentHighlight').
  --- 而 vim.lsp.util.buf_highlight_references() 只渲染已获取的 result 结果.
  vim.lsp.util.buf_highlight_references(req.bufnr, result, client.offset_encoding)

  --- CursorMoved clear documentHighlight.
  local group_id = vim.api.nvim_create_augroup("my_documentHighlight_CursorMoved_#"..req.client_id..'_#'..req.bufnr, {clear=true})
  vim.api.nvim_create_autocmd({"CursorMoved", "CursorMovedI"}, {
    group = group_id,
    buffer = req.bufnr,  -- 对指定 buffer 有效
    callback = function(params)
      --- getcharpos(): 1-index
      local cur_pos = vim.fn.getcharpos('.')
      local cur_line, cur_col = cur_pos[2]-1, cur_pos[3]-1

      --- result.range: 0-index
      for _, ref in ipairs(result) do
        local start_line, start_char = ref['range']['start']['line'], ref['range']['start']['character']
        local end_line, end_char = ref['range']['end']['line'], ref['range']['end']['character']
        if cur_line >= start_line and cur_col >= start_char and cur_line <= end_line and cur_col <= end_char then
          --- cursor still in references range.
          return
        end
      end

      vim.lsp.util.buf_clear_references(req.bufnr)
      vim.api.nvim_del_augroup_by_id(group_id)
    end,
    desc = "LSP: documentHighlight",
  })
end

--- VVI: 自定义 documentHighlight handler.
vim.lsp.handlers["textDocument/documentHighlight"] = doc_hl_handler

local M = {}

M.setup = function(client, bufnr)
  --- VVI: 这里必须使用 augroup, 否则在 `:LspRestart` 的情况下会叠加多个 autocmd.
  local group_id = vim.api.nvim_create_augroup("my_documentHighlight_#"..client.id..'_#'..bufnr, {clear=true})

  --- documentHighlight
  vim.api.nvim_create_autocmd({"CursorHold", "CursorHoldI"}, {
    group = group_id,
    buffer = bufnr,  -- 对指定 buffer 有效
    callback = function(params)
      --- send 'textDocument/documentHighlight' request.
      vim.lsp.buf.document_highlight()
    end,
    desc = "LSP: documentHighlight",
  })

  --- delete documentHighlight augroup
  --- NOTE: 这里必须使用 BufDelete, 否则 buffer 如果更改了 filetype 只能使用 :bwipeout 来删除 documentHighlight
  vim.api.nvim_create_autocmd({'LspDetach', 'BufDelete', 'BufWipeout'}, {
    group = group_id,
    buffer = bufnr,  -- 对指定 buffer 有效
    callback = function(params)
      vim.lsp.util.buf_clear_references(params.buf)
      vim.api.nvim_del_augroup_by_id(group_id)
    end,
    desc = "LSP: delete documentHighlight augroup",
  })
end

return M
