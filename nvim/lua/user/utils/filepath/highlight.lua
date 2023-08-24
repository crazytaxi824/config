--- highlight filepath

local parse = require('user.utils.filepath.parse')

local M = {}

local cache_hl = nil  --- map {bufnr, ns_ids}

--- delete previous cached highlight
M.highlight_clear_cache = function()
  if cache_hl and vim.api.nvim_buf_is_valid(cache_hl.bufnr) then
    for _, ns_id in ipairs(cache_hl.ns_ids) do
      vim.api.nvim_buf_clear_namespace(cache_hl.bufnr, ns_id, 0, -1)
    end
  end
  cache_hl = nil -- delete cache
end

--- <cWORD> 如果是 filepath 则 highlight
local function hl_cWORD()
  local r = parse.parse_content(vim.fn.expand('<cWORD>'), 'hl')
  if not r then
    return
  end

  --- highlight current filepath
  local ns_id = vim.api.nvim_buf_add_highlight(r.bufnr, 0, "Underlined", r.hl_lnum, r.hl_start_col, r.hl_end_col)
  cache_hl = {bufnr = r.bufnr, ns_ids = {ns_id}}
end

--- 检查一整行内所有 valide filepath, 然后 highlight.
local function hl_line()
  local rs = parse.parse_hl_line()
  if not rs then
    return
  end

  --- highlight
  local ns_ids = {}
  local bufnr
  for _, r in ipairs(rs) do
    local ns_id = vim.api.nvim_buf_add_highlight(r.bufnr, 0, "Underlined", r.hl_lnum, r.hl_start_col, r.hl_end_col)
    bufnr = r.bufnr
    table.insert(ns_ids, ns_id)
  end
  cache_hl = {bufnr = bufnr, ns_ids = ns_ids}
end

--- NOTE: matchadd() 每次执行只能作用在 current window 上. 所有在该 window 打开的 buffer 都会收到影响.
--- 而且状态持续, 当该 window 打开别的 buffer 时, highlight 一样会存在.
M.highlight_filepath = function()
  --- delete previous cached highlight
  M.highlight_clear_cache()

  hl_line()   -- highlight 整行中所有的 filepath
  --hl_cWORD()  -- highlight <cWORD>
end

return M
