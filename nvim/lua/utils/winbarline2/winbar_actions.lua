local wb_win = require("utils.winbarline2.winbar_win")
local wb_buf = require("utils.winbarline2.winbar_buf")
local g = require('utils.winbarline2.global')



local M = {}

---@param bufnr integer
---@param win_id integer
---@return WinbarLineWindow
local function binding_win_buf(win_id, bufnr)
  if not vim.api.nvim_buf_is_valid(bufnr) or not vim.api.nvim_win_is_valid(win_id) then
    error('win: ' .. win_id .. ', or bufnr: ' .. bufnr .. ' is not valid' )
  end

  local win = g.wins[win_id]
  if win then
    win:append_buf(bufnr)
  else
    win = wb_win.new(win_id, bufnr)
    g.wins[win_id] = win
  end

  local buf = g.bufs[bufnr]
  if buf then
    buf:append_win(win_id)
  else
    buf = wb_buf.new(bufnr, win_id)
    g.bufs[bufnr] = buf
  end

  return win
end


---@param bufnr integer
---@param win_id integer
---@return WinbarLineWindow
local function unbind_win_buf(win_id, bufnr)
  if not vim.api.nvim_buf_is_valid(bufnr) or not vim.api.nvim_win_is_valid(win_id) then
    error('win: ' .. win_id .. ', or bufnr: ' .. bufnr .. ' is not valid' )
  end

  local win = g.wins[win_id]
  if not win then
    error("win: " .. win_id .. " is not exist")
  end

  local buf = g.bufs[bufnr]
  if not buf then
    error("buffer: " .. bufnr .. " is not exist")
  end

  buf:remove_win(win_id)
  win:remove_buf(bufnr)

  return win
end


return M
