local M = {}

M.up = function()
  local move = math.ceil(vim.api.nvim_win_get_height(0)/2)
  vim.cmd.normal({ args = {move..'gk'}, bang=true })
end

M.down = function()
  local move = math.ceil(vim.api.nvim_win_get_height(0)/2)
  vim.cmd.normal({ args = {move..'gj'}, bang=true })
end

return M
