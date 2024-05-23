local mt = require('utils.my_term')
local fp = require('utils.filepath')

local M = {}

--- execute terminals: run cmd ---------------------------------------------------------------------
M.console = mt.new({
  id = 1001,
  auto_scroll = true,
  print_cmd = true,
  buf_output = true,  -- 这里使用 buf_job_output, ignore "jobdone" 设置.
  after_run = function(term_obj)
    --- highlight filepath & jump to filepath
    if term_obj.bufnr then
      fp.setup(term_obj.bufnr)
    end
  end,
})

--- keymaps ----------------------------------------------------------------------------------------
local opt = {noremap = true, silent = true}
local my_term_keymaps = {
  {'n', '<F17>', function() M.console:run() end, opt, "code: Re-Run Last cmd"}, -- <S-F5> re-run last cmd.
}
require('utils.keymaps').set(my_term_keymaps)

return M
