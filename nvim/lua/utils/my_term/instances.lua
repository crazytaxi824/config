local g = require('utils.my_term.deps.global')
local mt = require('utils.my_term')
local fp = require('utils.filepath')

local console_id = 1001


local M = {}

--- execute terminals: run cmd ---------------------------------------------------------------------
M.console = mt.new({
  id = console_id,
  auto_scroll = true,
  console_output = true,  -- 这里使用 console_exec()
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
  {'n', '<D-F5>', function()
    local tp = g.get_TermPost(console_id)
    if tp then
      tp:run()
    end
  end, opt, "Fn 5: code: Re-Run Last cmd"},
}
require('utils.keymaps').set(my_term_keymaps)

return M
