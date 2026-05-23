---@class WinbarLineBuffer
---@field bufnr integer
---@field private win_dict table<integer, boolean>
local WinbarLineBuf = {}
WinbarLineBuf.__index = WinbarLineBuf

---@param bufnr integer
---@param win_id integer
---@return WinbarLineBuffer
function WinbarLineBuf.new(bufnr, win_id)
  ---@type WinbarLineBuffer
  local self = setmetatable({
    bufnr = bufnr,
    win_dict = { [win_id] = true },
  }, WinbarLineBuf)
  return self
end

---@param win_id integer
function WinbarLineBuf:append_win(win_id)
  self.win_dict[win_id] = true
end

---@param win_id integer
function WinbarLineBuf:remove_win(win_id)
  self.win_dict[win_id] = nil
end

---@return integer[] win_ids
function WinbarLineBuf:list_wins()
  return vim.tbl_keys(self.win_dict)
end

--- 获取 diagnostic info
---@return {count: integer, severity: integer}|nil
function WinbarLineBuf:diagnostic()
  local diagnostics = vim.diagnostic.count(self.bufnr) or {}
  local diag_count = 0
  local severity = 9
  for s, c in pairs(diagnostics) do
    diag_count = diag_count + c

    if s < severity then
      severity = s
    end
  end

  if diag_count > 0 then
    return { count = diag_count, severity = severity }
  end
end

return WinbarLineBuf
