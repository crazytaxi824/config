local u = require('myplugins.winbarline.utils')
local wb_fmt = require('myplugins.winbarline.winbar_formatter')


---@class WinbarLineWindow
---@field win_id integer
---@field width integer
---@field private buf_list integer[]  -- 需要排序
local WinbarLineWin = {}
WinbarLineWin.__index = WinbarLineWin

---@param bufnr integer
---@param win_id integer
---@param win_width integer
---@return WinbarLineWindow
function WinbarLineWin.new(win_id, bufnr, win_width)
  ---@type WinbarLineWindow
  local self = setmetatable({
    win_id = win_id,
    buf_list = { bufnr },
    width = win_width,
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

---@return integer[] bufnrs
function WinbarLineWin:list_bufs()
  ---@type integer[]
  local valid_bufs = {}
  for _, bufnr in ipairs(self.buf_list) do
    if vim.api.nvim_buf_is_valid(bufnr) then
      table.insert(valid_bufs, bufnr)
    end
  end

  self.buf_list = valid_bufs
  return self.buf_list
end

---@param bufnrs integer[]
function WinbarLineWin:set_bufs(bufnrs)
  self.buf_list = bufnrs
end

-- set winbar for this window
--
---@param win_width? integer  update win_width if needed
function WinbarLineWin:set_winbar(win_width)
  if not vim.api.nvim_win_is_valid(self.win_id) then
    return
  end

  -- update window width
  if win_width then
    self.width = win_width
  end

  -- 先 update window width, 再 format winbar string
  local winbar_str = wb_fmt.winbar_format(self.win_id) or ''
  vim.api.nvim_set_option_value('winbar', winbar_str, { scope='local', win=self.win_id })
end

return WinbarLineWin
