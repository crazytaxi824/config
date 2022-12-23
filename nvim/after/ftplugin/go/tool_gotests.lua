--- command! -buffer -nargs=0 GoTests :lua _GoTests()
vim.api.nvim_buf_create_user_command(
  0,          -- bufnr = 0 表示 current buffer.
  "GoTestsGenerator",  -- command name
  function() require("user.ftplugin_deps.go").tool.gotests() end,
  {bang = true, bar = true}  -- options: {bang = true, nargs = "+"}
)



