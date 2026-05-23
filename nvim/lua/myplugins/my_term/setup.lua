local t_act = require('myplugins.my_term.term_actions')
local shell_term = require("myplugins.my_term.instance_shell")


-- global keymaps ---------------------------------------------------------------------------------
local M = {}


function M.setup()
  local opt = { silent = true }
  local keymaps = {
    -- NOTE: terminal key mapping 在其他 plugin 中也有设置.
    {'n', '<leader>tt', function() shell_term.open_shell_term() end, opt, "open/new Terminal #(1~999)"},
    {'n', '<leader>ta', function() t_act.toggle_all() end,  opt, "toggle All Terminals windows"},
    {'n', '<leader>tC', function() t_act.close_all() end,   opt, "close All Terminals windows"},
    {'n', '<leader>tO', function() t_act.open_all() end,    opt, "open All Terminals windows"},
    {'n', '<leader>tW', function() t_act.wipeout_all() end, opt, "wipeout All Terminals"},
    -- {'n', '<leader>tW', function() require('utils.keymaps').wipe_all_term_bufs() end, opt, "wipeout All Terminals"},
  }

  require('utils.keymaps').set(keymaps, {
    { "<leader>t", group = "my_term" },
  })
end


return M
