local mt = require('user.my_term')

local M = {}

M.exec_term = mt.new({
  id = 1001,
  jobdone = 'stopinsert',
  startinsert = false,
  auto_scroll = true,
})

return M
