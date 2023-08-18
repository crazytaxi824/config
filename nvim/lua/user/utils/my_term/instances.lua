local mt = require('user.utils.my_term')

local M = {}

--- execute terminals: run cmd ---------------------------------------------------------------------
M.exec_term = mt.new({
  id = 1001,
  auto_scroll = true,
  print_cmd = true,
  buf_output = true,  -- 这里使用 buf_job_output, ignore "jobdone" 设置.
})

--- keymaps ----------------------------------------------------------------------------------------
local opt = {noremap = true, silent = true}
local toggleterm_keymaps = {
  {'n', '<F17>', function() M.exec_term:run() end, opt, "code: Re-Run Last cmd"}, -- <S-F5> re-run last cmd.
}
require('user.utils.keymaps').set(toggleterm_keymaps)

return M
