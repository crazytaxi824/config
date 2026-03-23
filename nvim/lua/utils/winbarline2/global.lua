local M = {}


--- @type table<integer, WinbarLineBuffer>
M.bufs = {}

--- @type table<integer, WinbarLineWindow>
M.wins = {}


--- debug ------------------------------------------------------------------------------------------
function Get_WinbarLine()
  for win_id, w in ipairs(M.wins) do
    print('win:', win_id, vim.inspect(w))
  end

  for bufnr, b in ipairs(M.bufs) do
    print('buf:', bufnr, vim.inspect(b))
  end
end


return M
