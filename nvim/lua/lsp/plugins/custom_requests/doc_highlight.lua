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
--
--- VVI: PROBLEM: CursorMove 触发 clear_references() & CursorHold 触发 document_highlight(),
--- cursor 在同一个 document_highlight 的内部移动时造成闪烁.

--- SOLUTION: 重写 lsp.buf.document_highlight() 方法, 在其 handler 中对 lsp 返回的 result 进行
--- 有条件的 highlight_references() / clear_references().
-- -- }}}

local M = {}

M.setup = function(client, bufnr)
  --- VVI: 这里必须使用 augroup, 否则在 `:LspRestart` 的情况下会叠加多个 autocmd.
  local group_id = vim.api.nvim_create_augroup("my_documentHighlight_#"..client.id..'_#'..bufnr, {clear=true})

  --- documentHighlight
  vim.api.nvim_create_autocmd({"CursorHold", "CursorHoldI"}, {
    group = group_id,
    buffer = bufnr,  -- 对指定 buffer 有效
    callback = function(params)
      --- TODO: 如果 doc_highlight 存在则不执行 vim.lsp.buf.document_highlight()

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
