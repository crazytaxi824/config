local utils = require('utils.winbarline.utils')


local winvar = "my_win_bufs"
local bufvar = "my_buf_wins"

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
  local win_bufs = vim.w[win_id][winvar] or {}

  if not vim.list_contains(win_bufs, bufnr) then
    table.insert(win_bufs, bufnr)
    vim.w[win_id][winvar] = win_bufs
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
  local win_bufs = vim.w[win_id][winvar]
  if not win_bufs then
    return
  end

  local idx = utils.list_index_value(win_bufs, bufnr)
  if not idx then
    return
  end

  table.remove(win_bufs, idx)
  vim.w[win_id][winvar] = win_bufs
end


--- @param win_id integer
--- @return integer[]|nil
function M.get_win_bufs(win_id)
  return vim.w[win_id][winvar]
end

--- @param win_id integer
--- @param win_bufs integer[]
function M.set_win_bufs(win_id, win_bufs)
  vim.w[win_id][winvar] = win_bufs
end

--- for bufvar -------------------------------------------------------------------------------------

--- @param bufnr integer
--- @param win_id integer
function M.append_win_to_buf(bufnr, win_id)
  if not vim.api.nvim_buf_is_valid(bufnr) or not vim.api.nvim_win_is_valid(win_id) then
    error('win_id: ' .. win_id .. ', or bufnr: ' .. bufnr .. ' is not valid' )
  end

  --- @type integer[]
  local buf_wins = vim.b[bufnr][bufvar] or {}

  if not vim.list_contains(buf_wins, win_id) then
    table.insert(buf_wins, win_id)
    vim.b[bufnr][bufvar] = buf_wins
  end
end


--- @param bufnr integer
--- @param win_id integer
function M.remove_win_from_buf(bufnr, win_id)
  if not vim.api.nvim_buf_is_valid(bufnr) or not vim.api.nvim_win_is_valid(win_id) then
    error('win_id: ' .. win_id .. ', or bufnr: ' .. bufnr .. ' is not valid' )
  end

  --- buffer 可以没有 win list
  --- @type integer[]
  local buf_wins = vim.b[bufnr][bufvar]
  if not buf_wins then
    return
  end

  local idx = utils.list_index_value(buf_wins, win_id)
  if not idx then
    return
  end

  table.remove(buf_wins, win_id)
  vim.b[bufnr][bufvar] = buf_wins
end

--- @param bufnr integer
--- @return integer[]|nil
function M.get_buf_wins(bufnr)
  return vim.b[bufnr][bufvar]
end

--- @param bufnr integer
--- @param buf_wins integer[]
function M.set_buf_wins(bufnr, buf_wins)
  vim.b[bufnr][bufvar] = buf_wins
end

return M
