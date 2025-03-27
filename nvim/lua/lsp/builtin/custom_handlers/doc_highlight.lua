--- VVI: 自定义 documentHighlight handler.
--- copy from `M[ms.textDocument_documentHighlight] = function(_, result, ctx, _)`
--- https://github.com/neovim/neovim/blob/master/runtime/lua/vim/lsp/handlers.lua
vim.lsp.handlers["textDocument/documentHighlight"] = function(_, result, req, config)
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

  --- 这里不要使用 vim.lsp.buf.document_highlight(), document_highlight() 会发送 request 给 lsp,
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
    desc = "LSP: documentHighlight CursorMove clear_references",
  })

  vim.api.nvim_create_autocmd({"WinLeave"}, {
    group = group_id,
    buffer = req.bufnr,  -- 对指定 buffer 有效
    callback = function(params)
      vim.lsp.util.buf_clear_references(req.bufnr)
      vim.api.nvim_del_augroup_by_id(group_id)
    end,
    desc = "LSP: documentHighlight WinLeave clear_references",
  })
end



