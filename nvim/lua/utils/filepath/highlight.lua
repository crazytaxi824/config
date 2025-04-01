--- highlight filepath

local parse = require('utils.filepath.parse')

local M = {}

local cache_hl_bufnr

--- namespace
local ns = vim.api.nvim_create_namespace('my_filepath_extmarks')

--- highlight
vim.api.nvim_set_hl(0, "my_filepath_underline", {underline=true, sp=Colors.cyan.g})

--- delete previous cached highlight
M.highlight_clear_cache = function()
  if cache_hl_bufnr and vim.api.nvim_buf_is_valid(cache_hl_bufnr) then
    vim.api.nvim_buf_clear_namespace(cache_hl_bufnr, ns, 0, -1)
  end

  cache_hl_bufnr = nil -- delete cache
end

--- 检查一整行内所有 valide filepath, 然后 highlight.
local function hl_line()
  local rs = parse.parse_hl_line()
  if not rs then
    return
  end

  --- highlight
  for _, pos in ipairs(rs.pos) do
    --- highlight filepath
    vim.hl.range(rs.bufnr, ns, "my_filepath_underline", {pos.hl_lnum, pos.hl_start_col}, {pos.hl_lnum, pos.hl_end_col})
  end

  cache_hl_bufnr = rs.bufnr  -- cache bufnr
end

--- NOTE: matchadd() 每次执行只能作用在 current window 上. 所有在该 window 打开的 buffer 都会收到影响.
--- 而且状态持续, 当该 window 打开别的 buffer 时, highlight 一样会存在.
M.highlight_filepath = function()
  --- delete previous cached highlight
  M.highlight_clear_cache()

  --- highlight 整行中所有的 filepath
  hl_line()
end

return M
