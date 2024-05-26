--- 获取 cursor treesitter node --------------------------------------------------------------------
--- treesitter api 使用方法 ------------------------------------------------------------------------ {{{
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
  --- 获取 node at cursor.
  local pos = vim.api.nvim_win_get_cursor(0)
  local node = vim.treesitter.get_node({pos={pos[1]-1, pos[2]}})
  if not node then
    return
  end

  print("cursor node:", node:type(), node:start())
  local parent = node:parent()
  if parent then
    print("parent node:", parent:type(), parent:start())
  end

  local prev = node:prev_named_sibling()
  if prev then
    print("prev node:", prev:type(), prev:start())
  end

  local next = node:next_named_sibling()
  if next then
    print("next node:", next:type(), next:start())
  end
end



