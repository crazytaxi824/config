require('myplugins.winbarline.highlights')
require('myplugins.winbarline.autocmd')
require('myplugins.winbarline.lsp_handler') -- lsp methods 触发的相关事件

local keymaps = require('myplugins.winbarline.keymaps')


local M = {}

M.setup = function()
  keymaps.set()
end

return M
