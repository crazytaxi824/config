--- 获取所有 window 的 filetype 和 syntax 等信息 --------------------------------------------------- {{{
--    `:help winnr()`   " winnr()    - 当前 window_index
--                      " winnr('#') - prev_window_index
--                      " winnr('$') - total_window_number
--
--    `:help winheight()`   " winheight(win_index)   - 获取 window height
--                          " winheight(winnr())     - 当前 window height
--                          " winheight('%')         - 当前 window height, 和上面一样
--
--    `:help winwidth()`   " 获取 window 宽度, 使用方法和 winheight() 一样. winwidth(win_index)
--
--    `:help win_getid(win_index)`   " 通过 window_index 获取 window_id
--    `:help getwinvar(win_index)`   " 获取 window 变量
--    `:help getwininfo(win_id)`     " VVI: 获取 window 所有信息
--    `:help getwininfo()`           " VVI: 获取所有 window 的所有信息
--    `:help win_gettype(win_id)`    " 获取 window 类型
-- -- }}}
function Get_win_info()
  local infos = {}

  for win_index = 1, vim.fn.winnr('$'), 1 do
    local win_id = vim.fn.win_getid(win_index)

    local info = {
      win_index = win_index,
      win_id = win_id,
      win_height = vim.fn.winheight(win_index),
      win_width = vim.fn.winwidth(win_index),
      filetype = vim.fn.getwinvar(win_index, '&filetype'),  -- print(vim.bo.filetype) 打印当前 win filetype.
      syntax = vim.fn.getwinvar(win_index, '&syntax'),
      buftype = vim.fn.getwinvar(win_index, '&buftype'),
      win_type = vim.fn.win_gettype(win_id),
    }
    table.insert(infos, info)
  end

  print(vim.inspect(infos))
end

--- 获取 cursor treesitter node --------------------------------------------------------------------
--- treesitter api 使用方法 --- {{{
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
-- -- }}}
function Get_TSNode_at_cursor()
  local ts_status, ts_utils = pcall(require, "nvim-treesitter.ts_utils")
  if not ts_status then
    Notify("treesitter is not loaded.", "WARN", {title={"TS_Get_Cursor_Node()","util.lua"}})
    return nil
  end

  local node = ts_utils.get_node_at_cursor()
  print("cursor node:", node:type(), node:start())
  local parent = node:parent()
  if parent then
    print("parent node:", parent:type(), parent:start())
  end
  local prev = ts_utils.get_previous_node(node)
  if prev then
    print("prev node:", prev:type(), prev:start())
  end
  local next = ts_utils.get_next_node(node)
  if next then
    print("next node:", next:type(), next:start())
  end
end



