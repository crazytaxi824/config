--- 自定义 hover_short handler 用于在写代码的过程中可以迅速查看方法中的参数类型, 而不用移动光标或退出 insert mode.
--- 实现方法: 获取光标所在 method/func 的名字, 简化 "textDocument/hover" 返回内容.
--- 根据 vim.lsp.buf.hover() 方法修改. https://github.com/neovim/neovim/blob/master/runtime/lua/vim/lsp/buf.lua
--- 主要修改部分:
---   1. vim.lsp.util.make_position_params() 获取 cursor position. 通过 treesitter 找到 cursor
---      前面的 function node 的 position,  位置发送给 lsp server.
---   2. 将上述 func_position 通过 vim.lsp.buf_request_all("textDocument/hover", func_position) 向 lsp server 发送请求.
---   3. 修改 lsp server 返回的内容用于 floating window 显示: 只保留 lsp server 返回内容的第一行.
---   4. 修改 floating window 的位置.

local ms = vim.lsp.protocol.Methods
local hover_ns = vim.api.nvim_create_namespace('nvim.lsp.hover_range')

local M = {}

--- NOTE: 这里 node_row 和 node_char 都是从 0 开始计算.
--- node_char 是指行内第几个字符, \t 算一个字符.
local function calculate_offset(lsp_req_pos_line, lsp_req_pos_char)
  local cursor_line, cursor_col = unpack(vim.api.nvim_win_get_cursor(0))  -- (1,0)-indexed

  --- VVI: offset 中 \t 占4个字符位置, 而在 getpos() 和 node:start() 中只占1个字符.
  --- strdisplaywidth() 会计算实际显示宽度, \t 会被计算在显示宽度之内.
  --- node 行 virtual column 位置.
  local node_display_width = vim.fn.strdisplaywidth(
    string.sub(vim.fn.getline(lsp_req_pos_line+1), 0, lsp_req_pos_char)
  )
  --- cursor 行 virtual column 位置.
  local cursor_display_width = vim.fn.strdisplaywidth(
    string.sub(vim.fn.getline(cursor_line), 0, cursor_col)
  )

  --- 计算 open_floating_preview() 横向/纵向偏移量
  local offset_x = node_display_width - cursor_display_width
  local offset_y = lsp_req_pos_line - cursor_line +1

  return {
    lsp_req_pos_line = lsp_req_pos_line,
    lsp_req_pos_char = lsp_req_pos_char,
    offset_x = offset_x,
    offset_y = offset_y,
  }
end

--- 计算 argument list 前面一个 node 的 start 位置.
local function node_before_arguments(row, col)
  local node_before_args = vim.treesitter.get_node({pos={row, col}})
  if not node_before_args then
    error('debug: no node before arguments|argument_list node')
  end

  row, col, _ = node_before_args:start()
  return calculate_offset(row, col)
end

