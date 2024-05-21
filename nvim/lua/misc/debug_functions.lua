--- list all LSP clients' info
function Get_LSP_Client_info_By_bufnr(bufnr)
  local clients
  if bufnr then
    clients = vim.tbl_values(vim.lsp.get_clients({bufnr = bufnr}))
  else
    clients = vim.tbl_values(vim.lsp.get_clients())
  end

  vim.print(clients)
end

--- list all background jobs(channels)
function Get_all_jobs()
  vim.print(vim.api.nvim_list_chans())
end



