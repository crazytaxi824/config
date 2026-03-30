local u = require('myplugins.winbarline.utils')
local wb_fmt = require('myplugins.winbarline.winbar_formatter')


--- @class WinbarLineWindow
--- @field win_id integer
--- @field private buf_list integer[]  -- 需要排序
local WinbarLineWin = {}
WinbarLineWin.__index = WinbarLineWin

---@param bufnr integer
---@param win_id integer
---@return WinbarLineWindow
function WinbarLineWin.new(win_id, bufnr)
  --- @type WinbarLineWindow
  local self = setmetatable({
    win_id = win_id,
    buf_list = { bufnr },
  }, WinbarLineWin)
  return self
end

---@param bufnr integer
function WinbarLineWin:append_buf(bufnr)
  if not vim.list_contains(self.buf_list, bufnr) then
    table.insert(self.buf_list, bufnr)
  end
end

---@param bufnr integer
function WinbarLineWin:remove_buf(bufnr)
  local idx = u.list_index_value(self.buf_list, bufnr)
  if idx then
    table.remove(self.buf_list, idx)
  end
end

--- @return integer[] bufnrs
function WinbarLineWin:list_bufs()
  return self.buf_list
end

--- @param bufnrs integer[]
function WinbarLineWin:set_bufs(bufnrs)
  self.buf_list = bufnrs
end

--- set winbar for this window
function WinbarLineWin:set_winbar()
  local winbar_str = wb_fmt.winbar_format(self.win_id)
  if winbar_str then
    vim.api.nvim_set_option_value('winbar', winbar_str, { scope='local', win=self.win_id })
  end
end

return WinbarLineWin
