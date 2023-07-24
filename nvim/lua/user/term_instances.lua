local mt = require('user.utils.my_term')

local M = {}

--- execute terminals: run cmd ---------------------------------------------------------------------
M.exec_term = mt.new({
  id = 1001,
  jobdone = 'stopinsert',
  startinsert = false,
  auto_scroll = true,
})

--- shell terminals --------------------------------------------------------------------------------
local function open_shell_term()
  local t = mt.get_term_by_id(vim.v.count1)
  --- terminal 没有被缓存则 :new()
  if not t then
    t = mt.new({
      id = vim.v.count1,
      jobdone = 'exit',
      startinsert = true,
    })
    t:run()
    return
  end

  --- terminal 存在, 但是无法 open_win(), 则 run()
  if not t:open_win() then
    t:run()
  end
end

--- keymaps ----------------------------------------------------------------------------------------
local opt = {noremap = true, silent = true}
local toggleterm_keymaps = {
  {'n', 'tt', function() open_shell_term() end, opt, "my_term: open Terminal #(1-9)"},
  {'n', '<leader>t', function() mt.toggle_all() end, opt, "my_term: toggle All Terminals"},

  {'n', '<F17>', function() M.exec_term:run() end, opt, "code: Re-Run Last cmd"},    -- <S-F5> re-run last cmd.
}

require('user.utils.keymaps').set(toggleterm_keymaps, {
  key_desc = {
    t = {name="Terminal"},
  },
  opts = {mode='n'},
})

--- debug: get a terminal instance -----------------------------------------------------------------
function Get_Term_by_ID(id)
  local t = mt.get_term_by_id(id)
  return t or mt.new({id=id})
end

return M
