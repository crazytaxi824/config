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
local function myterm_exec(term, term_bufnr, term_win_id)
  --- executed before jobstart(). DO NOT have 'term.bufnr' and 'term.job_id' ...
  if term._opts.before_run then
    for _, before_run in ipairs(term._opts.before_run) do
      before_run(term, term_bufnr)
    end
  end

  --- VVI: 必须在 bufnr 被 window 显示之后运行. 避免 nvim_buf_call() 生成一个临时 autocmd window.
  local job_id
  if term._opts.console_output then
    job_id = console.console_exec(term, term_bufnr, term_win_id)
  else
    job_id = terminal.terminal_exec(term, term_bufnr, term_win_id)
  end

  --- executed after jobstart(). Have 'term.bufnr' and 'term.job_id' ...
  --- 和 on_exit 的区别是不用等到 jobdone.
  if term._opts.after_run then
    for _, after_run in ipairs(term._opts.after_run) do
      after_run(term, term_bufnr, job_id)
    end
  end

  return job_id
end

--- MyTermOpts -> MyTermInternalOpts
---
--- @param opts any
--- @return MyTermInternalOpts
local function init_opts(opts)
  local internal = {}
  for key, value in pairs(opts) do
    if type(value) == "function" then
      internal[key] = { value }
    else
      internal[key] = value
    end
  end
  return internal
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
    _opts = init_opts(opts),

    update = function(self, new_opts, cb_mode)
      cb_mode = cb_mode or 'append'
      for key, value in pairs(new_opts) do
        if type(value) == "function" then
          --- MyTermOptsCallbackList
          if cb_mode == 'append' and self._opts[key] then
            table.insert(self._opts[key] or {}, value)
          else
            self._opts[key] = { value }
          end
        else
          --- MyTermOptsProps
          self._opts[key] = value
        end
      end
    end,

    --- @param self MyTerm
    run = function(self)
      if t_act.job_status(self.id) == -1 then
        Notify("job_id is still running, please use `term:stop()` or `CTRL-C` first.", "WARN", {title="my_term"})
        return
      end

      --- 创建并进入 term window & buffer
      local term_bufnr, term_win_id = t_win.set_myterm_current_win(self)

      --- 快捷键设置: 在获取到 term.bufnr 和 term.id 之后运行
      t_key.set_buf_keymaps(self, term_bufnr)

      --- VVI(jobstart): 执行 cmd
      local job_id = myterm_exec(self, term_bufnr, term_win_id)

      --- buffer 被 wipeout 的时候自动 jobstop()
      cb.autocmd_jobstop(self, term_bufnr, job_id)

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

  return my_term
end


return M
