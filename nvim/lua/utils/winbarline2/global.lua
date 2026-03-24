--- @type table<integer, WinbarLineBuffer>
local bufs = {}

--- @type table<integer, WinbarLineWindow>
local wins = {}


local M = {}

--- @param win_id integer
--- @return WinbarLineWindow|nil
function M.get_win(win_id)
  return wins[win_id]
end

--- @param win WinbarLineWindow
function M.set_win(win)
  wins[win.win_id] = win
end

--- @param win_id integer
function M.delete_win(win_id)
  wins[win_id] = nil
end

--- @param bufnr integer
--- @return WinbarLineBuffer|nil
function M.get_buf(bufnr)
  return bufs[bufnr]
end

--- @param buf WinbarLineBuffer
function M.set_buf(buf)
  bufs[buf.bufnr] = buf
end

--- @param bufnr integer
function M.delete_buf(bufnr)
  bufs[bufnr] = nil
end

--- debug ------------------------------------------------------------------------------------------
function M:debug()
  for win_id, w in pairs(wins) do
    print('win:', win_id, vim.inspect(w:list_bufs()))
  end

  for bufnr, b in pairs(bufs) do
    print('buf:', bufnr, vim.inspect(b:list_wins()))
  end
end


return M
