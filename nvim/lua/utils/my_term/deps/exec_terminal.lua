local auto_scroll = require('utils.my_term.deps.auto_scroll')

local M = {}

--- 在 buffer 中执行 jobstart(cmd). (buftype = 'terminal')
--- 主要区别是 `:help jobstart-options` { term = true } 将当前 buffer 转成 terminal buffer 用于显示 output.
---
--- @param term_opts MyTermOpts
--- @param term_bufnr integer
--- @param term_win_id integer
--- @return integer job_id
function M.terminal_exec(term_opts, term_bufnr, term_win_id)
  if vim.api.nvim_win_get_buf(term_win_id) ~= term_bufnr then
    error("MyTerm win_id and bufnr do not match")
  end

  if not term_opts.cmd then
    error("MyTerm.cmd is missing")
  end

  --- VVI: terminal 不能改 bufname 否则会重新创建一个新的 terminal.
  --- VVI: 使用 nvim_buf_call() 时 bufnr 必须被某一个 window 显示, 否则 vim 会创建一个看不见的临时 autocmd window
  --- 用于执行 function. 导致 TermOpen event 中获取的 win id 是这个临时 window, 会造成一些 bug.
  return vim.api.nvim_buf_call(term_bufnr, function()
    return vim.fn.jobstart(term_opts.cmd, {
      term = true,  -- VVI: 将 output 结果输出到 bufnr
      cwd = term_opts.cwd,
      env = term_opts.env,

      --- @param job_id integer
      --- @param data string[]  output
      --- @param event string  'stdout'
      on_stdout = function(job_id, data, event)  -- event 是 'stdout'
        --- auto_scroll option
        auto_scroll.buf_scroll_bottom(term_opts, term_bufnr)

        --- callback
        if term_opts.on_stdout then
          term_opts.on_stdout(term_opts, term_bufnr, job_id, data)
        end
      end,

      --- @param job_id integer
      --- @param data string[]  err_msg
      --- @param event string  'stderr'
      on_stderr = function(job_id, data, event)  -- event 是 'stderr'
        --- auto_scroll option
        auto_scroll.buf_scroll_bottom(term_opts, term_bufnr)

        --- callback
        if term_opts.on_stderr then
          term_opts.on_stderr(term_opts, term_bufnr, job_id, data)
        end
      end,

      --- @param job_id integer
      --- @param exit_code integer
      --- @param event string  'exit'
      on_exit = function(job_id, exit_code, event)  -- event 是 'exit'
        --- callback
        if term_opts.on_exit then
          term_opts.on_exit(term_opts, term_bufnr, job_id, exit_code)
        end
      end,
    })
  end)
end

return M
