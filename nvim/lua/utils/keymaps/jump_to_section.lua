--- [[, ]], jump to previous/next section

local M = {}

--- @return TSNode|nil
local function find_ts_root_node()
  --- vim.treesitter.get_parser(bufnr, lang)
  --- "bufnr", 0 current buffer
  --- "lang", default filetype.
  --- TODO: nvim-0.12 get_parser() 返回 nil 而不是 error
  local tsparser = vim.treesitter.get_parser()
  if not tsparser then
    error("treesitter parser is missing")
  end

  --- tsparser:parse() return a {table} of immutable trees
  local tstree = tsparser:parse()[1]
  if tstree then
    return tstree:root()
  end
end

--- 只返回 root's Children Nodes
--- @return TSNode[]|nil
local function ts_root_children()
  local root = find_ts_root_node()
  if not root then
    return
  end

  --- @type TSNode[]
  local child_without_comment = {}  -- cache named child without comment.

  local child_count = root:named_child_count()
  --- 0-index named_child()
  for i = 0, child_count-1, 1 do
    local child = root:named_child(i)
    if child and child:type() ~= "comment" then
      table.insert(child_without_comment, child)
    end
  end

  if #child_without_comment>0 then
    return child_without_comment
  end
end

--- 当前 cursor 所在 root's Child Node
--- @param root_children TSNode[]
--- @return { index: integer, cursor_lnum: integer, node_start_lnum: integer }
local function current_node(root_children)
  local cursor_lnum = vim.api.nvim_win_get_cursor(0)[1]  -- {lnum, col}, (1,0)-indexed

  for i = #root_children, 1, -1 do
    local node_lnum = root_children[i]:start() + 1  -- {lnum, col, bytes}, all 0-indexed

    if cursor_lnum >= node_lnum then
      return {
        index = i,
        cursor_lnum = cursor_lnum,
        node_start_lnum = node_lnum,
      }
    end
  end

  -- cursor above first node
  return {
    index = 0,
    cursor_lnum = cursor_lnum,
    node_start_lnum = 1,
  }
end

--- jump_to_prev_section
M.goto_prev = function()
  local root_children = ts_root_children()
  if not root_children then
    return
  end

  local c_node = current_node(root_children)

  if c_node.index < 1 or (c_node.index == 1 and c_node.cursor_lnum == c_node.node_start_lnum) then
    vim.api.nvim_win_set_cursor(0, {1, 0})
  elseif c_node.cursor_lnum ~= c_node.node_start_lnum then
    vim.api.nvim_win_set_cursor(0, {c_node.node_start_lnum, 0})
  else
    local prev_node = root_children[c_node.index-1]
    local prev_node_lnum = prev_node:start() + 1
    vim.api.nvim_win_set_cursor(0, {prev_node_lnum, 0})
  end
end

--- jump_to_next_section
M.goto_next = function()
  local root_children = ts_root_children()
  if not root_children then
    return
  end

  local c_node = current_node(root_children)

  local next_node = root_children[c_node.index+1]
  if next_node then
    local next_node_lnum = next_node:start() +1
    vim.api.nvim_win_set_cursor(0, {next_node_lnum, 0})
  else
    local last_lnum = vim.api.nvim_buf_line_count(0)
    vim.api.nvim_win_set_cursor(0, {last_lnum, 0})
  end
end

return M
