local g = require('myplugins.my_term.deps.global')
local mt = require('myplugins.my_term.myterm')

---@type integer
local console_id = 1001

---@type MyTermOpts
local default_opts = {
  auto_scroll = true,
  console_output = true,  -- 这里使用 console_exec()
  on_init = function(_, term_bufnr)
    -- set highlight filepath & jump to filepath functions
    require('utils.filepath').auto_hl_current_line(term_bufnr)
  end,
}


-- keymaps ----------------------------------------------------------------------------------------
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


-- execute terminals: run cmd
local M = {}

-- reset console terminal callbacks
--
---@return MyTerm
M.console = function()
  return mt.new(console_id, default_opts, 'force')
end

return M
