local Terminal = require("toggleterm.terminal").Terminal

local M = {}

M.exec_float_term = Terminal:new({
  count = 2001,
  hidden = true,
  direction = "float",
  close_on_exit = false,
  auto_scroll = false,  -- automatically scroll to the bottom on terminal output.
})

M.exec = function(cmd)
  -- local fp = vim.fn.expand('%')
  -- local func = vim.fn.expand('<cword>')

  --- `gotests -only Foo /xxx/src/foo.go`
  -- local cmd = 'gotests -only ' .. func .. ' ' .. fp

  --- 删除之前的 terminal, 同时终止 job.
  --- NOTE: 这一步放在 cmd 生成的后面, 防止 shutdown() 导致 buffer 意外改变.
  M.exec_float_term:shutdown()

  M.exec_float_term.on_open = function()
    vim.cmd('stopinsert')
  end

  --- 设置 cmd
  vim.notify(cmd)
  M.exec_float_term.cmd = cmd

  --- run cmd
  M.exec_float_term:open()
end

return M
