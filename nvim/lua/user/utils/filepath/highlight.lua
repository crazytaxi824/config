local pat = require('user.global.filepath.pattern')

local M = {}

vim.api.nvim_set_hl(0, 'Filepath', {underline = true}) -- 自定义颜色, for Highlight_filepath()
vim.api.nvim_set_hl(0, 'URL', {ctermfg = Color.info_blue, underline = true}) -- 自定义颜色, for Highlight_filepath()

--- NOTE: matchadd() 每次执行只能作用在 current window 上.
--- 而且状态持续, 当该 window 打开别的 buffer 时, highlight 一样会存在.
M.highlight_filepath = function()
  vim.fn.matchadd('Filepath', pat.file_schema_pattern)
  vim.fn.matchadd('Filepath', pat.filepath_pattern)
  vim.fn.matchadd('URL', pat.url_schema_pattern)
end

return M
