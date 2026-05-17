local g = require('myplugins.my_term.deps.global')
local console = require('myplugins.my_term.deps.exec_console')
local terminal = require('myplugins.my_term.deps.exec_terminal')
local cb = require('myplugins.my_term.deps.autocmd_callback')
local t_win = require('myplugins.my_term.deps.term_win')
local t_key  = require('myplugins.my_term.term_keymaps')


--- @class MyTerm
---
--- VVI: 保证每个 id 只和一个 bufnr 对应. id 一旦设置应该无法改变.
--- @field id integer @readonly
---
--- @field private _opts MyTermInternalOpts @readonly
--- @field private _last_cmd? string|string[] @readonly
local MyTerm = {}
MyTerm.__index = MyTerm


--- jobstart(cmd, opts), 给 my_term.job_id 赋值.
---
--- @param cmd string|string[]
--- @param term MyTerm
--- @param term_bufnr integer
--- @param term_win_id integer
--- @return integer job_id
local function myterm_exec(cmd, term, term_bufnr, term_win_id)
  --- executed before jobstart(). DO NOT have 'term.bufnr' and 'term.job_id' ...
  local callbacks = term:before_run()
  if callbacks then
    for _, before_run in ipairs(callbacks) do
      before_run(term, term_bufnr)
    end
  end

  --- VVI: 必须在 bufnr 被 window 显示之后运行. 避免 nvim_buf_call() 生成一个临时 autocmd window.
  local job_id
  if term:console_output() then
    job_id = console.console_exec(cmd, term, term_bufnr, term_win_id)
  else
    job_id = terminal.terminal_exec(cmd, term, term_bufnr, term_win_id)
  end

  --- executed after jobstart(). Have 'term.bufnr' and 'term.job_id' ...
  --- 和 on_exit 的区别是不用等到 jobdone.
  callbacks = term:after_run()
  if callbacks then
    for _, after_run in ipairs(callbacks) do
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


--- @param id integer
--- @param opts MyTermOpts
--- @param force? 'force'
--- @return MyTerm
function MyTerm.new(id, opts, force)
  if not force then
    --- NOTE: terminal 已经存在, 无法使用相同 id 创建新的 terminal.
    if g.get_TermPost(id) then
      error('terminal id='.. id .. ' is already exist')
    end
  end

  --- @type MyTerm
  local self = setmetatable({
    id = id,
    _opts = init_opts(opts),
  }, MyTerm)

  return self
end


--- `:help jobstart-options` cwd
--- @return string|nil
function MyTerm:cwd() return self._opts.cwd end

--- `:help jobstart-options` cwd
--- @return string|nil
function MyTerm:env() return self._opts.env end

--- `true`: 在 console 中执行; `false`: 在 terminal 中执行
--- @return boolean|nil
function MyTerm:auto_scroll() return self._opts.auto_scroll end

--- `true`: 在 console 中执行; `false`: 在 terminal 中执行.
--- @return boolean|nil
function MyTerm:console_output() return self._opts.console_output end

--- term:run() 时触发. before jobstart().
--- @return MyTermCallback[]|nil
function MyTerm:before_run() return self._opts.before_run end

--- term:run() 时触发. 在 jobstart() 之后马上执行, 和 on_exit 的区别是不用等到 jobdone.
--- @return MyTermCBWithJob[]|nil
function MyTerm:after_run() return self._opts.after_run end

--- BufWinEnter. NOTE: 每次 term:// buffer 被 win 显示的时候都会触发, 同一个 buffer 被多个窗口显示时也会触发.
--- @return MyTermCallback[]|nil
function MyTerm:on_open() return self._opts.on_open end

--- BufWinLeave. NOTE: BufWinLeave 只会在 buffer 离开最后一个 win 的时候触发.
--- @return MyTermCallback[]|nil
function MyTerm:on_close() return self._opts.on_close end

--- jobstart() 中 callback 函数
--- @return MyTermOnOutput[]|nil
function MyTerm:on_stdout() return self._opts.on_stdout end

--- jobstart() 中 callback 函数
--- @return MyTermOnOutput[]|nil
function MyTerm:on_stderr() return self._opts.on_stderr end

--- jobstart() 中 callback 函数
--- @return MyTermOnExit[]|nil
function MyTerm:on_exit() return self._opts.on_exit end


--- update MyTerm options
---
--- @param new_opts MyTermOpts
--- @param cb_mode? 'append'|'replace'
function MyTerm:update(new_opts, cb_mode)
  cb_mode = cb_mode or 'append'

  for key, value in pairs(new_opts) do
    if type(value) == "function" then
      --- 如果 opts 是 function 则 append/replace callback list
      if cb_mode == 'append' and self._opts[key] then
        table.insert(self._opts[key] or {}, value)
      else
        self._opts[key] = { value }
      end
    else
      --- 如果 opts 是 props (k,v) 则直接替换
      self._opts[key] = value
    end
  end
end

--- jobstart(cmd)
---
--- @param cmd? string|string[]
function MyTerm:run(cmd)
  cmd = cmd or self._last_cmd
  if not cmd then
    vim.notify("no 'cmd' for my_term", vim.log.levels.WARN)
    return
  elseif type(cmd) == 'string' then
    vim.notify("myterm:run() -> jobstart() `cmd` is string, need vim.fn.shellescape(filepath)", vim.log.levels.WARN)
  end

  --- 检查 job 是否正在运行
  local tp = g.get_TermPost(self.id)
  if tp and tp:job_status() == -1 then
    Notify("job_id is still running, please use `term:stop()` or `CTRL-C` first.", "WARN", {title="my_term"})
    return
  end

  --- cache last cmd
  self._last_cmd = cmd

  --- 创建并进入 term window & buffer
  local term_bufnr, term_win_id = t_win.set_myterm_current_win(self)

  --- 快捷键设置: 在获取到 term.bufnr 和 term.id 之后运行
  t_key.set_buf_keymaps(self, term_bufnr)

  --- VVI(jobstart): 执行 cmd
  local job_id = myterm_exec(cmd, self, term_bufnr, term_win_id)

  --- buffer 被 wipeout 的时候自动 jobstop()
  cb.autocmd_jobstop(self, term_bufnr, job_id)

  --- VVI(require module): 延迟 require() 防止循环引用
  tp = require('myplugins.my_term.myterm_post').from(self, term_bufnr, job_id)
  g.set_TermPost(tp.id, tp)  -- cache MyTermPost
end

--- jobstop(job_id)
function MyTerm:stop()
  local tp = g.get_TermPost(self.id)
  if tp then
    vim.fn.jobstop(tp.job_id)
  end
end


return MyTerm
