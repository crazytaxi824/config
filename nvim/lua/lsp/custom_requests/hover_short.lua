-- 自定义 hover_short handler 用于在写代码的过程中可以迅速查看方法中的参数类型, 而不用移动光标或退出 insert mode.
-- 实现方法: 获取光标所在 method/func 的名字, 简化 "textDocument/hover" 返回内容.
-- 根据 vim.lsp.buf.hover() 方法修改. https://github.com/neovim/neovim/blob/master/runtime/lua/vim/lsp/buf.lua
-- 主要修改部分:
--   1. vim.lsp.util.make_position_params() 获取 cursor position. 通过 treesitter 找到 cursor
--      前面的 function node 的 position,  位置发送给 lsp server.
--   2. 将上述 func_position 通过 vim.lsp.buf_request_all("textDocument/hover", func_position) 向 lsp server 发送请求.
--   3. 修改 lsp server 返回的内容用于 floating window 显示: 只保留 lsp server 返回内容的第一行.
--   4. 修改 floating window 的位置.

local ms = vim.lsp.protocol.Methods

local M = {}

-- NOTE: 这里 row 和 char_pos 都是从 0 开始计算.
--
---@param lsp_req_pos_line integer
---@param lsp_req_pos_char integer  char_pos 是指行内第几个字符, \t 算一个字符.
---@return table
local function calculate_offset(lsp_req_pos_line, lsp_req_pos_char)
  local cursor_line, cursor_col = unpack(vim.api.nvim_win_get_cursor(0))  -- (1,0)-indexed

  -- VVI: offset 中 \t 占4个字符位置, 而在 getpos() 和 node:start() 中只占1个字符.
  -- strdisplaywidth() 会计算实际显示宽度, \t 会被计算在显示宽度之内.
  -- node 行 virtual column 位置.
  local node_display_width = vim.fn.strdisplaywidth(
    string.sub(vim.fn.getline(lsp_req_pos_line+1), 0, lsp_req_pos_char)
  )
  -- cursor 行 virtual column 位置.
  local cursor_display_width = vim.fn.strdisplaywidth(
    string.sub(vim.fn.getline(cursor_line), 0, cursor_col)
  )

  -- 计算 open_floating_preview() 横向/纵向偏移量
  local offset_x = node_display_width - cursor_display_width
  local offset_y = lsp_req_pos_line - cursor_line +1

  return {
    lsp_req_pos_line = lsp_req_pos_line,
    lsp_req_pos_char = lsp_req_pos_char,
    offset_x = offset_x,
    offset_y = offset_y,
  }
end

-- 计算 argument list 前面一个 node 的 start 位置.
--
---@param row integer
---@param col integer
---@return table
local function node_before_arguments(row, col)
  local node_before_args = vim.treesitter.get_node({pos={row, col}})
  if not node_before_args then
    error('debug: no node before arguments|argument_list node')
  end

  row, col, _ = node_before_args:start()
  return calculate_offset(row, col)
end

-- NOTE: 使用 nvim-treesitter 寻找 cursor 前最近的 function call() 的位置 ----- {{{
-- `:help treesitter`
--    node:start()  -- start pos, return [row, (col), totalbytes]
--    node:end_()   -- end pos
--    node:parent() -- 父级 node, 查找 arguments
--    node:prev_sibling()  -- 查找 function
--    node:next_sibling()
--    node:prev_named_sibling()  -- 查找 function
--    node:next_named_sibling()
--    node:type()   -- treesitter 分析
--        selector_expression  -- '.'
--        argument_list  -- func call '(xxx)' 中的所有内容, 包括括号 ().
--        func call 名字 -- call_expression.function.field
-- }}}
--
---@return table|nil
local function find_fn_call_before_cursor()
  -- 获取 node at cursor.
  local cur_line, cur_col = unpack(vim.api.nvim_win_get_cursor(0))
  local node = vim.treesitter.get_node({pos={cur_line-1, cur_col}})

  -- 向上(parent)寻找 'argument_list' / 'arguments' node.
  -- eg: fn("bar") 中 `("bar")` 属于 arguments, 包括括号.
  -- NOTE: 'go, py' use 'argument_list'; 'js, ts, lua' use 'arguments'.
  local args_type_name = {'argument_list', 'arguments'}

  while node do
    if vim.tbl_contains(args_type_name, node:type()) then
      -- 判断 arguments/argument_list 前一个 node 是否 type_arguments(generic type param)
      local prev_node = node:prev_named_sibling()
      if not prev_node then
        error('debug: arguments|argument_list missing previous named sibling node.')
      end

      if prev_node:type() == 'type_arguments' then
        -- 如果是 type_arguments 则返回 type_arguments node 前一个字符位置.
        local row, col, _ = prev_node:start()
        return node_before_arguments(row, col-1)
      end

      -- 如果前面不是 type_arguments 则返回本身 node 的前一个字符位置.
      -- argument_list start position 即 '(' 的位置. row, col 都是从 0 开始计算位置.
      local row, col, _ = node:start()
      return node_before_arguments(row, col-1)
    end

    node = node:parent()  -- 循环向上查找, 如果到了 root node 也没找到的话, node:parent() 返回 nil.
  end
