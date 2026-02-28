local g = require('utils.my_term.deps.global')
local t_act = require('utils.my_term.term_actions')
local new_mt = require('utils.my_term.new_term')


--- source Python Virtual Environment
---
--- @param term_id integer
local function python_env(term_id)
  local py_venv = vim.fs.find({ '.venv/bin/activate' }, {
    upward = true,
    stop = vim.env.HOME,
    type = "file",
  })
  if #py_venv < 1 then
    return
  end

  --- 返回 MyTermPost.job_id
  local job_id = g.get_job_id(term_id)
  if not job_id then
    error("no job_id after run()")
  end

  -- vim.fn.chansend(job_id, 'source ' .. py_venv[1] .. ' && clear\n')
  vim.api.nvim_chan_send(job_id, 'source ' .. py_venv[1] .. ' && clear\n')
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
    if not t_act.open_win(tp.id) then
      error('cached my_term has No bufnr')
    end
    return
  end

  --- terminal 没有被缓存则 M.new()
  local t = new_mt._new({
    id = vim.v.count1,
    cmd = vim.go.shell,  -- `:help 'shell'`, 相当于 os.getenv('SHELL'), vim.env.SHELL
    after_run = function(_, term_bufnr)
      --- after_run 的时候 cursor 在 terminal window 中则执行 stopinsert.
      if vim.api.nvim_win_get_buf(vim.api.nvim_get_current_win()) == term_bufnr then
        vim.cmd.startinsert()
      end
    end,
    on_exit = function(_, term_bufnr)
      --- VVI: 手动 :bw 删除 buffer 时会触发 TermClose, 导致重复 wipeout buffer 而报错.
      if vim.api.nvim_buf_is_valid(term_bufnr) then
        vim.api.nvim_buf_delete(term_bufnr, {force=true})
      end

      --- NOTE: jobdone 的时候 cursor 在 terminal window 中则执行 stopinsert.
      -- if vim.api.nvim_win_get_buf(vim.api.nvim_get_current_win()) == term_bufnr then
      --   vim.cmd.stopinsert()
      -- end
    end,
  })
  t:run()

  --- source Python Virtual Environment
  python_env(t.id)
end

return M
