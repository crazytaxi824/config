local mt = require('utils.my_term')
local fp = require('utils.filepath')

local M = {}

--- execute terminals: run cmd ---------------------------------------------------------------------
M.console = mt.new({
  id = 1001,
  auto_scroll = true,
  buf_output = true,  -- 这里使用 buf_job_output, ignore "jobdone" 设置.
  after_run = function(term_obj)
    --- highlight filepath & jump to filepath
    if term_obj.bufnr then
      fp.setup(term_obj.bufnr)
    end
  end,
})

--- DEBUG:
--- test append callback function. ----------------------------------------------------------------- {{{
-- M.console:append('before_run', function(term)
--   print('before_run', term)
-- end)
-- M.console:append('before_run', function(term)
--   print('before_run2', term)
-- end)
-- M.console:append('before_run', function(term)
--   print('before_run3', term)
-- end)
--
-- M.console:append('after_run', function(term)
--   print('after_run', term)
-- end)
-- M.console:append('after_run', function(term)
--   print('after_run2', term)
-- end)
-- M.console:append('after_run', function(term)
--   print('after_run3', term)
-- end)
--
-- M.console:append('on_open', function(term)
--   print('on_open', term)
-- end)
-- M.console:append('on_open', function(term)
--   print('on_open2', term)
-- end)
-- M.console:append('on_open', function(term)
--   print('on_open3', term)
-- end)
--
-- M.console:append('on_close', function(term)
--   print('on_close', term)
-- end)
-- M.console:append('on_close', function(term)
--   print('on_close2', term)
-- end)
-- M.console:append('on_close', function(term)
--   print('on_close3', term)
-- end)
--
-- M.console:append('on_stdout', function(term, job_id, data, event)
--   print('on_stdout', term, job_id, data, event)
-- end)
-- M.console:append('on_stdout', function(term, job_id, data, event)
--   print('on_stdout2', term, job_id, data, event)
-- end)
-- M.console:append('on_stdout', function(term, job_id, data, event)
--   print('on_stdout3', term, job_id, data, event)
-- end)
--
-- M.console:append('on_stderr', function(term, job_id, data, event)
--   print('on_stderr', term, job_id, data, event)
-- end)
-- M.console:append('on_stderr', function(term, job_id, data, event)
--   print('on_stderr2', term, job_id, data, event)
-- end)
-- M.console:append('on_stderr', function(term, job_id, data, event)
--   print('on_stderr3', term, job_id, data, event)
-- end)
--
-- M.console:append('on_exit', function(term, job_id, exit_code, event)
--   print('on_exit', term, job_id, exit_code, event)
-- end)
-- M.console:append('on_exit', function(term, job_id, exit_code, event)
--   print('on_exit2', term, job_id, exit_code, event)
-- end)
-- M.console:append('on_exit', function(term, job_id, exit_code, event)
--   print('on_exit3', term, job_id, exit_code, event)
-- end)
--
-- vim.print(M.console)
-- -- }}}

--- keymaps ----------------------------------------------------------------------------------------
local opt = { silent = true }
local my_term_keymaps = {
  {'n', '<D-F5>', function() M.console:run() end, opt, "code: Re-Run Last cmd"},
}
require('utils.keymaps').set(my_term_keymaps)

return M
