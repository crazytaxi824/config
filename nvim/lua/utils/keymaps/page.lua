local M = {}

M.up = function()
  local move = math.ceil(vim.api.nvim_win_get_height(0)/2)
  vim.cmd('normal! '.. move .. 'gk')
end

M.down = function()
  local move = math.ceil(vim.api.nvim_win_get_height(0)/2)
  vim.cmd('normal! '.. move .. 'gj')
end

return M
