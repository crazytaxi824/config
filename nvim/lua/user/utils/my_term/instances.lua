local mt = require('user.utils.my_term')

local M = {}

--- execute terminals: run cmd ---------------------------------------------------------------------
M.exec_term = mt.new({
  id = 1001,
  jobdone = 'stopinsert',
  auto_scroll = true,
})

--- keymaps ----------------------------------------------------------------------------------------
local opt = {noremap = true, silent = true}
local toggleterm_keymaps = {
  {'n', '<F17>', function() M.exec_term:run() end, opt, "code: Re-Run Last cmd"}, -- <S-F5> re-run last cmd.
}
require('user.utils.keymaps').set(toggleterm_keymaps)

return M
