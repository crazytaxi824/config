local g = require('utils.my_term.deps.global')
local au_cb = require('utils.my_term.deps.autocmd_callback')
local t_win = require('utils.my_term.deps.term_win')
local console = require('utils.my_term.deps.exec_console')
local terminal = require('utils.my_term.deps.exec_terminal')
local keymaps  = require('utils.my_term.deps.term_keymaps')

--- deps functions --------------------------------------------------------------------------------- {{{

--- Create new terminal buffer and window, 给 my_term.bufnr 赋值.
---
---@param term_opts MyTermOpts
---@param old_term_bufnr? integer
---@return integer bufnr
---@return integer win_id
local function create_my_term_win(term_opts, old_term_bufnr)
  --- VVI: 以下执行顺序很重要!
  --- `jobstart(cmd, {opts})` 事件触发顺序和 `:edit term://cmd` 有所不同.
  --- `:edit term://cmd` 中: 触发顺序 TermOpen -> BufEnter -> BufWinEnter.
  --- `jobstart(cmd, {opts})` 触发顺序 BufEnter -> BufWinEnter -> TermOpen.
  ---
  --- NOTE: nvim_buf_call()
  --- 可以使用 nvim_buf_call(bufnr, function() jobstart(...) end) 做到 TermOpen -> BufEnter -> BufWinEnter 顺序,
  --- 但在 nvim_buf_call() 的过程中 TermOpen event 获取到的 window id 是临时的 autocmd window, 所以需要先创建一个
  --- window 然后 win_gotoid(win_id)

  --- 每次运行 jobstart() 之前, 先创建一个新的 scratch buffer 给 terminal.
  local term_bufnr = vim.api.nvim_create_buf(false, true)  -- nobuflisted scratch buffer

  vim.bo[term_bufnr].filetype = "my_term"  --- set filetype
  -- vim.b[term_bufnr]["my_term"] = term_opts.id  --- 设置 bufvar: {my_term = term_id}

  --- autocmd 放在这里运行主要是有两个限制条件:
  --- 1. 在获取到 terminal bufnr 之后运行, 为了在 autocmd 中使用 bufnr 作为触发条件.
  --- 2. 在 term window 打开并加载 term bufnr 之前运行, 为了触发 BufWinEnter event.
  au_cb.autocmd_callback(term_opts, term_bufnr)

  --- 快捷键设置: 在获取到 term.bufnr 和 term.id 之后运行.
  keymaps.set_buf_keymaps(term_opts, term_bufnr)

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
---@param term_opts MyTermOpts
---@param term_win_id integer
---@return integer job_id
local function my_term_exec(term_opts, term_bufnr, term_win_id)
  --- VVI: 必须在 bufnr 被 window 显示之后运行. 避免 nvim_buf_call() 生成一个临时 autocmd window.
  local job_id
  if term_opts.console_output then
    job_id = console.console_exec(term_opts, term_bufnr, term_win_id)
  else
    job_id = terminal.terminal_exec(term_opts, term_bufnr, term_win_id)
  end

  au_cb.autocmd_jobstop(term_opts, term_bufnr, job_id)

  --- VVI: 手动触发 BufEnter & BufWinEnter event
  --- doautocmd "BufEnter & BufWinEnter term://"
  --- 触发时机在 after TermOpen & before TermClose
  --- 先触发 BufEnter, 再触发 BufWinEnter
  vim.api.nvim_exec_autocmds({"BufEnter", "BufWinEnter"}, { buffer = term_bufnr })

  return job_id
end
-- }}}

--- my_term object
---@class MyTerm: MyTermOpts  继承 MyTermOpts
---@field bufnr integer  -- bufnr 在 :run() 过程中创建
---@field job_id integer  -- job_id 在 :run() 过程中创建
---
---以下是 MyTerm 方法, 放在 metatable 中防止被修改.
---@field run fun(self: MyTerm) @readonly
---@field stop fun(self: MyTerm) @readonly
---@field is_open fun(self: MyTerm): boolean @readonly
---@field open_win fun(self: MyTerm): integer|nil @readonly
---@field close_win fun(self: MyTerm) @readonly
---@field job_status fun(self: MyTerm): integer @readonly
---@field wipeout fun(self: MyTerm) @readonly
local M = {}

--- execute cmd with opts
function M:run()
  if self:job_status() == -1 then
    Notify("job_id is still running, please use `term:stop()` or `CTRL-C` first.", "WARN", {title="my_term"})
    return
  end

  --- executed before jobstart(). DO NOT have 'term.bufnr' and 'term.job_id' ...
  if self.before_run then
    self.before_run(self)
  end

  --- 创建 my term window and buffer, 创建 my_term.bufnr
  local term_bufnr, term_win_id = create_my_term_win(self)

  --- 执行 jobstart(cmd), 创建 my_term.job_id
  local job_id = my_term_exec(self, term_bufnr, term_win_id)

  --- executed after jobstart(). Have 'term.bufnr' and 'term.job_id' ...
  --- 和 on_exit 的区别是不用等到 jobdone.
  if self.after_run then
    self.after_run(self, term_bufnr)
  end

  --- NOTE: MyTermOpts -> MyTerm
  self.bufnr = term_bufnr
  self.job_id = job_id

  --- cache terminal object
  g.global_my_term_cache[self.id] = self
end

--- 终止 job, 会触发 jobdone.
function M:stop()
  if self.job_id then
    vim.fn.jobstop(self.job_id)
  end
end

--- is_open(). true: window is opened; false: window is closed.
function M:is_open()
  if g.term_buf_exist(self.bufnr) then
    local term_wins = vim.fn.getbufinfo(self.bufnr)[1].windows
    if #term_wins > 0 then
      return true
    end
  end
  return false
end

--- open terminal window or goto terminal window, return win_id
function M:open_win()
  if g.term_buf_exist(self.bufnr) then
    local term_wins = vim.fn.getbufinfo(self.bufnr)[1].windows
    if #term_wins > 0 then
      --- 如果有 window 正在显示该 term buffer, 则跳转到该 window.
      if vim.fn.win_gotoid(term_wins[1]) == 0 then
        error('vim cannot win_gotoid(' .. term_wins[1] .. ')')
      end

      return term_wins[1]
    else
      --- 如果没有任何 window 显示该 terminal 则创建一个新的 window, 然后加载该 buffer.
      return t_win.create_term_win(self.bufnr)
    end
  end
end

--- close all windows which displays this term buffer.
function M:close_win()
  if g.term_buf_exist(self.bufnr) then
    local term_wins = vim.fn.getbufinfo(self.bufnr)[1].windows
    for _, w in ipairs(term_wins) do
      vim.api.nvim_win_close(w, true)
    end
  end
end

--- 检查 terminal 运行情况.
function M:job_status()
  --- `:help jobwait()`
  return vim.fn.jobwait({self.job_id}, 0)[1]
end

--- wipeout term buffer.
function M:wipeout()
  if not g.term_buf_exist(self.bufnr) then
    return
  end

  --- VVI: 保险起见先 jobstop() 再 wipeout buffer, 否则 job 可能还在继续执行.
  vim.fn.jobstop(self.job_id)

  --- wipeout term buffer
  vim.api.nvim_buf_delete(self.bufnr, {force=true})

  --- clear term bufnr
  self.bufnr = nil
end

return M
