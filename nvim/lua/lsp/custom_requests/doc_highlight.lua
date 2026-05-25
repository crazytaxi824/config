-- 官方设置方法, `:help vim.lsp.buf.document_highlight()` ------------------------------------ {{{
-- color: "LspReferenceText", "LspReferenceRead", "LspReferenceWrite"
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
-- VVI: PROBLEM: CursorMove 触发 clear_references() & CursorHold 触发 document_highlight(),
-- cursor 在同一个 document_highlight 的内部移动时造成闪烁.

-- SOLUTION: 重写 lsp.buf.document_highlight() 方法, 在其 handler 中对 lsp 返回的 result 进行
-- 有条件的 highlight_references() / clear_references().
-- }}}

-- cursor 在未移出当前 documentHighlight <word> 的范围时不重新发送 vim.lsp.buf_request_all()

local ms = vim.lsp.protocol.Methods

-- cache last documentHighlight references
---@type { bufnr: integer, groups: { refs: lsp.DocumentHighlight[], offset_encoding?: string }[] }
local last_results = {}


local M = {}

---@param a_line integer
---@param a_char integer
---@param b_line integer
---@param b_char integer
local function pos_le(a_line, a_char, b_line, b_char)
  return a_line < b_line or (a_line == b_line and a_char <= b_char)
end

---@param a_line integer
---@param a_char integer
---@param b_line integer
---@param b_char integer
local function pos_lt(a_line, a_char, b_line, b_char)
  return a_line < b_line or (a_line == b_line and a_char <= b_char)
end

-- 判断当前 cursor 是否仍然在 range 之内
--
---@param bufnr integer
---@param refs lsp.DocumentHighlight[]
---@param offset_encoding? string
---@return boolean|nil inside
local function cursor_inside_range(bufnr, refs, offset_encoding)
  local row, byte_col = unpack(vim.api.nvim_win_get_cursor(0))
  local cur_line = row - 1

  -- 将 cursor col 根据 lsp offset_encoding 进行转换
  local text = vim.api.nvim_buf_get_lines(bufnr, cur_line, cur_line + 1, false)[1] or ''
  local cur_char = vim.str_utfindex(text, offset_encoding or 'utf-16', byte_col, false)

  for _, ref in ipairs(refs) do
    local range = ref.range
    if range then
      local s = range.start
      local e = range["end"]

      if pos_le(s.line, s.character, cur_line, cur_char)
        and pos_lt(cur_line, cur_char, e.line, e.character)
      then
        return true
      end
    end
  end

  return false
end

-- cursor is in any of the lsp clients highlight range
---@return boolean
local function cursor_inside_buf_ranges(bufnr)
  for _, group in ipairs(last_results.groups or {}) do
    if cursor_inside_range(bufnr, group.refs, group.offset_encoding) then
      return true
    end
  end
  return false
end

-- 创建 vim.lsp.buf_request_all(_, _, params, _) 中的 params
--
---@param params? table
---@return fun(client: vim.lsp.Client, bufnr: integer):table?
local function client_positional_params(params)
  local win = vim.api.nvim_get_current_win()
  return function(client)
    local ret = vim.lsp.util.make_position_params(win, client.offset_encoding)
    ret = vim.tbl_deep_extend('force', ret, params or {})
    return ret
  end
end

-- https://github.com/neovim/neovim/blob/master/runtime/lua/vim/lsp/buf.lua
-- 根据 M.hover(config) 函数中 vim.lsp.buf_request_all(_, _, _, handler) 中的 handler 修改
---@type lsp.MultiHandler
---@param results table<integer, { err: lsp.ResponseError?, result: lsp.DocumentHighlight[] }>
---@param ctx lsp.HandlerContext
local function doc_highlight_handler(results, ctx)
  local bufnr = assert(ctx.bufnr)
  if vim.api.nvim_get_current_buf() ~= bufnr then
    -- Ignore result since buffer changed. This happens for slow language servers.
    return
  end

  ---@type { refs: lsp.DocumentHighlight[], offset_encoding?: string }[]
  local groups = {}

  for client_id, resp in pairs(results) do
    local refs = resp.result or {}
    local err = resp.err

    if err then
      vim.lsp.log.error(err.code, err.message)
    elseif refs then
      local client = assert(vim.lsp.get_client_by_id(client_id))

      ---@type { refs: lsp.DocumentHighlight[], offset_encoding?: string }
      local group = {}
      group.refs = refs
      group.offset_encoding = client.offset_encoding
      table.insert(groups, group)

      vim.lsp.util.buf_highlight_references(bufnr, refs, client.offset_encoding)  -- NOTE: highlight references
    end
  end

  -- 刷新 cache 内容
  last_results = { bufnr=bufnr, groups=groups }
end

---@param client vim.lsp.Client
---@param bufnr integer
M.setup = function(client, bufnr)
  -- VVI: 这里必须使用 augroup, 否则在 `:LspRestart` 的情况下会叠加多个 autocmd.
  local group_id = vim.api.nvim_create_augroup("my_documentHighlight_#buf:"..bufnr, {clear=true})

  -- CursorHold 时, 如果没有超出 range 则不发送 documentHighlight 请求,
  -- 如果超出 range 则重新发送 documentHighlight 并 highlight references
  vim.api.nvim_create_autocmd({"CursorHold", "CursorHoldI"}, {
    group = group_id,
    buffer = bufnr,  -- 对指定 buffer 有效
    callback = function(args)
      if last_results.bufnr == bufnr and cursor_inside_buf_ranges(bufnr) then
        return
      end

      -- 清除旧 highlight
      if last_results.bufnr then
        vim.lsp.util.buf_clear_references(last_results.bufnr)
      end
      vim.lsp.util.buf_clear_references(bufnr)
      last_results = {}

      -- send 'textDocument/documentHighlight' request. 重新渲染 highlight
      vim.lsp.buf_request_all(bufnr, ms.textDocument_documentHighlight, client_positional_params(), doc_highlight_handler)
    end,
    desc = "LSP: documentHighlight",
  })

  -- cursor 离开 documentHighlight word 时清除 references highlight
  vim.api.nvim_create_autocmd({'CursorMovedI', 'CursorMoved'}, {
    group = group_id,
    buffer = bufnr,  -- 对指定 buffer 有效
    callback = function(args)
      if not last_results.bufnr then
        return
      end

      if last_results.bufnr ~= bufnr then
        vim.lsp.util.buf_clear_references(last_results.bufnr)
        last_results = {}
        return
      end

      if not cursor_inside_buf_ranges(bufnr) then
        vim.lsp.util.buf_clear_references(bufnr)
        last_results = {}
        return
      end
    end,
    desc = "LSP: clear highlight when cursor move out of word",
  })

  -- cursor 离开 window 时清除 references highlight
  -- 主要是用于进入了没有 lsp 的 buffer
  vim.api.nvim_create_autocmd({'WinLeave'}, {
    group = group_id,
    buffer = bufnr,  -- 对指定 buffer 有效
    callback = function(args)
      vim.lsp.util.buf_clear_references(bufnr)
      last_results = {}
    end,
    desc = "LSP: clear highlight when leave window",
  })

  -- bdelete buffer 的时会触发 LspDetach
  -- buffer 被 delete 时清除 references highlight, 同时删除整个 augroup
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
