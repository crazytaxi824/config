if __Debug_Neovim.autocmd then
  local common_events = {
    "VimEnter", "VimLeave",
    "BufAdd", "BufNew", "BufNewFile",
    "BufEnter", "BufLeave",
    "BufReadPre", "BufReadPost", "BufWritePre", "BufWritePost", "BufFilePre", "BufFilePost",
    "BufDelete", "BufUnload", "BufWipeout",
    "BufWinEnter", "BufWinLeave",
    "WinNew", "WinEnter", "WinLeave",
    "FileType",
  }

  vim.api.nvim_create_autocmd(common_events, {
    pattern = {"*"},
    -- once = true,
    callback = function(params)
      print(params.event)
    end
  })
end



