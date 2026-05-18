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
--- }}}

--- cursor 在未移出当前 documentHighlight <word> 的范围时不重新发送 vim.lsp.buf_request_all()

local ms = vim.lsp.protocol.Methods

--- cache last documentHighlight references
--- @type {bufnr: integer, refs: lsp.DocumentHighlight[]}
local last_results = {}


local M = {}

--- 判断当前 cursor 是否仍然在 range 之内
---
--- @param refs lsp.DocumentHighlight[]
--- @return boolean|nil inside
local function cursor_inside_range(refs)
  --- getcharpos(): 1-index
  local cur_pos = vim.fn.getcharpos('.')
  local cur_line, cur_col = cur_pos[2]-1, cur_pos[3]-1

  --- result.range: 0-index
  for _, ref in ipairs(refs) do
    local start_line, start_char = ref['range']['start']['line'], ref['range']['start']['character']
    local end_line, end_char = ref['range']['end']['line'], ref['range']['end']['character']
    if cur_line >= start_line and cur_col >= start_char and cur_line <= end_line and cur_col <= end_char then
      return true  --- cursor still inside references range
    end
  end
end

--- 创建 vim.lsp.buf_request_all(_, _, params, _) 中的 params
---
--- @param params? table
--- @return fun(client: vim.lsp.Client, bufnr: integer):table?
local function client_positional_params(params)
  local win = vim.api.nvim_get_current_win()
  return function(client)
    local ret = vim.lsp.util.make_position_params(win, client.offset_encoding)
    ret = vim.tbl_deep_extend('force', ret, params or {})
    return ret
  end
end

--- 根据 https://github.com/neovim/neovim/blob/master/runtime/lua/vim/lsp/buf.lua 中 M.hover(config) 函数修改
---
--- 创建 vim.lsp.buf_request_all(_, _, _, handler) 中的 handler
---
--- @param results table<integer,{err: lsp.ResponseError?, result: any}>
--- @param ctx lsp.HandlerContext
local function doc_highlight_handler(results, ctx)
  local bufnr = assert(ctx.bufnr)
  if vim.api.nvim_get_current_buf() ~= bufnr then
    -- Ignore result since buffer changed. This happens for slow language servers.
    return
  end

  --- @type lsp.DocumentHighlight[]
  local cache = {}

  for client_id, resp in pairs(results) do
    local err = resp.err
    local refs = resp.result or {}
    if err then
      vim.lsp.log.error(err.code, err.message)
    elseif refs then
      cache = vim.list_extend(cache, refs)
      local client = assert(vim.lsp.get_client_by_id(client_id))
      vim.lsp.util.buf_highlight_references(bufnr, refs, client.offset_encoding)  -- NOTE: highlight references
    end
  end

  --- VVI: cache result
  last_results = { bufnr = bufnr, refs = cache }
end

M.setup = function (client, bufnr)
  --- VVI: 这里必须使用 augroup, 否则在 `:LspRestart` 的情况下会叠加多个 autocmd.
  local group_id = vim.api.nvim_create_augroup("my_documentHighlight_#buf:"..bufnr, {clear=true})

  --- CursorHold 时, 如果没有超出 range 则不发送 documentHighlight 请求,
  --- 如果超出 range 则重新发送 documentHighlight 并 highlight references
  vim.api.nvim_create_autocmd({"CursorHold", "CursorHoldI"}, {
    group = group_id,
    buffer = bufnr,  -- 对指定 buffer 有效
    callback = function(args)
      if last_results.bufnr and last_results.bufnr == bufnr
        and last_results.refs and #last_results.refs > 0
        and cursor_inside_range(last_results.refs)
      then
        return
      end

      --- 清除旧 highlight
      vim.lsp.util.buf_clear_references(bufnr)

      --- send 'textDocument/documentHighlight' request. 重新渲染 highlight
      vim.lsp.buf_request_all(bufnr, ms.textDocument_documentHighlight, client_positional_params(), doc_highlight_handler)
    end,
    desc = "LSP: documentHighlight",
  })

  --- cursor 离开 documentHighlight word 时清除 references highlight
  vim.api.nvim_create_autocmd({'CursorMovedI', 'CursorMoved'}, {
    group = group_id,
    buffer = bufnr,  -- 对指定 buffer 有效
    callback = function(args)
      if last_results.bufnr and last_results.bufnr == bufnr
        and last_results.refs and #last_results.refs > 0
        and not cursor_inside_range(last_results.refs)
      then
        vim.lsp.util.buf_clear_references(bufnr)
      end
    end,
    desc = "LSP: clear highlight when cursor move out of word",
  })

  --- cursor 离开 window 时清除 references highlight
  vim.api.nvim_create_autocmd({'WinLeave'}, {
    group = group_id,
    buffer = bufnr,  -- 对指定 buffer 有效
    callback = function(args)
      last_results = {}
      vim.lsp.util.buf_clear_references(bufnr)
    end,
    desc = "LSP: clear highlight when leave window",
  })

  --- bdelete buffer 的时会触发 LspDetach
  --- buffer 被 delete 时清除 references highlight, 同时删除整个 augroup
  vim.api.nvim_create_autocmd({'LspDetach', 'BufDelete', 'BufWipeout'}, {
    group = group_id,
    once = true,
    buffer = bufnr,  -- 对指定 buffer 有效
    callback = function(args)
      last_results = {}
      vim.lsp.util.buf_clear_references(bufnr)
      vim.api.nvim_del_augroup_by_id(group_id)
    end,
    desc = "LSP: delete documentHighlight augroup",
  })
end

return M
