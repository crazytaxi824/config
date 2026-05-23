---@type table<integer, WinbarLineBuffer>
local bufs = {}

---@type table<integer, WinbarLineWindow>
local wins = {}


local M = {}

---@param win_id integer
---@return WinbarLineWindow|nil
function M.get_win(win_id)
  if vim.api.nvim_win_is_valid(win_id) then
    return wins[win_id]
  else
    wins[win_id] = nil
  end
end

---@param win WinbarLineWindow
function M.set_win(win)
  if vim.api.nvim_win_is_valid(win.win_id) then
    wins[win.win_id] = win
  end
end

---@param win_id integer
function M.delete_win(win_id)
  wins[win_id] = nil
end

---@param bufnr integer
---@return WinbarLineBuffer|nil
function M.get_buf(bufnr)
  if vim.api.nvim_buf_is_valid(bufnr) then
    return bufs[bufnr]
  else
    bufs[bufnr] = nil
  end
end

---@param buf WinbarLineBuffer
function M.set_buf(buf)
  if vim.api.nvim_buf_is_valid(buf.bufnr) then
    bufs[buf.bufnr] = buf
  end
end

---@param bufnr integer
function M.delete_buf(bufnr)
  bufs[bufnr] = nil
end

-- debug ------------------------------------------------------------------------------------------
function M:debug()
  for win_id, w in pairs(wins) do
    print('win:', win_id, vim.inspect(w:list_bufs()))
  end

  for bufnr, b in pairs(bufs) do
    print('buf:', bufnr, vim.inspect(b:list_wins()))
  end
end


return M