end

-- cache hover winid
local hover_winid

-- toggle hover window
function M.toggle_hover_short()
  if hover_winid and vim.api.nvim_win_is_valid(hover_winid) then
    vim.api.nvim_win_close(hover_winid, true)
    hover_winid = nil
  else
    local fn_node = find_fn_call_before_cursor()
    if not fn_node then  -- 如果 cursor 不在 'arguments' 内, 则结束.
      return
    end

    -- NOTE: 修改 position 为 cursor position 前面的 func_position
    local pos_params = {
      position = {
        line = fn_node.lsp_req_pos_line,       -- line 从 0 开始计算.
        character = fn_node.lsp_req_pos_char,  -- char 从 0 开始计算.
      }
    }

    -- NOTE: 生成 config, 修改 hover_short floating window 显示的位置
    ---@type vim.lsp.buf.hover.Opts
    local config = {
      offset_x = fn_node.offset_x,
      offset_y = fn_node.offset_y,
      focusable = false,
      border = Nerd_icons.border,
      anchor_bias = 'above',
      max_width = math.floor(vim.go.columns * 0.8),
      close_events = { "WinScrolled" },
      silent = true,  -- 有些 linter 类型的 lsp 不返回任何 result, 导致 handler 报错.
    }

    M.hover_short(config, pos_params)
  end
end

-- VVI: 以下代码大多从源代码中复制 ----------------------------------------------------------------
-- 根据 https://github.com/neovim/neovim/blob/master/runtime/lua/vim/lsp/buf.lua 中 M.hover(config) 函数修改

local api = vim.api
local lsp = vim.lsp
local validate = vim.validate

--- @param params? table
--- @return fun(client: vim.lsp.Client): lsp.TextDocumentPositionParams
local function client_positional_params(params)
  local win = api.nvim_get_current_win()
  return function(client)
    local ret = lsp.util.make_position_params(win, client.offset_encoding)
    if params then
      ret = vim.tbl_extend('force', ret, params)
    end
    return ret
  end
end

local hover_ns = api.nvim_create_namespace('nvim.lsp.hover_range')

--- Returns false if the LSP response is stale and should be discarded.
--- @param ctx lsp.HandlerContext
--- @return boolean
local function ctx_is_valid(ctx)
  local bufnr = ctx.bufnr
  if
    not bufnr
    or not api.nvim_buf_is_valid(bufnr)
    or api.nvim_get_current_buf() ~= bufnr
    or vim.lsp.util.buf_versions[bufnr] ~= ctx.version
  then
    return false
  end
  ---@type lsp.Position?
  local p = ctx.params and ctx.params.position
  if not p then
    return true
  end

  local c = lsp.get_client_by_id(ctx.client_id)
  local enc = c and c.offset_encoding
  if not enc then
    return false
  end

  -- >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
  -- 不要检查 cursor postion
  -- local cur_pos = vim.pos.cursor(bufnr, api.nvim_win_get_cursor(0))
  -- local pos = vim.pos.lsp(bufnr, p, enc)
  -- return cur_pos == pos
  return true
  -- <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<
end

