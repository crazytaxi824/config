require('myplugins.wbl.highlights')
require('myplugins.wbl.lsp_handler') -- lsp methods 触发的相关事件
require('myplugins.wbl.autocmd')

local M = {}

M.setup = function()
  require('myplugins.wbl.keymaps').set()

  vim.opt.showtabline = 1
  vim.opt.tabline = "%!v:lua.require('myplugins.wbl.tabline').custom_tabline()"
end

return M