--- NOTE: 使用 nvim-treesitter 寻找 cursor 前最近的 function call() 的位置 ----- {{{
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
local function find_fn_call_before_cursor()
  --- 获取 node at cursor.
  local cur_line, cur_col = unpack(vim.api.nvim_win_get_cursor(0))
  local node = vim.treesitter.get_node({pos={cur_line-1, cur_col}})

  --- 向上(parent)寻找 'argument_list' / 'arguments' node.
  --- eg: fn("bar") 中 `("bar")` 属于 arguments, 包括括号.
  --- NOTE: 'go, py' use 'argument_list'; 'js, ts, lua' use 'arguments'.
  local args_type_name = {'argument_list', 'arguments'}

  while node do
    if vim.tbl_contains(args_type_name, node:type()) then
      --- 判断 arguments/argument_list 前一个 node 是否 type_arguments(generic type param)
      local prev_node = node:prev_named_sibling()
      if not prev_node then
        error('debug: arguments|argument_list missing previous named sibling node.')
      end

      if prev_node:type() == 'type_arguments' then
        --- 如果是 type_arguments 则返回 type_arguments node 前一个字符位置.
        local row, col, _ = prev_node:start()
        return node_before_arguments(row, col-1)
      end

      --- 如果前面不是 type_arguments 则返回本身 node 的前一个字符位置.
      --- argument_list start position 即 '(' 的位置. row, col 都是从 0 开始计算位置.
      local row, col, _ = node:start()
      return node_before_arguments(row, col-1)
    end

    node = node:parent()  -- 循环向上查找, 如果到了 root node 也没找到的话, node:parent() 返回 nil.
  end
end

--- VVI: 以下代码大多从源代码中复制 ----------------------------------------------------------------
--- https://github.com/neovim/neovim/blob/master/runtime/lua/vim/lsp/buf.lua
local function client_positional_params(fn_node)
  local win = vim.api.nvim_get_current_win()
  return function(client)
    --- 1. 修改 position 为 cursor position 前面的 func_position.
    local ret = vim.lsp.util.make_position_params(win, client.offset_encoding)
    ret = vim.tbl_deep_extend('force', ret, {
      position = {
        line = fn_node.lsp_req_pos_line,       -- line 从 0 开始计算.
        character = fn_node.lsp_req_pos_char,  -- char 从 0 开始计算.
      }
    })
    return ret
  end
end

--- cache hover winid
local hover_winid

--- toggle hover window
function M.toggle_hover_short()
  if hover_winid and vim.api.nvim_win_is_valid(hover_winid) then
    vim.api.nvim_win_close(hover_winid, true)
    hover_winid = nil
  else
    M.hover_short()
  end
end

--- 只获取 textDocument/hover 中 signature 部分
function M.hover_short()
  local fn_node = find_fn_call_before_cursor()
  if not fn_node then  -- 如果 cursor 不在 'arguments' 内, 则结束.
    return
  end

  --- 4. 修改 hover_short floating window 显示的位置.
  --- `:help vim.lsp.util.open_floating_preview.Opts`
  local config = {
    offset_x = fn_node.offset_x,
    offset_y = fn_node.offset_y,
    focusable = false,
    border = Nerd_icons.border,
    anchor_bias = 'above',
    max_width = math.floor(vim.go.columns * 0.8),
    close_events = {"WinScrolled"},
    silent = true,  -- 有些 linter 类型的 lsp 不返回任何 result, 导致 handler 报错.

    focus_id = ms.textDocument_hover  -- 'textDocument' request
  }

  --- 2. 发送请求到 lsp server
  --- results: { client_id1 = {}, client_id2 = {} ... }
  vim.lsp.buf_request_all(0, ms.textDocument_hover, client_positional_params(fn_node), function(results, ctx)
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

    if vim.tbl_isempty(results1) then
      if config.silent ~= true then
        vim.notify('No information available')
      end
      return
    end

    local contents = {} --- @type string[]

    local nresults = #vim.tbl_keys(results1)

    local format = 'markdown'

    --- results1: { client_id1 = {}, client_id2 = {} ... }
    for client_id, result in pairs(results1) do
      local client = assert(vim.lsp.get_client_by_id(client_id))
      if nresults > 1 then
        -- Show client name if there are multiple clients
        contents[#contents + 1] = string.format('# %s', client.name)
      end
      if type(result.contents) == 'table' and result.contents.kind == 'plaintext' then
        if #results1 == 1 then
          format = 'plaintext'
          contents = vim.split(result.contents.value or '', '\n', { trimempty = true })
        else
          -- Surround plaintext with ``` to get correct formatting
          contents[#contents + 1] = '```'
          vim.list_extend(
            contents,
            vim.split(result.contents.value or '', '\n', { trimempty = true })
          )
          contents[#contents + 1] = '```'
        end
      else
        --- 3. 修改 lsp server 返回的内容用于 floating window 显示: 只保留 lsp server 返回内容的第一行.
        --- 寻找 "```" end line, 忽略后面的所有内容.
        local tmp = {}
        for _, line in ipairs(vim.lsp.util.convert_input_to_markdown_lines(result.contents)) do
          table.insert(tmp, line)
          if line == '```' then
            break
          end
        end
        vim.list_extend(contents, tmp)
      end
      local range = result.range
      if range then
        local start = range.start
        local end_ = range['end']
        local start_idx = vim.lsp.util._get_line_byte_from_position(bufnr, start, client.offset_encoding)
        local end_idx = vim.lsp.util._get_line_byte_from_position(bufnr, end_, client.offset_encoding)

        vim.hl.range(
          bufnr,
          hover_ns,
          'LspReferenceTarget',
          { start.line, start_idx },
          { end_.line, end_idx },
          { priority = vim.hl.priorities.user }
        )
      end
      contents[#contents + 1] = '---'
    end

    -- Remove last linebreak ('---')
    contents[#contents] = nil

    if vim.tbl_isempty(contents) then
      if config.silent ~= true then
        vim.notify('No information available')
      end
      return
    end

    _, hover_winid = vim.lsp.util.open_floating_preview(contents, format, config)

    vim.api.nvim_create_autocmd('WinClosed', {
      pattern = tostring(hover_winid),
      once = true,
      callback = function()
        vim.api.nvim_buf_clear_namespace(bufnr, hover_ns, 0, -1)
        return true
      end,
    })
  end)
end

return M
