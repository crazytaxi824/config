local mt = require('utils.my_term')
local fp = require('utils.filepath')

local M = {}

--- execute terminals: run cmd ---------------------------------------------------------------------
M.console = mt.new({
  id = 1001,
  auto_scroll = true,
  console_output = true,  -- 这里使用 console_exec(), ignore "jobdone" 设置.
  after_run = function(_, term_bufnr)
    --- highlight filepath & jump to filepath
    if term_bufnr then
      fp.setup(term_bufnr)
    end
  end,
})

--- keymaps ----------------------------------------------------------------------------------------
local opt = { silent = true }
local my_term_keymaps = {
  {'n', '<D-F5>', function() M.console:run() end, opt, "Fn 5: code: Re-Run Last cmd"},
}
require('utils.keymaps').set(my_term_keymaps)

return M
