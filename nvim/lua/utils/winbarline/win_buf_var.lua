local utils = require('utils.winbarline.utils')


--- @type { [integer]: integer[]}
local win_buf_list = {}

--- @type { [integer]: { [integer]: boolean }}
local buf_win_dict = {}

local M = {}

--- for winvar -------------------------------------------------------------------------------------

--- @param win_id integer
--- @param bufnr integer
function M.append_buf_to_win(win_id, bufnr)
  if not vim.api.nvim_buf_is_valid(bufnr) or not vim.api.nvim_win_is_valid(win_id) then
    error('win_id: ' .. win_id .. ', or bufnr: ' .. bufnr .. ' is not valid' )
  end

  --- @type integer[]
  local win_bufs = win_buf_list[win_id] or {}

  if not vim.list_contains(win_bufs, bufnr) then
    table.insert(win_bufs, bufnr)
    win_buf_list[win_id] = win_bufs
  end
end


--- @param win_id integer
--- @param bufnr integer
function M.remove_buf_from_win(win_id, bufnr)
  if not vim.api.nvim_buf_is_valid(bufnr) or not vim.api.nvim_win_is_valid(win_id) then
    error('win_id: ' .. win_id .. ', or bufnr: ' .. bufnr .. ' is not valid' )
  end

  --- floating window 没有 buffer list
  --- @type integer[]
  local win_bufs = win_buf_list[win_id]
  if not win_bufs then
    return
  end

  local idx = utils.list_index_value(win_bufs, bufnr)
  if not idx then
    return
  end

  table.remove(win_bufs, idx)
  win_buf_list[win_id] = win_bufs
end


--- @param win_id integer
function M.delete_win(win_id)
  win_buf_list[win_id] = nil
end

--- @param win_id integer
--- @return integer[]|nil
function M.get_win_bufs(win_id)
  return win_buf_list[win_id]
end

--- @param win_id integer
--- @param win_bufs integer[]
function M.set_win_bufs(win_id, win_bufs)
  win_buf_list[win_id] = win_bufs
end

--- for bufvar -------------------------------------------------------------------------------------

--- @param bufnr integer
--- @param win_id integer
function M.append_win_to_buf(bufnr, win_id)
  if not vim.api.nvim_buf_is_valid(bufnr) or not vim.api.nvim_win_is_valid(win_id) then
    error('win_id: ' .. win_id .. ', or bufnr: ' .. bufnr .. ' is not valid' )
  end

  --- @type { [integer]: boolean }
  local buf_wins = buf_win_dict[bufnr] or {}
  buf_wins[win_id] = true
  buf_win_dict[bufnr] = buf_wins
end


--- @param bufnr integer
--- @param win_id integer
function M.remove_win_from_buf(bufnr, win_id)
  if not vim.api.nvim_buf_is_valid(bufnr) or not vim.api.nvim_win_is_valid(win_id) then
    error('win_id: ' .. win_id .. ', or bufnr: ' .. bufnr .. ' is not valid' )
  end

  --- buffer 可以没有 win list
  --- @type { [integer]: boolean }
  local buf_wins = buf_win_dict[bufnr]
  if not buf_wins then
    return
  end

  buf_wins[win_id] = nil
  buf_win_dict[bufnr] = buf_wins
end

--- @param bufnr integer
function M.delete_buf(bufnr)
  buf_win_dict[bufnr] = nil
end

--- @param bufnr integer
--- @return { [integer]: boolean }|nil
function M.get_buf_wins(bufnr)
  return buf_win_dict[bufnr]
end

--- @param bufnr integer
--- @param buf_wins { [integer]: boolean }
function M.set_buf_wins(bufnr, buf_wins)
  buf_win_dict[bufnr] = buf_wins
end

return M
