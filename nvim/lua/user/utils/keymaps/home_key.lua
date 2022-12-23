local M = {}

--- <HOME> key in `:set nowrap` situation.
--- 先跳到 '^' first non-blank character of the line, 再跳到 '0' first character of the line.
M.nowrap = function()
  local before_pos = vim.fn.getpos('.')
  vim.cmd('normal! ^')

  local after_pos = vim.fn.getpos('.')
  if before_pos[2] == after_pos[2] and before_pos[3] == after_pos[3] then
    vim.cmd('normal! 0')
  end
end

--- <HOME> key in `:set wrap` situation.
--- <Home> 快捷键先跳到 'g^' first non-blank character of the line, 再跳到 'g0' first character of the line.
M.wrap = function()
  local before_pos = vim.fn.getpos('.')
  vim.cmd('normal! g^')

  local after_pos = vim.fn.getpos('.')
  if before_pos[2] == after_pos[2] and before_pos[3] == after_pos[3] then
    vim.cmd('normal! g0')
  end
end

return M
