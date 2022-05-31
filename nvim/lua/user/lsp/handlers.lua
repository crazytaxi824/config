--- Overwrite handler 设置 -------------------------------------------------------------------------
--- NOTE: 使用 with() 方法. `:help lsp-handler-configuration`
---      `:help lsp-api` lsp-method 显示 textDocument/... 列表

--- handler config examples ------------------------------------------------------------------------ {{{
--- signatureHelp 是用来显示函数入参出参的.
-- vim.lsp.handlers["textDocument/signatureHelp"] = vim.lsp.with(
--   vim.lsp.handlers["textDocument/signatureHelp"],
--   { focusable = false, border = {"▄","▄","▄","█","▀","▀","▀","█"},  }
-- )

--- NOTE: 这里是修改输出到 location-list. 默认是 quickfix
-- vim.lsp.handlers["textDocument/references"] = vim.lsp.with(
--   vim.lsp.handlers["textDocument/references"], {
--     -- Use location list instead of quickfix list
--     loclist = true,  -- qflist | loclist
--   }
-- )

-- vim.lsp.handlers["textDocument/publishDiagnostics"] = vim.lsp.with(
--   vim.lsp.handlers["textDocument/publishDiagnostics"], {
--     -- Enable underline, use default values
--     underline = true,
--
--     -- Enable virtual text, override spacing to 4
--     virtual_text = {
--       spacing = 4,
--       source = true,
--     },
--
--     -- Use a function to dynamically turn signs off
--     -- and on, using buffer local variables
--     signs = function(namespace, bufnr)
--       return vim.b[bufnr].show_signs == true
--     end,
--
--     -- Disable a feature
--     update_in_insert = false,
--   }
-- )
-- -- }}}

--- 这里是修改 'textDocument/hover' handler 的 border 样式.
vim.lsp.handlers["textDocument/hover"] = vim.lsp.with(
  vim.lsp.handlers["textDocument/hover"],
  {
    focusable = false,  -- false: 重复执行 vim.lsp.buf.hover() 时不会进入 floating window.
    border = {"▄","▄","▄","█","▀","▀","▀","█"},

    --- events, to trigger close floating window
    --- VVI: `set omnifunc?` 没有设置, 所以 <C-x><C-o> 不会触发 Completion.
    --- 使用 `:doautocmd CompleteDone` 手动触发 event.
    close_events = {"CompleteDone", "WinScrolled"},
    --- 以下是 close_events 默认设置. https://github.com/neovim/neovim/ -> runtime/lua/vim/lsp/util.lua
    --close_events = {"CursorMoved", "CursorMovedI", "InsertCharPre"},
  }
)

-- VVI: 自定义 handler -----------------------------------------------------------------------------
-- 该自定义 handler 主要作用是根据 'textDocument/hover' handler 修改 open_floating_preview() 中的显示内容.
--    不显示 comments, 只显示 function 定义.
-- 主要函数: vim.lsp.buf_request(0, method, params, handlerFn), 向 LSP server 发送请求, 通过自定义 handler 处理结果.

-- copy from `function M.hover(_, result, ctx, config)`
-- https://github.com/neovim/neovim/ -> runtime/lua/vim/lsp/handlers.lua
local function hoverShortHandler(_, result, ctx, config)
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

  -- print(vim.inspect(markdown_lines))  -- DEBUG

  if vim.tbl_isempty(markdown_lines) then
    vim.notify('No information available')
    return
  end

  return vim.lsp.util.open_floating_preview(markdown_lines, "markdown", config)
end

