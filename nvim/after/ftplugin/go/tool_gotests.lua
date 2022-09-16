-- command! -buffer -nargs=0 GoTests :lua _GoTests()
vim.api.nvim_buf_create_user_command(
  0,          -- bufnr = 0 表示 current buffer.
  "GoTestsGenerator",  -- command name
  require("user.ftplugin_tools.go").gotests_cmd_tool,    -- 使用 vim.api 方法的好处是可以使用 local lua function
  {bang = true, bar = true}  -- options: {bang = true, nargs = "+"}
)



