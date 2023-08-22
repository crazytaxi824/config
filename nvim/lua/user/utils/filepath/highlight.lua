--- highlight filepath

local parse = require('user.utils.filepath.parse')

local M = {}

local cache_hl = nil

--- delete previous cached highlight
M.highlight_clear_cache = function()
  if cache_hl and vim.api.nvim_buf_is_valid(cache_hl.bufnr) then
    vim.api.nvim_buf_clear_namespace(cache_hl.bufnr, cache_hl.ns_id, 0, -1)
  end
  cache_hl = nil -- delete cache
end

-- --- NOTE: matchadd() 每次执行只能作用在 current window 上. 所有在该 window 打开的 buffer 都会收到影响.
-- --- 而且状态持续, 当该 window 打开别的 buffer 时, highlight 一样会存在.
M.highlight_filepath = function()
  --- delete previous cached highlight
  M.highlight_clear_cache()

  local r = parse.parse(vim.fn.expand('<cWORD>'), 'hl')
  if not r then
    return
  end

  --- highlight current filepath
  local ns_id = vim.api.nvim_buf_add_highlight(r.bufnr, 0, "Underlined", r.hl_lnum, r.hl_start_col, r.hl_end_col)
  cache_hl = vim.tbl_deep_extend("force", r, {ns_id = ns_id})
end

return M
