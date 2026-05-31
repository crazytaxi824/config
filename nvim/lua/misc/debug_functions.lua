-- list all LSP clients' info
---@param bufnr integer
__Debug.Get_LSP_Client_info_By_bufnr = function(bufnr)
  local clients
  if bufnr then
    clients = vim.tbl_values(vim.lsp.get_clients({bufnr = bufnr}))
  else
    clients = vim.tbl_values(vim.lsp.get_clients())
  end

  vim.print(clients)
end

-- list all background jobs(channels)
__Debug.Get_all_jobs = function()
  vim.print(vim.api.nvim_list_chans())
end



