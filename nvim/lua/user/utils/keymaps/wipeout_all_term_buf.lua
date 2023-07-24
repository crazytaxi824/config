--- close all terminals' window; stop all terminals' job; wipeout all terminals' buffer.

local M = {}

M.wipeout_all_terminals = function()
  -- 获取所有 bufnr, 判断 bufname 是否匹配 term://*
  for bufnr = vim.fn.bufnr('$'), 1, -1 do
    if vim.bo[bufnr].buftype == 'terminal' then
      vim.api.nvim_buf_delete(bufnr, {force=true})  -- wipeout buffe
    end
  end
end

return M
