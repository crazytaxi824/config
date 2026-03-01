local g = require('utils.my_term.deps.global')
local console = require('utils.my_term.deps.exec_console')
local terminal = require('utils.my_term.deps.exec_terminal')
local cb = require('utils.my_term.deps.autocmd_callback')
local t_win = require('utils.my_term.deps.term_win')
local t_act = require('utils.my_term.term_actions')
local t_key  = require('utils.my_term.term_keymaps')

--- deps functions --------------------------------------------------------------------------------- {{{

--- Create new terminal buffer and window, 给 my_term.bufnr 赋值.
---
--- @param term MyTerm
--- @return integer bufnr
--- @return integer win_id
local function create_my_term_win(term)
  --- VVI: 以下执行顺序很重要!
  --- `jobstart(cmd, {opts})` 事件触发顺序和 `:edit term://cmd` 有所不同.
  --- `:edit term://cmd` 中: 触发顺序 TermOpen -> BufEnter -> BufWinEnter.
  --- `jobstart(cmd, {opts})` 触发顺序 BufEnter -> BufWinEnter -> TermOpen.
  ---
  --- NOTE: nvim_buf_call()
  --- 可以使用 nvim_buf_call(bufnr, function() jobstart(...) end) 做到 TermOpen -> BufEnter -> BufWinEnter 顺序,
  --- 但在 nvim_buf_call() 的过程中 TermOpen event 获取到的 window id 是临时的 autocmd window, 所以需要先创建一个
  --- window 然后 win_gotoid(win_id)

  --- 获取是否已经 run() 并用于 term_bufnr
  local old_term_bufnr
  local tp = g.get_TermPost(term.id)
  if tp then
    old_term_bufnr = tp.bufnr
  end

  --- 每次运行 jobstart() 之前, 先创建一个新的 scratch buffer 给 terminal.
  local term_bufnr = vim.api.nvim_create_buf(false, true)  -- nobuflisted scratch buffer

  vim.bo[term_bufnr].filetype = "my_term"  --- set filetype
  -- vim.b[term_bufnr]["my_term"] = term.id  --- 设置 bufvar: {my_term = term_id}

  --- autocmd 放在这里运行主要是有两个限制条件:
  --- 1. 在获取到 terminal bufnr 之后运行, 为了在 autocmd 中使用 bufnr 作为触发条件.
  --- 2. 在 term window 打开并加载 term bufnr 之前运行, 为了触发 BufWinEnter event.
  cb.autocmd_callback(term, term_bufnr)

  --- 快捷键设置: 在获取到 term.bufnr 和 term.id 之后运行.
  t_key.set_buf_keymaps(term, term_bufnr)

  --- 进入一个选定的 term window 加载现有 term buffer, 同时 wipeout old_term_bufnr.
  local term_win_id = t_win.enter_term_win(term_bufnr, old_term_bufnr)

  --- 设置 term win 属性
  local scope={ scope='local', win=term_win_id }
  vim.api.nvim_set_option_value('sidescrolloff', 0, scope)
  vim.api.nvim_set_option_value('scrolloff', 0, scope)

  return term_bufnr, term_win_id
end

--- jobstart(cmd, opts), 给 my_term.job_id 赋值.
---
--- @param term MyTerm
--- @param term_bufnr integer
--- @param term_win_id integer
--- @return integer job_id
local function my_term_exec(term, term_bufnr, term_win_id)
  --- VVI: 必须在 bufnr 被 window 显示之后运行. 避免 nvim_buf_call() 生成一个临时 autocmd window.
  local job_id
  if term.console_output then
    job_id = console.console_exec(term, term_bufnr, term_win_id)
  else
    job_id = terminal.terminal_exec(term, term_bufnr, term_win_id)
  end

  --- buffer 被 wipeout 的时候自动 jobstop()
  cb.autocmd_jobstop(term, term_bufnr, job_id)

  --- VVI: 手动触发 BufEnter & BufWinEnter event
  --- doautocmd "BufEnter & BufWinEnter term://"
  --- 触发时机在 after TermOpen & before TermClose
  --- 先触发 BufEnter, 再触发 BufWinEnter
  vim.api.nvim_exec_autocmds({"BufEnter", "BufWinEnter"}, { buffer = term_bufnr })

  return job_id
end
-- }}}


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

      --- executed before jobstart(). DO NOT have 'term.bufnr' and 'term.job_id' ...
      if self.before_run then
        self.before_run(self)
      end

      --- 创建 term window & buffer
      local term_bufnr, term_win_id = create_my_term_win(self)

      --- 执行 jobstart(cmd)
      local job_id = my_term_exec(self, term_bufnr, term_win_id)

      --- executed after jobstart(). Have 'term.bufnr' and 'term.job_id' ...
      --- 和 on_exit 的区别是不用等到 jobdone.
      if self.after_run then
        self.after_run(self, term_bufnr)
      end

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
