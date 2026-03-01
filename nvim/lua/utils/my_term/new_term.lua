local g = require('utils.my_term.deps.global')
local console = require('utils.my_term.deps.exec_console')
local terminal = require('utils.my_term.deps.exec_terminal')
local cb = require('utils.my_term.deps.autocmd_callback')
local t_win = require('utils.my_term.deps.term_win')
local t_act = require('utils.my_term.term_actions')
local t_key  = require('utils.my_term.term_keymaps')

--- jobstart(cmd, opts), 给 my_term.job_id 赋值.
---
--- @param term MyTerm
--- @param term_bufnr integer
--- @param term_win_id integer
--- @return integer job_id
local function my_term_exec(term, term_bufnr, term_win_id)
  --- autocmd 放在这里运行主要是有两个限制条件:
  --- 1. 在获取到 terminal bufnr 之后运行, 为了在 autocmd 中使用 bufnr 作为触发条件.
  --- 2. 在 term window 打开并加载 term bufnr 之前运行, 为了触发 BufWinEnter event.
  cb.autocmd_callback(term, term_bufnr)  -- FIXME: before nvim_win_set_buf() 才能触发 on_open

  --- executed before jobstart(). DO NOT have 'term.bufnr' and 'term.job_id' ...
  if term.before_run then
    term.before_run(term)  -- TODO: add bufnr
  end

  --- VVI: 必须在 bufnr 被 window 显示之后运行. 避免 nvim_buf_call() 生成一个临时 autocmd window.
  local job_id
  if term.console_output then
    job_id = console.console_exec(term, term_bufnr, term_win_id)
  else
    job_id = terminal.terminal_exec(term, term_bufnr, term_win_id)
  end

  --- executed after jobstart(). Have 'term.bufnr' and 'term.job_id' ...
  --- 和 on_exit 的区别是不用等到 jobdone.
  if term.after_run then
    term.after_run(term, term_bufnr)  -- TODO: add job_id
  end

  --- buffer 被 wipeout 的时候自动 jobstop()
  cb.autocmd_jobstop(term, term_bufnr, job_id)

  return job_id
end


local M = {}


--- new MyTerm object
---
--- @param id integer
--- @param opts MyTermOpts
--- @param force? 'force'
--- @return MyTerm
function M._new(id, opts, force)
  if not force then
    --- NOTE: terminal 已经存在, 无法使用相同 id 创建新的 terminal.
    if g.get_TermPost(id) then
      error('terminal id='.. id .. ' is already exist')
    end
  end

  --- @type MyTerm
  local my_term = {
    id = id,

    --- @param self MyTerm
    run = function(self)
      if t_act.job_status(self.id) == -1 then
        Notify("job_id is still running, please use `term:stop()` or `CTRL-C` first.", "WARN", {title="my_term"})
        return
      end

      --- 创建 term window & buffer
      local term_bufnr, term_win_id = t_win.create_my_term_win(self)  -- TODO: rename function

      --- 快捷键设置: 在获取到 term.bufnr 和 term.id 之后运行.
      t_key.set_buf_keymaps(self, term_bufnr)

      --- VVI(jobstart): 执行 cmd
      local job_id = my_term_exec(self, term_bufnr, term_win_id)

      --- NOTE: cache MyTermPost
      --- @type MyTermPost
      local tp = vim.tbl_deep_extend('keep', {bufnr = term_bufnr, job_id = job_id}, self)
      g.set_TermPost(tp.id, tp)
    end,

    stop = function(self)
      local tp = g.get_TermPost(self.id)
      if tp then
        vim.fn.jobstop(tp.job_id)
      end
    end,
  }

  return vim.tbl_deep_extend('force', my_term, opts)
end


return M
