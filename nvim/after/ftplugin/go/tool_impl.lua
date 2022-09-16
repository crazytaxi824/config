--- command! -buffer -nargs=1 GoImpl :lua _GoImpl(<f-args>)
vim.api.nvim_buf_create_user_command(
  0,
  "GoImpl",
  function(params)
    require("user.ftplugin_tools.go").go_impl(params.fargs)
  end,
  {bang=true, nargs="+"}
)



