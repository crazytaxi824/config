--- https://ericlathrop.com/2024/02/configuring-neovim-s-lsp-to-work-with-godot/
--- start a pipe for "neovim to talk to Godot's built-in language server."
local pipepath = vim.fn.stdpath("cache") .. "/server.pipe"
if not vim.uv.fs_stat(pipepath) then
  --- Opens a socket or named pipe
  vim.fn.serverstart(pipepath)
end

return {}
