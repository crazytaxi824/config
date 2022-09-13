--- log custom vim.lsp.buf_request() handler error message to file

local M = {}

local log_filepath = vim.fn.stdpath('cache') .. '/custom_lsp_handler.log'

M.log = function(err)
  local time_now = vim.fn.strftime("[%Y-%m-%d %H:%M:%S]")

  --- 将内容写入文件中.
  vim.fn.writefile(vim.list_extend({time_now}, err), log_filepath, 'a')
end

return M
