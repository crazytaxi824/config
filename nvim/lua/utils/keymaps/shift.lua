local M = {}

local count = 3

--- <Shift-UP>
M.up = function()
  if vim.v.count > 0 then
    count = vim.v.count
  end
  vim.cmd.normal({ args = {count..'gk'}, bang=true })
end

--- <Shift-Down>
M.down = function()
  if vim.v.count > 0 then
    count = vim.v.count
  end
  vim.cmd.normal({ args = {count..'gj'}, bang=true })
end

return M
