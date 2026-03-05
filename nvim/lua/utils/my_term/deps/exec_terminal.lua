local utils = require('utils.my_term.deps.utils')

local M = {}

--- 在 buffer 中执行 jobstart(cmd). (buftype = 'terminal')
--- 主要区别是 `:help jobstart-options` { term = true } 将当前 buffer 转成 terminal buffer 用于显示 output.
---
--- @param term MyTerm
--- @param term_bufnr integer
--- @param term_win_id integer
--- @return integer job_id
function M.terminal_exec(term, term_bufnr, term_win_id)
  if vim.api.nvim_win_get_buf(term_win_id) ~= term_bufnr then
    error("MyTerm win_id and bufnr do not match")
  end

  if not term._opts.cmd then
    error("MyTerm.cmd is missing")
  end

  --- VVI: terminal 不能改 bufname 否则会重新创建一个新的 terminal.
  --- VVI: 使用 nvim_buf_call() 时 bufnr 必须被某一个 window 显示, 否则 vim 会创建一个看不见的临时 autocmd window
  --- 用于执行 function. 导致 TermOpen event 中获取的 win id 是这个临时 window, 会造成一些 bug.
  ---
  --- DOCS: `:help nvim_buf_call()`, If the current
  --- window already shows "buffer", the window is not switched. If a window
  --- inside the current tabpage (including a float) already shows the buffer,
  --- then one of those windows will be set as current window temporarily.
  --- Otherwise a temporary scratch window (called the "autocmd window" for
  --- historical reasons) will be used.
  return vim.api.nvim_buf_call(term_bufnr, function()
    return vim.fn.jobstart(term._opts.cmd, {
      term = true,  -- VVI: 将 output 结果输出到 bufnr
      cwd = term._opts.cwd,
      env = term._opts.env,

      --- @param job_id integer
      --- @param data string[]  output
      --- @param event string  'stdout'
      on_stdout = function(job_id, data, event)  -- event 是 'stdout'
        --- auto_scroll option
        utils.buf_scroll_bottom(term, term_bufnr)

        --- callback
        if term._opts.on_stdout then
          for _, on_stdout in ipairs(term._opts.on_stdout) do
            on_stdout(term, term_bufnr, job_id, data)
          end

          --- 防止 term buffer 在执行过程中被 wipeout 造成的 error.
          if not vim.api.nvim_buf_is_valid(term_bufnr) then
            error("should not delete terminal buffer")
          end
        end
      end,

      --- @param job_id integer
      --- @param data string[]  err_msg
      --- @param event string  'stderr'
      on_stderr = function(job_id, data, event)  -- event 是 'stderr'
        --- auto_scroll option
        utils.buf_scroll_bottom(term, term_bufnr)

        --- callback
        if term._opts.on_stderr then
          for _, on_stderr in ipairs(term._opts.on_stderr) do
            on_stderr(term, term_bufnr, job_id, data)
          end

          --- 防止 term buffer 在执行过程中被 wipeout 造成的 error.
          if not vim.api.nvim_buf_is_valid(term_bufnr) then
            error("should not delete terminal buffer")
          end
        end
      end,

      --- @param job_id integer
      --- @param exit_code integer
      --- @param event string  'exit'
      on_exit = function(job_id, exit_code, event)  -- event 是 'exit'
        --- auto_scroll option
        utils.buf_scroll_bottom(term, term_bufnr)

        --- callback
        if term._opts.on_exit then
          for _, on_exit in ipairs(term._opts.on_exit) do
            on_exit(term, term_bufnr, job_id, exit_code)
          end
        end
      end,
    })
  end)
end

return M
