local M = {}

-- 自动滚动页面到底部
--
---@param term MyTerm
---@param term_bufnr integer
function M.buf_scroll_bottom(term, term_bufnr)
  if not term:auto_scroll() then
    return
  end

  local win_id = vim.fn.bufwinid(term_bufnr)
  if win_id > 0 then
    local last_lnum = vim.api.nvim_buf_line_count(term_bufnr)  -- 获取 buffer line count
    vim.api.nvim_win_set_cursor(win_id, {last_lnum, 0})  -- (1,0)-indexed
  end
end

return M
