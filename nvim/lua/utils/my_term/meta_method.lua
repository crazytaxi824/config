local g = require('utils.my_term.deps.global')
local au_cb = require('utils.my_term.deps.autocmd_callback')
local t_win = require('utils.my_term.deps.term_win')
local console = require('utils.my_term.deps.exec_console')
local terminal = require('utils.my_term.deps.exec_terminal')

local M = {}

M.bufvar_myterm = "my_term"

--- default_opts 相当于 global setting.
M.default_opts = {
  --- VVI: 这三个属性不应该被外部手动修改.
  id = 1,  -- v:count1, VVI: 保证每个 id 只和一个 bufnr 对应. id 一旦设置应该无法改变.
  bufnr = nil,
  job_id = nil,

  cmd = vim.go.shell, -- `:help 'shell'`, 相当于 os.getenv('SHELL')
  cwd = nil,          -- jobstart() 中的 opts.
  auto_scroll = nil,  -- goto bottom of the terminal. 在 on_stdout & on_stderr 中触发.
  console_output = nil,   -- bool, true: 在 console 中执行; false: 在 terminal 中执行.

  --- callback functions
  before_run = nil, -- func(term), term:run() 时触发. before jobstart().
  after_run = nil,  -- func(term), term:run() 时触发. 在 jobstart() 之后马上执行, 和 on_exit 的区别是不用等到 jobdone.

  on_open = nil,   -- func(term), BufWinEnter. NOTE: 每次 term:// buffer 被 win 显示的时候都会触发,
                   -- 同一个 buffer 被多个窗口显示时也会触发.
  on_close = nil,  -- func(term), BufWinLeave. NOTE: BufWinLeave 只会在 buffer 离开最后一个 win 的时候触发.

  on_stdout = nil, -- func(term, job_id, data, event), 可用于 auto_scroll to bottom
  on_stderr = nil, -- func(term, job_id, data, event), 可用于 auto_scroll to bottom
  on_exit = nil,   -- func(term, job_id, exit_code, event), TermClose, jobstop() 时触发.
                   -- 可用于 `:silent! bwipeout! term_bufnr`
}

--- keymaps: for terminal buffer only --------------------------------------------------------------
--- set keymaps for my_term terminal & output-buffer.
local function set_buf_keymaps(term_obj)
  local opt = { buffer = term_obj.bufnr, silent = true }
  local keys = {
    {'n', 't<Up>', '<cmd>resize +5<CR>',   opt, 'my_term: resize +5'},
    {'n', 't<Down>', '<cmd>resize -5<CR>', opt, 'my_term: resize -5'},
    {'n', 'tc', function() M.close_others(term_obj.id) end,   opt, 'my_term: close other my_terms windows'},
    {'n', 'tw', function() M.wipeout_others(term_obj.id) end, opt, 'my_term: wipeout other my_terms'},
    {'n', 'q',  function() M.wipeout(term_obj.id) end, opt, 'my_term: wipeout current my_term'},
  }
  require('utils.keymaps').set(keys)
end

