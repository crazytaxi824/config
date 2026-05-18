local utils = require('myplugins.my_term.deps.utils')


local M = {}

--- 在 buffer 中执行 jobstart(cmd). (buftype = 'terminal')
--- 主要区别是 `:help jobstart-options` { term = true } 将当前 buffer 转成 terminal buffer 用于显示 output.
---
--- @param cmd string|string[]
--- @param term MyTerm
--- @param term_bufnr integer
--- @param term_win_id integer
--- @return integer job_id
function M.terminal_exec(cmd, term, term_bufnr, term_win_id)
  if vim.api.nvim_win_get_buf(term_win_id) ~= term_bufnr then
    error("MyTerm win_id and bufnr do not match")
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
    local job_id = vim.fn.jobstart(cmd, {
      term = true,  -- VVI: 将 output 结果输出到 bufnr
      cwd = term:cwd(),
      env = term:env(),

      --- @param job_id integer
      --- @param data string[]  output
      --- @param event string  'stdout'
      on_stdout = function(job_id, data, event)  -- event 是 'stdout'
        --- auto_scroll option
        utils.buf_scroll_bottom(term, term_bufnr)

        --- callback
        local callbacks = term:on_stdout()
        if callbacks then
          for _, on_stdout in ipairs(callbacks) do
            on_stdout(term, term_bufnr, job_id, data)
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
        local callbacks = term:on_stderr()
        if callbacks then
          for _, on_stderr in ipairs(callbacks) do
            on_stderr(term, term_bufnr, job_id, data)
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
        local callbacks = term:on_exit()
        if callbacks then
          for _, on_exit in ipairs(callbacks) do
            on_exit(term, term_bufnr, job_id, exit_code)
          end
        end
      end,
    })

    if job_id <= 0 then
      error("jobstart failed: " .. vim.inspect(cmd))
    end

    return job_id
  end)
end

return M
