require('myplugins.winbarline.highlights')
require('myplugins.winbarline.autocmd')
require('myplugins.winbarline.lsp_handler') -- lsp methods 触发的相关事件

local setup = require('myplugins.winbarline.setup')


local M = {}

M.setup = setup.setup

return M