--- Create new terminal ----------------------------------------------------------------------------
--- VVI: 以下执行顺序很重要!
--- `jobstart(cmd, {opts})` 事件触发顺序和 `:edit term://cmd` 有所不同.
--- `:edit term://cmd` 中: 触发顺序 TermOpen -> BufEnter -> BufWinEnter.
--- `jobstart(cmd, {opts})` 触发顺序 BufEnter -> BufWinEnter -> TermOpen.
---
--- NOTE: nvim_buf_call()
--- 可以使用 nvim_buf_call(bufnr, function() jobstart(...) end) 做到 TermOpen -> BufEnter -> BufWinEnter 顺序,
--- 但在 nvim_buf_call() 的过程中 TermOpen event 获取到的 window id 是临时的 autocmd window 会导致很多问题.
local function create_my_term(term_obj)
  --- cache old term bufnr, for reuse old term_buf window.
  local old_term_bufnr = term_obj.bufnr

  --- 每次运行 jobstart() 之前, 先创建一个新的 scratch buffer 给 terminal.
  term_obj.bufnr = vim.api.nvim_create_buf(false, true)  -- nobuflisted scratch buffer
  vim.bo[term_obj.bufnr].filetype = "my_term"

  --- 给 buffer 设置 var: my_term_id
  vim.b[term_obj.bufnr][M.bufvar_myterm] = term_obj.id

  --- autocmd 放在这里运行主要是有两个限制条件:
  --- 1. 在获取到 terminal bufnr 之后运行, 为了在 autocmd 中使用 bufnr 作为触发条件.
  --- 2. 在 term window 打开并加载 term bufnr 之前运行, 为了触发 BufWinEnter event.
  au_cb.autocmd_callback(term_obj)

  --- 快捷键设置: 在获取到 term.bufnr 和 term.id 之后运行.
  set_buf_keymaps(term_obj)

  --- 进入一个选定的 term window 加载现有 term buffer, 同时 wipeout old_term_bufnr.
  local term_win_id = t_win.enter_term_win(term_obj.bufnr, old_term_bufnr)
  --- VVI: 必须在 bufnr 被 window 显示之后运行. 避免 nvim_buf_call() 生成一个临时 autocmd window.
  if term_obj.console_output then
    console.console_exec(term_obj, term_win_id)
  else
    terminal.terminal_exec(term_obj, term_win_id)
  end

  local scope={ scope='local', win=term_win_id }
  vim.api.nvim_set_option_value('sidescrolloff', 0, scope)
  vim.api.nvim_set_option_value('scrolloff', 0, scope)

  --- VVI: doautocmd "BufEnter & BufWinEnter term://"
  --- 触发时机在 after TermOpen & before TermClose
  --- 先触发 BufEnter, 再触发 BufWinEnter
  vim.api.nvim_exec_autocmds({"BufEnter", "BufWinEnter"}, { buffer = term_obj.bufnr })
end

--- NOTE: setmetatable() 将全部 term:methods() 放在 metatable 中, 如果 term 被 tbl_deep_extend() 则无法
--- 使用 methods, 因为 tbl_deep_extend() 无法 extend metatable.
M.metatable_funcs = function()
  local meta_funcs = {}

  function meta_funcs:run()
    if self:job_status() == -1 then
      Notify("job_id is still running, please use `term:stop()` or `CTRL-C` first.", "WARN", {title="my_term"})
      return
    end

    --- executed before jobstart(). DO NOT have 'term.bufnr' and 'term.job_id' ...
    g.exec_callbacks(self.before_run, self)

    create_my_term(self)

    --- executed after jobstart(). Have 'term.bufnr' and 'term.job_id' ...
    --- 和 on_exit 的区别是不用等到 jobdone.
    g.exec_callbacks(self.after_run, self)

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

  --- append callback funcitons: on_open, on_close, on_exit, on_stdout, on_stderr, before_run, after_run ...
  --- 使用场景: 在多个不同地方需要添加多个 callbacks 的情况下使用.
  function meta_funcs:append(cb_name, callback)
    if type(callback) ~= 'function' then
      vim.notify("my_term append() callback is not a function", vim.log.levels.WARN)
      return
    end

    if not self[cb_name] then
      self[cb_name] = callback
      return
    end

    local typ = type(self[cb_name])
    if typ == 'function' then
      local tmp = { self[cb_name] }
      table.insert(tmp, callback)
      self[cb_name] = tmp
    elseif typ == 'table' then
      table.insert(self[cb_name], callback)
    end
  end

  return meta_funcs
end

--- 以下函数用于 term buffer keymaps ---------------------------------------------------------------

--- NOTE: M.close() 没有实现, 可以使用 `:q` 代替.

--- close all other terms except term_id
M.close_others = function(term_id)
  local t = g.global_my_term_cache[term_id]
  if not t then
    Notify('term: "' .. term_id .. '" is not exist', "WARN")
    return
  end

  for _, term_obj in pairs(g.global_my_term_cache) do
    if term_obj.bufnr ~= t.bufnr then
      term_obj:close_win()
    end
  end
end

M.wipeout = function(term_id)
  local t = g.global_my_term_cache[term_id]
  if not t then
    Notify('term: "' .. term_id .. '" is not exist', "WARN")
    return
  end

  if t:job_status() == -1 then
    Notify("job_id is still running, please use `term:stop()` or `CTRL-C` first.", "WARN", {title="my_term"})
    return
  end

  t:wipeout()
end

--- wipeout all other terms except term_id
M.wipeout_others = function(term_id)
  local t = g.global_my_term_cache[term_id]
  if not t then
    Notify('term: "' .. term_id .. '" is not exist', "WARN")
    return
  end

  for _, term_obj in pairs(g.global_my_term_cache) do
    if term_obj.bufnr ~= t.bufnr then
      term_obj:wipeout()
    end
  end
end

return M
