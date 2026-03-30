local console = require('myplugins.my_term.instance_console')
local setup = require('myplugins.my_term.setup')


local M = {}

--- return console terminal
M.console = console.console

M.setup = setup.setup

return M
