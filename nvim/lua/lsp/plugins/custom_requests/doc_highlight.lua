local ms = require('vim.lsp.protocol').Methods

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

local function client_positional_params(params)
  local win = vim.api.nvim_get_current_win()
  return function(client)
    local ret = vim.lsp.util.make_position_params(win, client.offset_encoding)
    if params then
      ret = vim.tbl_extend('force', ret, params)
    end
    return ret
  end
end

--- 根据 vim.lsp.buf.hover() 方法修改. https://github.com/neovim/neovim/blob/master/runtime/lua/vim/lsp/buf.lua
--- textDocument_documentHighlight, https://github.com/neovim/neovim/blob/master/runtime/lua/vim/lsp/handlers.lua
--- results: {  --- {{{
--- client_id1 = {
---   kind=1,
---   range={
---     start = {
---       line = ...
---       character = ...
---     },
---     end = {
---       line = ...
---       character = ...
---     },
---   }
--- },
--- client_id2 = {
---   ...
--- }
--- ...
--- }
-- -- }}}
local function doc_highlight_handler(results, ctx)
  local bufnr = assert(ctx.bufnr)
  if vim.api.nvim_get_current_buf() ~= bufnr then
    -- Ignore result since buffer changed. This happens for slow language servers.
    return
  end

  -- Filter errors from results
  local results1 = {} --- @type table<integer,lsp.Hover>

  for client_id, resp in pairs(results) do
    local err, result = resp.err, resp.result
    if err then
      vim.lsp.log.error(err.code, err.message)
    elseif result then
      results1[client_id] = result  -- results1: { client_id1 = {}, client_id2 = {} ... }
    end
  end

  --- No information available
  if vim.tbl_isempty(results1) then
    return
  end

  --- results: { client_id1 = {}, client_id2 = {} ... }
  for client_id, result in pairs(results1) do
    local client = assert(vim.lsp.get_client_by_id(client_id))

    --- VVI: vim.lsp.util.buf_highlight_references() 用于渲染 result 结果.
    vim.lsp.util.buf_highlight_references(bufnr, result, client.offset_encoding)

    --- augroup id
    local group_id = vim.api.nvim_create_augroup("my_documentHighlight_CursorMoved_#lsp:"..client_id..'_#buf:'..bufnr, {clear=true})

    vim.api.nvim_create_autocmd({"CursorMoved", "CursorMovedI"}, {
      group = group_id,
      buffer = bufnr,  -- 对指定 buffer 有效
      callback = function(params)
        --- getcharpos(): 1-index
        local cur_pos = vim.fn.getcharpos('.')
        local cur_line, cur_col = cur_pos[2]-1, cur_pos[3]-1

        --- result.range: 0-index
        for _, ref in ipairs(result) do
          local start_line, start_char = ref['range']['start']['line'], ref['range']['start']['character']
          local end_line, end_char = ref['range']['end']['line'], ref['range']['end']['character']
          if cur_line >= start_line and cur_col >= start_char and cur_line <= end_line and cur_col <= end_char then
            --- VVI: cursor still in references range, do nothing.
            return
          end
        end

        --- else, remove highlight
        vim.lsp.util.buf_clear_references(bufnr)
        vim.api.nvim_del_augroup_by_id(group_id)
      end,
      desc = "LSP: documentHighlight CursorMove clear_references",
    })

    vim.api.nvim_create_autocmd({"WinLeave"}, {
      group = group_id,
      buffer = bufnr,  -- 对指定 buffer 有效
      callback = function(params)
        vim.lsp.util.buf_clear_references(bufnr)
        vim.api.nvim_del_augroup_by_id(group_id)
      end,
      desc = "LSP: documentHighlight WinLeave clear_references",
    })
  end
end

M.setup = function(client, bufnr)
  --- VVI: 这里必须使用 augroup, 否则在 `:LspRestart` 的情况下会叠加多个 autocmd.
  local group_id = vim.api.nvim_create_augroup("my_documentHighlight_#lsp:"..client.id..'_#buf:'..bufnr, {clear=true})

  --- documentHighlight
  vim.api.nvim_create_autocmd({"CursorHold", "CursorHoldI"}, {
    group = group_id,
    buffer = bufnr,  -- 对指定 buffer 有效
    callback = function(params)
      --- send 'textDocument/documentHighlight' request.
      vim.lsp.buf_request_all(bufnr, ms.textDocument_documentHighlight, client_positional_params(), doc_highlight_handler)
    end,
    desc = "LSP: documentHighlight",
  })

  --- delete documentHighlight augroup
  --- VVI: 这里必须使用 BufDelete, 否则 buffer 如果更改了 filetype 只能使用 :bwipeout 来删除 documentHighlight
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
