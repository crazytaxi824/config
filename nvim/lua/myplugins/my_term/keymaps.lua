-- global keymaps ---------------------------------------------------------------------------------
local M = {}


function M.set()
  local opt = { silent = true }
  local keymaps = {
    -- NOTE: terminal key mapping 在其他 plugin 中也有设置.
    {'n', '<leader>tt', function() require("myplugins.my_term.instance_shell").open_shell_term() end, opt, "open/new Terminal #(1~999)"},
    {'n', '<leader>ta', function() require('myplugins.my_term.term_actions').toggle_all() end,  opt, "toggle All Terminals windows"},
    {'n', '<leader>tC', function() require('myplugins.my_term.term_actions').close_all() end,   opt, "close All Terminals windows"},
    {'n', '<leader>tO', function() require('myplugins.my_term.term_actions').open_all() end,    opt, "open All Terminals windows"},
    {'n', '<leader>tW', function() require('myplugins.my_term.term_actions').wipeout_all() end, opt, "wipeout All Terminals"},
    -- {'n', '<leader>tW', function() require('utils.keymaps').wipe_all_term_bufs() end, opt, "wipeout All Terminals"},
  }

  require('utils.keymaps').set(keymaps, {
    { "<leader>t", group = "my_term" },
  })
end


return M
