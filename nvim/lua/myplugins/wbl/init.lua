require('myplugins.wbl.highlights')
require('myplugins.wbl.lsp_handler') -- lsp methods 触发的相关事件

require('myplugins.wbl.autocmd')

local M = {}

M.setup = function()
  require('myplugins.wbl.keymaps').set()
end

return M
