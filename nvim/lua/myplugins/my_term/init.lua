local console = require('myplugins.my_term.instance_console')
local keymaps = require('myplugins.my_term.keymaps')


local M = {}

-- console terminal
M.console = console.console

M.setup = function()
  keymaps.set()
end

return M
