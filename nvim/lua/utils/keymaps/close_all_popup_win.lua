local M = {}

M.close_pop_wins = function ()
  local win_closed
  local wins = vim.api.nvim_tabpage_list_wins(0)
  for _, win_id in ipairs(wins) do
    if vim.fn.win_gettype(win_id) == 'popup' then
      vim.api.nvim_win_close(win_id, true)
      win_closed = true
    end
  end

  return win_closed
end

return M
