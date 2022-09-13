--- NOTE: 这里 node_row 和 node_char 都是从 0 开始计算.
--- node_char 是指行内第几个字符, \t 算一个字符.
local function calculate_offset(lsp_req_pos_line, lsp_req_pos_char)
  local cursor_pos = vim.fn.getpos('.')  -- 光标位置, 返回 [bufnum, lnum, col, off]. lnum 和 col 都是从 1 开始计算.

  --- VVI: offset 中 \t 占4个字符位置, 而在 getpos() 和 node:start() 中只占1个字符.
  --- strdisplaywidth() 会计算实际显示宽度, \t 会被计算在显示宽度之内.
  --- node 行 virtual column 位置.
  local node_display_width = vim.fn.strdisplaywidth(string.sub(vim.fn.getline(lsp_req_pos_line+1), 0, lsp_req_pos_char))
  --- cursor 行 virtual column 位置.
  local cursor_display_width = vim.fn.strdisplaywidth(string.sub(vim.fn.getline(cursor_pos[2]), 0, cursor_pos[3]-1))

  --- 计算 open_floating_preview() 横向/纵向偏移量
  local offset_x = node_display_width - cursor_display_width
  local offset_y = lsp_req_pos_line - cursor_pos[2] +1

  --- VVI:
  --- offsetX - float_window 距离 cursor 的位置偏移.
  --- offsetY - 同上, 由于 getpos() 返回的 lnum 是从 1 开始, 而 node:start() 返回的 row 是从 0 开始,
  ---           所以 offsetY 的结果需要 +1.
  return {
    lsp_req_pos_line = lsp_req_pos_line,
    lsp_req_pos_char = lsp_req_pos_char,
    offset_x = offset_x,
    offset_y = offset_y,
  }
end

--- NOTE: 使用 nvim-treesitter 寻找 cursor 前最近的 function call() 的位置 --- {{{
-- `:help nvim-treesitter`
--    node = ts_utils.get_node_at_cursor()  -- 获取 node at cursor.
--
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
  local ts_status, ts_utils = pcall(require, "nvim-treesitter.ts_utils")
  if not ts_status then
    Notify("treesitter is not loaded.", "WARN")
    return
  end

  -- local pos = vim.fn.getpos('.')  -- 光标位置, 返回 [bufnum, lnum, col, off]. lnum 和 col 都是从 1 开始计算.
  local node = ts_utils.get_node_at_cursor()  -- 获取 node at cursor.

  --- 向上(parent)寻找 'argument_list' / 'arguments' node.
  --- eg: fn("bar") 中 `("bar")` 属于 arguments, 包括括号.
  --- NOTE: 'go, py' use 'argument_list'; 'js, ts, lua' use 'arguments'.
  local args_type_name = {'argument_list', 'arguments'}

  while node do
    if vim.tbl_contains(args_type_name, node:type()) then
      --- 判断 arguments/argument_list 前一个 node 是否 type_arguments(generic type param)
      local prev_node = node:prev_named_sibling()
      if prev_node:type() == 'type_arguments' then
        --- 如果是 type_arguments 则返回 type_arguments node 前一个字符位置.
        local p_row, p_col, _ = prev_node:start()
        return calculate_offset(p_row, p_col-1)
      end

      --- 如果前面不是 type_arguments 则返回本身 node 的前一个字符位置.
      local row, col, _ = node:start()  -- argument_list start position, 即 '(' 的位置. row, col 都是从 0 开始计算位置.
      return calculate_offset(row, col-1)
    end

    node = node:parent()  -- 循环向上查找, 如果到了 root node 也没找到的话, node:parent() 返回 nil.
  end
end

--- VVI: 自定义 lsp request ------------------------------------------------------------------------
--- 主要函数: vim.lsp.buf_request(0, method, params, handlerFn), 向 LSP server 发送请求, 通过自定义 handler 处理结果.

local M = {}

--- lsp request handler ----------------------------------------------------------------------------
--- NOTE: 该自定义 handler 主要作用是根据 'textDocument/hover' handler 修改 open_floating_preview()
--        中的显示内容. 不显示 comments, 只显示 function 定义. 类似 textDocument/signatureHelp.
--- copy from `function M.hover(_, result, ctx, config)`
--- https://github.com/neovim/neovim/blob/master/runtime/lua/vim/lsp/handlers.lua
--- `:help lsp-handler`, lsp-request handler 的第一个参数为 err, 这里省略不处理.
local function hover_short_handler(err, result, req, config)
  if err then
    require("user.lsp.custom_lsp_request.error_logger").log(err)
    Notify("hover_short_handler error", "ERROR")
    return
  end

  config = config or {}
  config.focus_id = req.method

  -- NOTE: open_floating_preview() 自定义设置
  config.focusable = false
  config.border = {"▄","▄","▄","█","▀","▀","▀","█"}
  config.close_events = {"WinScrolled"}  -- 默认 {"CursorMoved", "CursorMovedI", "InsertCharPre"}

  if not (result and result.contents) then
    vim.notify('No information available')
    return
  end

  local mls = vim.lsp.util.convert_input_to_markdown_lines(result.contents)  -- split string to text list
  mls = vim.lsp.util.trim_empty_lines(mls)  -- Removes empty lines from the beginning and end

  -- NOTE: 寻找 "```" end line, 忽略后面的所有内容.
  local markdown_lines = {}
  for _, line in ipairs(mls) do
    table.insert(markdown_lines, line)
    if line == '```' then
      break
    end
  end

  --print(vim.inspect(markdown_lines))  -- DEBUG

  if vim.tbl_isempty(markdown_lines) then
    vim.notify('No information available')
    return
  end

  return vim.lsp.util.open_floating_preview(markdown_lines, "markdown", config)
end

--- vim.lsp.buf_request() ----------------------------------
--- https://github.com/neovim/neovim/blob/master/runtime/lua/vim/lsp/buf.lua
--- vim.lsp.buf_request(0, method, params, handlerFn)  -- 向 LSP server 发送请求, 通过 handler 处理结果.
M.hover_short = function()
  local result = find_fn_call_before_cursor()
  if not result then  -- 如果 cursor 不在 'arguments' 内, 则结束.
    return
  end

  --- VVI: overwrite make_position_params() 生成的请求位置.
  local param = vim.tbl_deep_extend('force',
    vim.lsp.util.make_position_params(),
    {
      position = {
        line = result.lsp_req_pos_line,       -- line 从 0 开始计算.
        character = result.lsp_req_pos_char,  -- char 从 0 开始计算.
      }
    }
  )

  vim.lsp.buf_request(0, 'textDocument/hover', param,
    --- VVI: 添加 offsetX 设置到 handler, 用来偏移 open_floating_preview() window
    vim.lsp.with(hover_short_handler,  -- VVI: 调用自定义 handler
      {
        offset_x = result.offset_x,
        offset_y = result.offset_y,
      }
    )
  )
end

return M
