--- NOTE: 使用 nvim-treesitter 寻找 cursor 前最近的 function call() 的位置 --- {{{
-- `:help nvim-treesitter`
--    node = ts_utils.get_node_at_cursor()  -- 获取 node at cursor.
--
-- `:help treesitter`
--    node:start()  -- start pos, return [row, (col), totalbytes]
--    node:end_()   -- end pos
--    node:parent() -- 父级 node
--    node:type()   -- treesitter 分析
--        selector_expression  -- '.'
--        argument_list  -- func call '(xxx)' 中的所有内容, 包括括号 ().
--        func call 名字 -- call_expression.function.field
-- }}}
local function find_fn_call_before_cursor()
  local ts_status, ts_utils = pcall(require, "nvim-treesitter.ts_utils")
  if not ts_status then
    Notify("treesitter is not loaded.", "WARN")
    return nil
  end

  local pos = vim.fn.getpos('.')  -- 光标位置, 返回 [bufnum, lnum, col, off]. lnum 和 col 都是从 1 开始计算.
  local node = ts_utils.get_node_at_cursor()  -- 获取 node at cursor.

  --- 向上寻找 'argument_list' / 'arguments' node. 'go, py' use argument_list; 'js, ts, lua' use arguments.
  --- NOTE: foo("bar") 中 `("bar")` 属于 arguments, 包括括号.
  while node do
    if node:type() == 'argument_list' or node:type() == 'arguments' then
      local row, col, _ = node:start()  -- argument_list start position, 即 '(' 的位置. row, col 都是从 0 开始计算位置.
      local func_call_last_char = col-1 -- VVI: col 是 '(' 的位置, func call() 是 '(' 前面的一个位置.

      --- VVI: offset 中 \t 占4个字符位置, 而在 getpos() 和 node:start() 中只占1个字符.
      --- strdisplaywidth() 会计算实际显示宽度, \t 会被计算在显示宽度之内.
      --- argument_list 行 virtual column 位置.
      local argDisplayCol = vim.fn.strdisplaywidth(string.sub(vim.fn.getline(row+1), 0, func_call_last_char))
      --- cursor 行 virtual column 位置.
      local curDisplayCol = vim.fn.strdisplaywidth(string.sub(vim.fn.getline(pos[2]), 0, pos[3]-1))
      --- 计算 open_floating_preview() 横向偏移量
      local offsetX = argDisplayCol - curDisplayCol

      --- VVI:
      --- char    - '(' arguments start() 的前一个位置.
      --- offsetX - float_window 距离 cursor 的位置偏移.
      --- offsetY - 同上, 由于 getpos() 返回的 lnum 是从 1 开始, 而 node:start() 返回的 row 是从 0 开始,
      ---           所以 offsetY 的结果需要 +1.
      return {line=row, char=func_call_last_char, offsetX=offsetX, offsetY=row-pos[2]+1}
    end

    node = node:parent()  -- 循环向上查找, 如果到了 root node 也没找到的话, node:parent() 返回 nil.
  end

  return nil
end

--- VVI: 自定义 lsp request ------------------------------------------------------------------------
--- 主要函数: vim.lsp.buf_request(0, method, params, handlerFn), 向 LSP server 发送请求, 通过自定义 handler 处理结果.

local M = {}

--- lsp request handler ------------------------------------
--- 该自定义 handler 主要作用是根据 'textDocument/hover' handler 修改 open_floating_preview() 中的显示内容.
---    不显示 comments, 只显示 function 定义.
--- copy from `function M.hover(_, result, ctx, config)`
--- https://github.com/neovim/neovim/ -> runtime/lua/vim/lsp/handlers.lua
--- `:help lsp-handler`, lsp-request handler 的第一个参数为 err, 这里省略不处理.
local function hover_short_handler(_, result, ctx, config)
  config = config or {}
  config.focus_id = ctx.method

  -- NOTE: open_floating_preview() 自定义设置
  config.focusable = false
  config.border = {"▄","▄","▄","█","▀","▀","▀","█"}
  config.close_events = {"CompleteDone", "WinScrolled"}

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
--- https://github.com/neovim/neovim/ -> runtime/lua/vim/lsp/buf.lua
--- vim.lsp.buf_request(0, method, params, handlerFn)  -- 向 LSP server 发送请求, 通过 handler 处理结果.
M.hover_short = function()
  local result = find_fn_call_before_cursor()
  if not result then  -- 如果 cursor 不在 'arguments' 内, 则结束.
    return
  end

  local method = 'textDocument/hover'  -- 调用 lsp hover() 请求

  --- VVI: overwrite make_position_params() 生成的请求位置.
  local param = vim.tbl_deep_extend('force',
    vim.lsp.util.make_position_params(),
    {
      position = {
        character = result.char,  -- char 从 0 开始计算.
        line = result.line,       -- line 从 0 开始计算.
      }
    }
  )

  vim.lsp.buf_request(0, method, param,
    --- VVI: 添加 offsetX 设置到 handler, 用来偏移 open_floating_preview() window
    vim.lsp.with(hover_short_handler,  -- VVI: 调用自定义 handler
      {
        offset_x = result.offsetX,
        offset_y = result.offsetY,
      }
    )
  )
end

return M



