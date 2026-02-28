local g = require('utils.my_term.deps.global')
local new_mt = require('utils.my_term.new_term')
local fp = require('utils.filepath')

--- @type integer
local console_id = 1001

--- @type MyTermOpts
local default_opts = {
  id = console_id,
  auto_scroll = true,
  console_output = true,  -- 这里使用 console_exec()
  after_run = function(_, term_bufnr)
    --- highlight filepath & jump to filepath
    if term_bufnr then
      fp.setup(term_bufnr)
    end
  end,
}


local M = {}

--- execute terminals: run cmd ---------------------------------------------------------------------
M.console = new_mt._new(default_opts)

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
