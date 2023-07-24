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
    Notify("nvim-treesitter is not loaded.", "WARN")
    return
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



