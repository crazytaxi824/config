local mt = require('user.my_term')

local M = {}

M.exec_term = mt.new({
  id = 1001,
  jobdone = 'stopinsert',
  startinsert = false,
  auto_scroll = true,
})

--- normal terminals -----------------------------------------------------------
local function term_opts(id)
  return {
    id = id,
    jobdone = 'exit',
    startinsert = true,
  }
end

M.h1_term = mt.new(term_opts(1))
M.h2_term = mt.new(term_opts(2))
M.h3_term = mt.new(term_opts(3))
M.h4_term = mt.new(term_opts(4))
M.h5_term = mt.new(term_opts(5))
M.h6_term = mt.new(term_opts(6))
M.v7_term = mt.new(term_opts(7))
M.v8_term = mt.new(term_opts(8))
M.v9_term = mt.new(term_opts(9))

--- keymaps ----------------------------------------------------------------------------------------
local opt = {noremap = true, silent = true}
local function open_term()
  local t = mt.get_term_by_id(vim.v.count1)
  if not t or not t:open_win() then
    t:run()
  end
end

local toggleterm_keymaps = {
  {'n', 'tt', function() open_term() end, opt, "my_term: open Terminal #(1-9)"},
  {'n', '<leader>t', function() mt.toggle_all() end, opt, "my_term: toggle All Terminals"},

  {'n', '<F17>', function() M.exec_term:run() end, opt, "code: Re-Run Last cmd"},    -- <S-F5> re-run last cmd.
}

require('user.utils.keymaps').set(toggleterm_keymaps, {
  key_desc = {
    t = {name="Terminal"},
  },
  opts = {mode='n'},
})

return M
