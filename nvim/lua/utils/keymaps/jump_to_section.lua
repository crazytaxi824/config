--- [[, ]], jump to previous/next section

local M = {}

--- NOTE: `:help treesitter-languagetree`, `lang` will default to 'filetype'.
--- 利用 nvim-treesitter 获取 buffer `lang`.
local function parse_buffer_lang()
  local nvim_ts_ok, nvim_ts_parsers = pcall(require, "nvim-treesitter.parsers")
  if nvim_ts_ok then
    return nvim_ts_parsers.get_buf_lang(0)  -- 如果 nvim-treesitter 存在, 则 parse
  else
    return vim.bo.filetype  -- 如果 nvim-treesitter 不存在, 则使用 filetype
  end
end

local function find_ts_root_node()
  local lang = parse_buffer_lang()
  if not lang or lang == '' then
    vim.notify('treesitter-parser for current buffer is not available', vim.log.levels.WARN)
    return
  end

  --- vim.treesitter.get_parser(bufnr, lang)
  --- "bufnr", 0 current buffer
  --- "lang", default filetype.
  local tsparser_status_ok, tsparser = pcall(vim.treesitter.get_parser, 0, lang)
  if not tsparser_status_ok then
    vim.notify(vim.inspect(tsparser), vim.log.levels.WARN)
    return
  end

  --- tsparser:parse() return a {table} of immutable trees
  local tstree = tsparser:parse()[1]
  if tstree then
    return tstree:root()
  end
end

local function ts_root_children()
  local root = find_ts_root_node()
  if not root then
    return
  end

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

local function current_node()
  local root_children = ts_root_children()
  if not root_children then
    return
  end

  local cursor_lnum = vim.fn.getpos('.')[2]  -- {bufnr, line, col, bytes}, table_list/array, 从 1 开始计算.

  for index in ipairs(root_children) do
    local node_line = root_children[index]:start()  -- {line, col, bytes}, 从 0 开始计算.
    if cursor_lnum <= node_line then
      return {
        index = index-1,
        root_nodes = root_children,
        cursor_lnum = cursor_lnum,
      }
    end
  end

  -- cursor at last node
  return {
    index = #root_children,
    root_nodes = root_children,
    cursor_lnum = cursor_lnum,
  }
end

--- jump_to_prev_section
M.prev = function()
  local c_node = current_node()
  if not c_node then
    return
  end

  --- NOTE: cursor line < first non comment node 的情况下 result.current = nil.
  local current_node_first_lnum = c_node.root_nodes[c_node.index]:start() +1

  --- cursor 在 current_node 第一行.
  if c_node.cursor_lnum == current_node_first_lnum then
    local prev_node = c_node.root_nodes[c_node.index-1]
    if prev_node then
      local prev_node_lnum = prev_node:start() +1
      vim.fn.cursor(prev_node_lnum, 1)
    else
      --- 自己是 first node's first line 的情况
      vim.notify("it's first node in this buffer", vim.log.levels.INFO)
    end
  else
    --- jump to cursor current node first line.
    vim.fn.cursor(current_node_first_lnum, 1)
  end
end

--- jump_to_next_section
M.next = function()
  local c_node = current_node()
  if not c_node then
    return
  end

  local next_node = c_node.root_nodes[c_node.index+1]

  if next_node then
    local next_node_lnum = next_node:start() +1
    vim.fn.cursor(next_node_lnum, 1)
  else
    local current_node_last_line = c_node.root_nodes[c_node.index]:end_() +1
    if c_node.cursor_lnum < current_node_last_line then
      --- jump to last node's last line
      vim.fn.cursor(current_node_last_line, 1)
    else
      --- NOTE: cursor_line >= last node's last line 的情况.
      vim.notify("it's last node in this buffer", vim.log.levels.INFO)
    end
  end
end

return M
