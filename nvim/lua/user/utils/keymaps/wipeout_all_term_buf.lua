--- close all terminals' window; stop all terminals' job; wipeout all terminals' buffer.

local M = {}

M.wipeout_all_terminals = function()
  for _, bufnr in ipairs(vim.api.nvim_list_bufs()) do
    if vim.bo[bufnr].buftype == 'terminal' then
      vim.api.nvim_buf_delete(bufnr, {force=true})  -- wipeout buffe
    end
  end
end

return M
