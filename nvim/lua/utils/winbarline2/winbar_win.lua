local g = require('utils.winbarline2.global')


--- @class WinbarLineWindow
--- @field win_id integer
--- @field private buf_list integer[]  -- 需要排序
local M = {}
M.__index = M

---@param bufnr integer
---@param win_id integer
---@return WinbarLineWindow
function M.new(win_id, bufnr)
  local self = setmetatable({
    win_id = win_id,
    buf_list = { bufnr },
  }, M)
  return self
end

---@param bufnr integer
function M:append_buf(bufnr)
  if not vim.list_contains(self.buf_list, bufnr) then
    table.insert(self.buf_list, bufnr)
  end
end

---@param bufnr integer
function M:remove_buf(bufnr)
  local idx = g.list_index_value(self.buf_list, bufnr)
  if idx then
    table.remove(self.buf_list, idx)
  end
end

--- @return integer[]
function M:list_bufs()
  return self.buf_list
end


--- set winbar for this window
function M:set_winbar()
  error("TODO")  -- TODO
end

return M
