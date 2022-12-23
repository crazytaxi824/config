local Terminal = require("toggleterm.terminal").Terminal
local goto_win = require("user.utils.term.goto_winid")

local M = {}

--- toggleterm 实例
---   term:clear()     清除 term 设置.
---   term:close()     关闭窗口, NOTE: 只能关闭 :open() 打开的窗口.
---   term:open()      打开窗口, 如果 term 不存在则运行 job.
---   term:toggle()    相当于 close() / open(), 如果 term 不存在则运行 job.
---   term:shutdown()  NOTE: exit terminal. 终止 terminal job, 然后关闭 term 窗口.

--- NOTE: execute: golang / javascript / typescript / python ...
M.exec_bot_term = Terminal:new({
  --- NOTE: count 在 term job end 之后可以被新的 term 使用, :ls! 中可以看到两个相同 count 的 buffer.
  --- 但是如果有相同 count 的 term job 还未结束时, 新的 term 无法运行.
  count = 1001,

  --- job done 之后会自动关闭 terminal window, 无法查看运行结果.
  close_on_exit = false,
})

--- callback 在 on_exit = func() 的时候执行.
M.exec = function(cmd, on_exit_fn)
  --- 删除之前的 terminal, 同时终止 job.
  M.exec_bot_term:shutdown()

  --- 缓存执行 _Exec() 的 window id
  local exec_win_id = vim.api.nvim_get_current_win()

  --- 该 terminal buffer wipeout 的时候回到之前的窗口.
  M.exec_bot_term.on_open = goto_win.fn(exec_win_id, "stopinsert")

  --- NOTE: callback 不存在的时候 on_exit 就会清除, 相当于: on_exit = nil
  M.exec_bot_term.on_exit = on_exit_fn

  --- 设置 cmd
  M.exec_bot_term.cmd = 'echo -e "\\e[32m' .. vim.fn.escape(cmd,'"') .. ' \\e[0m" && ' .. cmd

  --- run cmd
  M.exec_bot_term:open()
end

--- 重新执行 last cmd
M.exec_last_cmd = function()
  if not M.exec_bot_term.cmd then
    Notify("no Command has been Executed", "Info")
    return
  end

  --- 删除之前的 terminal, 同时终止 job.
  M.exec_bot_term:shutdown()

  --- re-run last cmd.
  --- NOTE: 这里因为没有改变 exec_term 中的任何设置,
  --- 所以 open() 的时候, 会运行上一次记录在 cmd 中的命令.
  M.exec_bot_term:open()
end

return M
