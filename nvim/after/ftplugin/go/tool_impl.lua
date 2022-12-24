--- command! -buffer -nargs=1 GoImpl :lua _GoImpl(<f-args>)
vim.api.nvim_buf_create_user_command(
  0,
  "GoImpl",
  function(params) require("user.utils.go").tool.impl(params.fargs) end,
  {bang=true, nargs="+"}
)



