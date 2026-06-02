local keymaps = require('myplugins.my_term.keymaps')


local M = {}

-- console terminal
M.console = require('myplugins.my_term.instance_console').console

M.setup = function()
  keymaps.set()
end

return M
