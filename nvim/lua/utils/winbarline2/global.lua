local M = {}


--- @type table<integer, WinbarLineBuffer>
M.bufs = {}

--- @type table<integer, WinbarLineWindow>
M.wins = {}


--- 找出 value 在 list 中的 index
---
--- @generic T
--- @param list T[]
--- @param val T
--- @return integer|nil
function M.list_index_value(list, val)
  for i, v in ipairs(list) do
    if v == val then
      return i
    end
  end
end


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