-- 只获取 textDocument/hover 中 signature 部分
function M.hover_short(config, pos_params)
  validate('config', config, 'table', true)

  config = config or {}
  config.focus_id = 'textDocument/hover'

  -- >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
  -- 向 client_positional_params() 传入 params
  lsp.buf_request_all(0, ms.textDocument_hover, client_positional_params(pos_params), function(results, ctx)
  -- <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<
    local bufnr = ctx.bufnr
    if not bufnr or not ctx_is_valid(ctx) then
      return -- Ignore result if context changed. Can happen for slow LS.
    end

    -- Filter errors from results
    local results1 = {} --- @type table<integer,lsp.Hover>
    local nresults = 0
    local empty_response = false

    for client_id, resp in pairs(results) do
      local err, result = resp.err, resp.result
      if err then
        lsp.log.error(err.code, err.message)
      elseif result and result.contents then
        -- Make sure the response is not empty
        -- Five response shapes:
        -- - MarkupContent: { kind="markdown", value="doc" }
        -- - MarkedString-string: "doc"
        -- - MarkedString-pair: { language="c", value="doc" }
        -- - MarkedString[]-string: { "doc1", ... }
        -- - MarkedString[]-pair: { { language="c", value="doc1" }, ... }
        local valid = false
        if type(result.contents) == 'table' then
          local value_len = #(
            vim.tbl_get(result.contents, 'value') -- MarkupContent or MarkedString-pair
            or vim.tbl_get(result.contents, 1, 'value') -- MarkedString[]-pair
            or result.contents[1] -- MarkedString[]-string
            or ''
          )
          valid = value_len > 0
        elseif type(result.contents) == 'string' then
          valid = #result.contents > 0
        end

        if valid then
          results1[client_id] = result
          nresults = nresults + 1
        else
          empty_response = true
        end
      end
    end

    if nresults == 0 then
      if config.silent ~= true then
        if empty_response then
          vim.notify('Empty hover response', vim.log.levels.INFO)
        else
          vim.notify('No information available', vim.log.levels.INFO)
        end
      end
      return
    end

    local contents = {} --- @type string[]
    local MarkupKind = lsp.protocol.MarkupKind
    local format = MarkupKind.Markdown

    -- results1: { client_id1 = {}, client_id2 = {} ... }
    for client_id, result in pairs(results1) do
      local client = assert(lsp.get_client_by_id(client_id))
      if nresults > 1 then
        -- Show client name if there are multiple clients
        contents[#contents + 1] = string.format('# %s', client.name)
      end

      if type(result.contents) == 'table' and result.contents.kind == MarkupKind.PlainText then
        if nresults == 1 then
          -- Only one client: use PlainText format
          format = MarkupKind.PlainText
          contents = vim.split(result.contents.value or '', '\n', { trimempty = true })
        else
          -- Multiple clients: surround plaintext with ``` to get correct formatting
          contents[#contents + 1] = '```'
          vim.list_extend(
            contents,
            vim.split(result.contents.value or '', '\n', { trimempty = true })
          )
          contents[#contents + 1] = '```'
        end
      else
        -- 这里是 MarkupKind.Markdown format
        -- >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
        -- 修改 lsp server 返回的内容用于 floating window 显示: 只保留 lsp server 返回内容的第一行.
        -- 寻找 "```" end line, 忽略后面的所有内容
        local tmp = {}
        for _, line in ipairs(vim.lsp.util.convert_input_to_markdown_lines(result.contents)) do
          table.insert(tmp, line)
          if line == '```' then
            break
          end
        end
        -- <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<
        vim.list_extend(contents, tmp)
      end
      if result.range then
        local range = vim.range.lsp(bufnr, result.range, client.offset_encoding)

        vim.hl.range(
          bufnr,
          hover_ns,
          'LspReferenceTarget',
          { range.start_row, range.start_col },
          { range.end_row, range.end_col },
          { priority = vim.hl.priorities.user }
        )
      end
      contents[#contents + 1] = '---'
    end

    -- Remove last linebreak ('---') if contents is not empty
    if #contents > 0 then
      contents[#contents] = nil
    end

    -- >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
    -- cache win_id
    _, hover_winid = lsp.util.open_floating_preview(contents, format, config)

    -- 简化 nvim_buf_clear_namespace
    vim.api.nvim_create_autocmd('WinClosed', {
      pattern = tostring(hover_winid),
      once = true,
      callback = function()
        vim.api.nvim_buf_clear_namespace(bufnr, hover_ns, 0, -1)
        return true
      end,
    })
    -- <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<
  end)
end

return M
