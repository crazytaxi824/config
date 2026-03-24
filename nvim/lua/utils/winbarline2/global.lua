local M = {}


--- @type table<integer, WinbarLineBuffer>
M.bufs = {}

--- @type table<integer, WinbarLineWindow>
M.wins = {}

--- TODO: 使用函数, 不要直接读取属性

--- debug ------------------------------------------------------------------------------------------
function M:debug()
  for win_id, w in pairs(self.wins) do
    print('win:', win_id, vim.inspect(w:list_bufs()))
  end

  for bufnr, b in pairs(self.bufs) do
    print('buf:', bufnr, vim.inspect(b:list_wins()))
  end
end


return M
