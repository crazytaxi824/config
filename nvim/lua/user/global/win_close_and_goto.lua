--- close current window and goto choosen window.
function Close_win_goto_choosen_win(win_id)
  local curr_win_id = vim.api.nvim_get_current_win()

  --- goto choosen window
  vim.fn.win_gotoid(win_id)

  --- close window
  vim.api.nvim_win_close(curr_win_id, "force")
end

--- close current window and goto previous window.
function Close_win_goto_prev_win()
  local curr_win_id = vim.api.nvim_get_current_win()

  vim.cmd('wincmd p')  -- goto previous window

  --- close window
  vim.api.nvim_win_close(curr_win_id, "force")
end



