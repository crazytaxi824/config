local g = require('utils.winbarline2.global')


--- @class WinbarLineBuffer
--- @field bufnr integer
--- @field private win_dict table<integer, boolean>
local M = {}
M.__index = M

---@param bufnr integer
---@param win_id integer
---@return WinbarLineBuffer
function M.new(bufnr, win_id)
  local self = setmetatable({
    bufnr = bufnr,
    wins = { [win_id] = true },
  }, M)
  return self
end

---@param win_id integer
function M:append_win(win_id)
  self.win_dict[win_id] = true
end

---@param win_id integer
function M:remove_win(win_id)
  self.win_dict[win_id] = nil
end

--- @return integer[]
function M:list_wins()
  return vim.tbl_keys(self.win_dict)
end

return M
