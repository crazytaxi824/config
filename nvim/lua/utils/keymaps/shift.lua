local M = {}

local count = 3

M.up = function()
  if vim.v.count > 0 then
    count = vim.v.count
  end
  vim.cmd.normal({ args = {count..'gk'}, bang=true })
end

M.down = function()
  if vim.v.count > 0 then
    count = vim.v.count
  end
  vim.cmd.normal({ args = {count..'gj'}, bang=true })
end

return M
