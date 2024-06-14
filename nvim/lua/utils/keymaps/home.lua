--- <Home> key in `:set nowrap` and `:set wrap` situation.

local M = {}

--- <Home> key in `:set nowrap` situation.
--- 先跳到 '^' first non-blank character of the line, 再跳到 '0' first character of the line.
M.nowrap = function()
  --- ^ 之前获取 cursor 位置.
  local before_line, before_col = unpack(vim.api.nvim_win_get_cursor(0))
  vim.cmd.normal({ args = {'^'}, bang=true })

  --- ^ 之后获取 cursor 位置.
  local after_line, after_col = unpack(vim.api.nvim_win_get_cursor(0))
  if before_line == after_line and before_col == after_col then
    vim.cmd.normal({ args = {'0'}, bang=true })
  end
end

--- <Home> key in `:set wrap` situation.
--- <Home> 快捷键先跳到 'g^' first non-blank character of the line, 再跳到 'g0' first character of the line.
M.wrap = function()
  --- g^ 之前获取 cursor 位置.
  local before_line, before_col = unpack(vim.api.nvim_win_get_cursor(0))
  vim.cmd.normal({ args = {'g^'}, bang=true })

  --- g^ 之后获取 cursor 位置.
  local after_line, after_col = unpack(vim.api.nvim_win_get_cursor(0))
  if before_line == after_line and before_col == after_col then
    vim.cmd.normal({ args = {'g0'}, bang=true })
  end
end

return M
