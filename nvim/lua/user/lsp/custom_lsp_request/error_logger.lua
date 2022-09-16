--- log custom vim.lsp.buf_request() handler error message to file

local M = {}

local log_filepath = vim.fn.stdpath('cache') .. '/custom_lsp_handler.log'

--- lsp.buf_request() 中 handler(err, result, req, config)
--- name: custome handler name
--- req: table (map)
--- err: table (list)
M.log = function(name, req, err)
  local time_now = vim.fn.strftime("[%Y-%m-%d %H:%M:%S] ")

  local req_str = vim.fn.json_encode(req)

  local msg = {time_now .. name, "Request: " .. req_str, "Errors:"}

  vim.list_extend(msg, err)
  vim.list_extend(msg, {''})  -- 最后空一行

  --- 将内容写入文件中.
  vim.fn.writefile(msg, log_filepath, 'a')
end

return M
