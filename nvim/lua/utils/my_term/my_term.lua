local g = require('utils.my_term.deps.global')
local au_cb = require('utils.my_term.deps.autocmd_callback')
local t_win = require('utils.my_term.deps.term_win')
local console = require('utils.my_term.deps.exec_console')
local terminal = require('utils.my_term.deps.exec_terminal')
local keymaps  = require('utils.my_term.deps.term_keymaps')

--- my_term object
---@class MyTerm: MyTermOpts  继承 MyTermOpts
---@field bufnr integer
---@field job_id integer
---
---以下是 MyTerm 方法, 放在 metatable 中防止被修改.
---@field run fun(self: MyTerm)
---@field stop fun(self: MyTerm)
---@field is_open fun(self: MyTerm)
---@field open_win fun(self: MyTerm)
---@field close_win fun(self: MyTerm)
---@field job_status fun(self: MyTerm)
---@field wipeout fun(self: MyTerm)
local M = {}

M.bufvar_myterm = "my_term"

--- Create new terminal ----------------------------------------------------------------------------
--- VVI: 以下执行顺序很重要!
--- `jobstart(cmd, {opts})` 事件触发顺序和 `:edit term://cmd` 有所不同.
--- `:edit term://cmd` 中: 触发顺序 TermOpen -> BufEnter -> BufWinEnter.
--- `jobstart(cmd, {opts})` 触发顺序 BufEnter -> BufWinEnter -> TermOpen.
---
--- NOTE: nvim_buf_call()
--- 可以使用 nvim_buf_call(bufnr, function() jobstart(...) end) 做到 TermOpen -> BufEnter -> BufWinEnter 顺序,
--- 但在 nvim_buf_call() 的过程中 TermOpen event 获取到的 window id 是临时的 autocmd window 会导致很多问题.
---@param term_obj MyTerm
---@return integer
local function create_my_term(term_obj)
  --- cache old term bufnr, for reuse old term_buf window.
  local old_term_bufnr = term_obj.bufnr

  --- 每次运行 jobstart() 之前, 先创建一个新的 scratch buffer 给 terminal.
  term_obj.bufnr = vim.api.nvim_create_buf(false, true)  -- nobuflisted scratch buffer

  vim.bo[term_obj.bufnr].filetype = "my_term"  --- set filetype
  vim.b[term_obj.bufnr][M.bufvar_myterm] = term_obj.id  --- 设置 bufvar: {my_term_id}

  --- autocmd 放在这里运行主要是有两个限制条件:
  --- 1. 在获取到 terminal bufnr 之后运行, 为了在 autocmd 中使用 bufnr 作为触发条件.
  --- 2. 在 term window 打开并加载 term bufnr 之前运行, 为了触发 BufWinEnter event.
  au_cb.autocmd_callback(term_obj)

  --- 快捷键设置: 在获取到 term.bufnr 和 term.id 之后运行.
  keymaps.set_buf_keymaps(term_obj)

  --- 进入一个选定的 term window 加载现有 term buffer, 同时 wipeout old_term_bufnr.
  local term_win_id = t_win.enter_term_win(term_obj.bufnr, old_term_bufnr)

  --- 设置 term win 属性
  local scope={ scope='local', win=term_win_id }
  vim.api.nvim_set_option_value('sidescrolloff', 0, scope)
  vim.api.nvim_set_option_value('scrolloff', 0, scope)

  return term_win_id
end

---jobstart(cmd, opts)
---@param term_obj MyTerm
---@param term_win_id integer
local function my_term_exec(term_obj, term_win_id)
  --- VVI: 必须在 bufnr 被 window 显示之后运行. 避免 nvim_buf_call() 生成一个临时 autocmd window.
  if term_obj.console_output then
    console.console_exec(term_obj, term_win_id)
  else
    terminal.terminal_exec(term_obj, term_win_id)
  end

  --- VVI: 手动触发 BufEnter & BufWinEnter event
  --- doautocmd "BufEnter & BufWinEnter term://"
  --- 触发时机在 after TermOpen & before TermClose
  --- 先触发 BufEnter, 再触发 BufWinEnter
  vim.api.nvim_exec_autocmds({"BufEnter", "BufWinEnter"}, { buffer = term_obj.bufnr })
end

--- NOTE: setmetatable() 将全部 term:methods() 放在 metatable 中, 防止方法被修改.
--- 如果 my_term 被 tbl_deep_extend() 则无法使用 methods, 因为 tbl_deep_extend() 无法 extend metatable.
function M.metatable_funcs()
  local meta_funcs = {}

  function meta_funcs:run()
    if self:job_status() == -1 then
      Notify("job_id is still running, please use `term:stop()` or `CTRL-C` first.", "WARN", {title="my_term"})
      return
    end

    --- executed before jobstart(). DO NOT have 'term.bufnr' and 'term.job_id' ...
    if self.before_run then
      self.before_run(self)
    end

    --- 创建 my term window and buffer
    local term_win_id = create_my_term(self)

    --- 执行 jobstart(cmd)
    my_term_exec(self, term_win_id)

    --- executed after jobstart(). Have 'term.bufnr' and 'term.job_id' ...
    --- 和 on_exit 的区别是不用等到 jobdone.
    if self.after_run then
      self.after_run(self)
    end

    --- cache terminal object
    g.global_my_term_cache[self.id] = self
  end

  --- 终止 job, 会触发 jobdone.
  function meta_funcs:stop()
    if self.job_id then
      vim.fn.jobstop(self.job_id)
    end
  end

  --- is_open(). true: window is opened; false: window is closed.
  function meta_funcs:is_open()
    if g.term_buf_exist(self.bufnr) then
      local term_wins = vim.fn.getbufinfo(self.bufnr)[1].windows
      if #term_wins > 0 then
        return true
      end
    end
  end

  --- open terminal window or goto terminal window, return win_id
  function meta_funcs:open_win()
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
  function meta_funcs:close_win()
    if g.term_buf_exist(self.bufnr) then
      local term_wins = vim.fn.getbufinfo(self.bufnr)[1].windows
      for _, w in ipairs(term_wins) do
        vim.api.nvim_win_close(w, true)
      end
    end
  end

  --- 检查 terminal 运行情况.
  function meta_funcs:job_status()
    --- `:help jobwait()`
    return vim.fn.jobwait({self.job_id}, 0)[1]
  end

  --- wipeout term buffer.
  function meta_funcs:wipeout()
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

  return meta_funcs
end

return M
