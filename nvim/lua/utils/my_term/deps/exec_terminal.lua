local auto_scroll = require('utils.my_term.deps.auto_scroll')

local M = {}

--- 在 buffer 中执行 jobstart(cmd). (buftype = 'terminal')
--- 主要区别是 `:help jobstart-options` { term = true } 将当前 buffer 转成 terminal buffer 用于显示 output.
---
---@param term_obj MyTerm
---@param term_win_id integer
function M.terminal_exec(term_obj, term_win_id)
  if vim.api.nvim_win_get_buf(term_win_id) ~= term_obj.bufnr then
    return
  end

  if not term_obj.cmd then
    error("MyTerm.cmd is missing")
  end

  --- VVI: terminal 不能改 bufname 否则会重新创建一个新的 terminal.
  --- VVI: 使用 nvim_buf_call() 时 bufnr 必须被某一个 window 显示, 否则 vim 会创建一个看不见的临时 autocmd window
  --- 用于执行 function. 导致 TermOpen event 中获取的 win id 是这个临时 window, 会造成一些 bug.
  vim.api.nvim_buf_call(term_obj.bufnr, function()
    term_obj.job_id = vim.fn.jobstart(term_obj.cmd, {
      term = true,  -- VVI: 将 output 结果输出到 term_obj.bufnr
      cwd = term_obj.cwd,
      env = term_obj.env,

      on_stdout = function(job_id, data, event)  -- event 是 'stdout'
        --- auto_scroll option
        auto_scroll.buf_scroll_bottom(term_obj)

        --- callback
        if term_obj.on_stdout then
          term_obj.on_stdout(term_obj, job_id, data, event)
        end
      end,

      on_stderr = function(job_id, data, event)  -- event 是 'stderr'
        --- auto_scroll option
        auto_scroll.buf_scroll_bottom(term_obj)

        --- callback
        if term_obj.on_stderr then
          term_obj.on_stderr(term_obj, job_id, data, event)
        end
      end,

      on_exit = function(job_id, exit_code, event)  -- event 是 'exit'
        --- callback
        if term_obj.on_exit then
          term_obj.on_exit(term_obj, job_id, exit_code, event)
        end
      end,
    })
  end)
end

return M
