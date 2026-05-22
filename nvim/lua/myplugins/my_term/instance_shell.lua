local g = require('myplugins.my_term.deps.global')
local mt = require('myplugins.my_term.myterm')


--- source Python Virtual Environment
---
--- @param term_id integer
local function python_env(term_id)
  --- 返回 MyTermPost.job_id
  local tp = g.get_TermPost(term_id)
  if not tp then return end

  local py_venv = vim.fs.find({ '.venv/bin/activate' }, {
    upward = true,
    stop = vim.env.HOME,
    type = "file",
    limit = 1,
  })
  if #py_venv < 1 then
    return
  end

  --- NOTE: chansend 和 nvim_chan_send 是模拟键盘操作, 所以不能使用 shellescape(), 否则报错
  local cmd = string.format("source %q && clear\n", py_venv[1])
  -- vim.fn.chansend(job_id, cmd)
  vim.api.nvim_chan_send(tp.job_id, cmd)
end


local M = {}

--- open shell terminal
function M.open_shell_term()
  if vim.v.count1 > 999 then
    Notify("my_term id should be 1~999 in this method", "INFO")
    return
  end

  local tp = g.get_TermPost(vim.v.count1)
  if tp then
    --- open & enter window
    if not tp:open_win() then
      error('cached my_term has No bufnr')
    end
    return
  end

  --- terminal 没有被缓存则 M.new()
  local t = mt.new(vim.v.count1, {
    on_init = function(term, term_bufnr)
      vim.schedule(function()
        --- on_init 的时候 cursor 在 terminal window 中则执行 startinsert.
        if vim.api.nvim_get_current_buf() == term_bufnr then
          vim.cmd.startinsert()
        end

        --- source Python Virtual Environment
        python_env(term.id)
      end)
    end,

    on_exit = function(_, term_bufnr)
      --- 在 jobdone (exit) 的时候 :bwipeout terminal buffer
      if vim.api.nvim_buf_is_valid(term_bufnr) then
        vim.api.nvim_buf_delete(term_bufnr, {force=true})  -- :bwipeout
      end
    end,
  })

  t:run({ vim.go.shell })  -- `:help 'shell'`, 相当于 os.getenv('SHELL'), vim.env.SHELL
end

return M
