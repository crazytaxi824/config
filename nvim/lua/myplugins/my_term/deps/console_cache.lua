--- @class ConsoleCache
--- @field event string
--- @field data string[]
local ConsoleCache = {}
ConsoleCache.__index = ConsoleCache

local ns = vim.api.nvim_create_namespace('my_term_output')

--- highlight
vim.api.nvim_set_hl(0, "my_output_sys", {ctermfg=Colors.orange.c, fg=Colors.orange.g})
vim.api.nvim_set_hl(0, "my_output_sys_error", {
  ctermfg=Colors.black.c, fg=Colors.black.g,
  ctermbg=Colors.red.c, bg=Colors.red.g,
})
vim.api.nvim_set_hl(0, "my_output_stdout", {ctermfg=Colors.blue.c, fg=Colors.blue.g})
vim.api.nvim_set_hl(0, "my_output_stderr", {ctermfg=Colors.red.c, fg=Colors.red.g})
vim.api.nvim_set_hl(0, "my_output_eof", {ctermfg=Colors.g238.c, fg=Colors.g238.g})


--- @param event string
--- @param data string[]
function ConsoleCache.new(event, data)
  --- @type ConsoleCache
  local self = setmetatable({
    event = event,
    data = data,
  }, ConsoleCache)
  return self
end

--- write to buffer
--- @param bufnr integer
--- @param start_lnum integer
function ConsoleCache:write(bufnr, start_lnum)
  local end_lnum = start_lnum + #self.data - 1

  vim.bo[bufnr].modifiable = true
  vim.api.nvim_buf_set_lines(bufnr, start_lnum, end_lnum, false, self.data)
  vim.bo[bufnr].modifiable = false

  if self.event == "stdout" then
    vim.hl.range(bufnr, ns, "my_output_stdout", {start_lnum, 0}, {end_lnum, -1})
  elseif self.event == "stderr" then
    vim.hl.range(bufnr, ns, "my_output_stderr", {start_lnum, 0}, {end_lnum, -1})
  elseif self.event == "eof" then
    vim.hl.range(bufnr, ns, "my_output_eof", {start_lnum, 0}, {end_lnum, -1})
  elseif self.event == "sys" then
    vim.hl.range(bufnr, ns, "my_output_sys", {start_lnum, 0}, {end_lnum, -1})
  else
    vim.hl.range(bufnr, ns, "my_output_sys_error", {start_lnum, 0}, {end_lnum, -1})
  end
end

return ConsoleCache