--- NOTE: 使用 nvim-treesitter 寻找 cursor 前最近的 function call() 的位置 --- {{{
-- `:help nvim-treesitter`
-- `:help treesitter`
--    node = ts_utils.get_node_at_cursor()  -- 获取 node at cursor.
--    node:start()  -- start pos, return [row, (col), totalbytes]
--    node:end_()   -- end pos
--    node:parent() -- 父级 node
--    node:type()   -- treesitter 分析
--        selector_expression  -- '.'
--        argument_list  -- func call '(xxx)' 中的所有内容, 包括括号 ().
--        func call 名字 -- call_expression.function.field
-- }}}
local function findFuncCallBeforeCursor()
  local ts_status, ts_utils = pcall(require, "nvim-treesitter.ts_utils")
  if not ts_status then
    vim.api.nvim_echo({{' tree-sitter is not loaded. ', "WarningMsg"}}, false, {})
    return nil
  end

  local pos = vim.fn.getpos('.')  -- 光标位置, 返回 [bufnum, lnum, col, off]. lnum 和 col 都是从 1 开始计算.
  local node = ts_utils.get_node_at_cursor()  -- 获取 node at cursor.

  -- 向上寻找 'argument_list' node.
  while node do
    -- NOTE: 'go, py' use argument_list; 'js, ts, lua' use arguments.
    if node:type() == 'argument_list' or node:type() == 'arguments' then
      local row, col, _ = node:start()  -- argument_list start position, 即 '(' 的位置. row, col 都是从 0 开始计算位置.
      local func_call_last_char = col-1 -- col 是 '(' 的位置, func call() 是 '(' 前面的一个位置.

      -- VVI: offset 中 \t 占4个字符位置, 而在 getpos() 和 node:start() 中只占1个字符.
      -- strdisplaywidth() 会计算实际显示宽度, \t 会被计算在显示宽度之内.
      -- argument_list 行 virtual column 位置.
      local argDisplayCol = vim.fn.strdisplaywidth(string.sub(vim.fn.getline(row+1), 0, func_call_last_char))
      -- cursor 行 virtual column 位置.
      local curDisplayCol = vim.fn.strdisplaywidth(string.sub(vim.fn.getline(pos[2]), 0, pos[3]-1))
      -- 计算 open_floating_preview() 横向偏移量
      local offsetX = argDisplayCol - curDisplayCol

      -- char - '(' 前的一个位置.
      -- offsetX - float_window 距离 cursor 的位置偏移.
      -- offsetY - 同上, 由于 getpos() 返回的 lnum 是从 1 开始, 而 node:start() 返回的 row 是从 0 开始,
      --           所以 offsetY 的结果需要 +1.
      return {line=row, char=func_call_last_char, offsetX=offsetX, offsetY=row-pos[2]+1}
    end

    node = node:parent()  -- 循环向上查找, 如果到了 root node 也没找到的话, node:parent() 返回 nil.
  end

  return nil
end

-- https://github.com/neovim/neovim/ -> runtime/lua/vim/lsp/buf.lua
-- vim.lsp.buf_request(0, method, params, handlerFn)  -- 向 LSP server 发送请求, 通过 handler 处理结果.
function HoverShort()
  local result = findFuncCallBeforeCursor()

  -- 如果 cursor 不在 'arguments' 内则返回.
  if not result then
    return
  end

  local method = 'textDocument/hover'

  -- overwrite make_position_params() 生成的请求位置.
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
    -- VVI: 添加 offsetX 设置到 handler, 用来偏移 open_floating_preview() window
    vim.lsp.with(hoverShortHandler,
      {
        offset_x = result.offsetX,
        offset_y = result.offsetY,
      }
    )
  )
end

-- HACK: Always Put popup window on Top of the cursor.
-- 影响所有使用 vim.lsp.util.open_floating_preview() 的 popup window.
-- https://github.com/neovim/neovim/ -> runtime/lua/vim/lsp/util.lua
-- modify native function (global) - `vim.lsp.util.make_floating_popup_options` -------------------- {{{
vim.lsp.util.make_floating_popup_options = function (width, height, opts)
    vim.validate {
    opts = { opts, 't', true };
  }
  opts = opts or {}
  vim.validate {
    ["opts.offset_x"] = { opts.offset_x, 'n', true };
    ["opts.offset_y"] = { opts.offset_y, 'n', true };
  }

  local anchor = ''
  local row, col

  local lines_above = vim.fn.winline() - 1
  local lines_below = vim.fn.winheight(0) - lines_above

  -- if lines_above < lines_below then
  --   anchor = anchor..'N'
  --   height = math.min(lines_below, height)
  --   row = 1
  -- else
  --   anchor = anchor..'S'
  --   height = math.min(lines_above, height)
  --   row = 0
  -- end

  if vim.fn.winline() < height+2 then  -- +2 border width
    anchor = anchor..'N'
    height = math.min(lines_below, height)
    row = 1
  else
    anchor = anchor..'S'
    height = math.min(lines_above, height)
    row = 0
  end

  if vim.fn.wincol() + width + (opts.offset_x or 0) <= vim.api.nvim_get_option('columns') then
    anchor = anchor..'W'
    col = 0
  else
    anchor = anchor..'E'
    col = 1
  end

  local default_border = {
    {"", "NormalFloat"},
    {"", "NormalFloat"},
    {"", "NormalFloat"},
    {" ", "NormalFloat"},
    {"", "NormalFloat"},
    {"", "NormalFloat"},
    {"", "NormalFloat"},
    {" ", "NormalFloat"},
  }

  return {
    anchor = anchor,
    col = col + (opts.offset_x or 0),
    height = height,
    focusable = opts.focusable,
    relative = 'cursor',
    row = row + (opts.offset_y or 0),
    style = 'minimal',
    width = width,
    border = opts.border or default_border,
    zindex = opts.zindex or 50,
  }
end

-- -- }}}




