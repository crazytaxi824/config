local M = {}

-- console terminal
M.console = require('myplugins.my_term.instance_console').console

M.setup = function()
  require('myplugins.my_term.keymaps').set()
end

return M
