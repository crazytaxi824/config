local M = {}

M.global_my_term_cache = {}  -- map-like table { id:term_obj }
M.name_tag=';#my_term#'
M.bufvar_myterm = "my_term"

--- for persist my_term window height
--local win_height = 10
local win_height = math.ceil(vim.o.lines/4)

--- highlight
vim.api.nvim_set_hl(0, "my_output_sys", {ctermfg=Colors.orange.c, fg=Colors.orange.g})
vim.api.nvim_set_hl(0, "my_output_sys_error", {
  ctermfg=Colors.black.c, fg=Colors.black.g,
  ctermbg=Colors.orange.c, bg=Colors.orange.g,
})
vim.api.nvim_set_hl(0, "my_output_stdout", {ctermfg=Colors.blue.c, fg=Colors.blue.g})
vim.api.nvim_set_hl(0, "my_output_stderr", {ctermfg=Colors.red.c, fg=Colors.red.g})

--- default_opts 相当于 global setting.
M.default_opts = {
  --- VVI: 这三个属性不应该被外部手动修改.
  id = 1,  -- v:count1, VVI: 保证每个 id 只和一个 bufnr 对应. id 一旦设置应该无法改变.
  bufnr = nil,
  job_id = nil,

  cmd = vim.go.shell, -- `:help 'shell'`, get global option 'shell', 相当于 os.getenv('SHELL')
  jobstart = nil,     -- 'startinsert' | func(term), 在 termopen() 之后触发. eg: win_gotoid()
  jobdone = nil,      -- 'stopinsert' | 'exit'. 在 on_exit 中触发.
                      -- NOTE: 如果要设置 func 可以在 on_exit 中设置.
                      -- NOTE: jobdone 对 buf_output 无效.
  auto_scroll = nil,  -- goto bottom of the terminal. 在 on_stdout & on_stderr 中触发.
  print_cmd = nil,    -- bool, 是否打印 cmd. 默认不打印.
  buf_output = nil,   -- bool, 是否用 buf_job_output 执行, 默认使用 termopen().

  --- callback functions
  on_init = nil,   -- func(term), require('utils.my_term').new() 的时候触发.
  on_open = nil,   -- func(term), BufWinEnter. NOTE: 每次 term:// buffer 被 win 显示的时候都会触发,
                   -- 同一个 buffer 被多个窗口显示时也会触发.
  on_close = nil,  -- func(term), BufWinLeave. NOTE: BufWinLeave 只会在 buffer 离开最后一个 win 的时候触发.
  on_stdout = nil, -- func(term, job_id, data, event), 可用于 auto_scroll to bottom
  on_stderr = nil, -- func(term, job_id, data, event), 可用于 auto_scroll to bottom
  on_exit = nil,   -- func(term, job_id, exit_code, event), TermClose, jobstop() 时触发.
                   -- 可用于 `:silent! bwipeout! term_bufnr`
}

--- 判断 terminal bufnr 是否存在, 是否有效
M.term_buf_exist = function (bufnr)
  if bufnr and vim.api.nvim_buf_is_valid(bufnr) then
    return true
  end
end

--- keymaps: for terminal buffer only -------------------------------------------------------------- {{{
--- set keymaps for my_term terminal & output-buffer.
local function set_buf_keymaps(term_obj)
  local opt = {buffer = term_obj.bufnr, silent = true, noremap = true}
  local keys = {
    {'n', 't<Up>', '<cmd>resize +5<CR>',   opt, 'my_term: resize +5'},
    {'n', 't<Down>', '<cmd>resize -5<CR>', opt, 'my_term: resize -5'},
    {'n', 'tc', function() M.close_others(term_obj.id) end,   opt, 'my_term: close other my_terms windows'},
    {'n', 'tw', function() M.wipeout_others(term_obj.id) end, opt, 'my_term: wipeout other my_terms'},
    {'n', 'q',  function() M.wipeout(term_obj.id) end, opt, 'my_term: wipeout current my_term'},
  }
  require('utils.keymaps').set(keys)
end

local function stop_job(term_obj)
  if term_obj.job_id and vim.fn.jobstop(term_obj.job_id) == 1 then
    vim.bo[term_obj.bufnr].modifiable = true
    vim.api.nvim_buf_set_lines(term_obj.bufnr, -1, -1, true, {"signal: interrupt"})
    vim.bo[term_obj.bufnr].modifiable = false
  end
end

--- CTRL-C send interrupt signal to output-buffer ONLY. terminal already has this.
local function set_output_buf_keymaps(term_obj)
  local opt = {buffer = term_obj.bufnr, silent = true, noremap = true}
  local keys = {
    {'n', '<C-c>', function() stop_job(term_obj) end, opt, "my_term: jobstop()"},
    {'i', '<C-c>', function() stop_job(term_obj) end, opt, "my_term: jobstop()"},
  }
  require('utils.keymaps').set(keys)
end
-- -- }}}

--- 判断当前 windows 中是否有 my_term window, 返回 win_id ------------------------------------------ {{{
--- 通过 buffer name regexp 查找.
local function find_exist_term_win()
  local win_id = -1
  for _, term_obj in pairs(M.global_my_term_cache) do
    if M.term_buf_exist(term_obj.bufnr) then
      local term_wins = vim.fn.getbufinfo(term_obj.bufnr)[1].windows
      for _, w in ipairs(term_wins) do
        if w > win_id then
          win_id = w
        end
      end
    end
  end

  if win_id > 0 then
    return win_id
  end
end
-- -- }}}

--- auto_scroll: 自动滚动到 terminal 底部 ---------------------------------------------------------- {{{
local function buf_scroll_bottom(term_obj)
  if not term_obj.auto_scroll then
    return
  end

  vim.api.nvim_buf_call(term_obj.bufnr, function()
    --- 在 terminal insert mode ( mode()=='t' ) 时无法使用 `normal! G`. 在 terminal 模式下默认会滚动到最底部.
    local info = vim.api.nvim_get_mode()
    if info and (info.mode ~= "t") then vim.cmd("normal! G") end
  end)
end
-- -- }}}

--- autocmd: 根据 terminal bufnr 触发 -------------------------------------------------------------- {{{
local function autocmd_callback(term_obj)
  --- 关闭 terminal window 之后再打开时触发 BufWinEnter, 但不会触发 TermOpen.
  --- buffer 离开所有 window 才会触发 BufWinLeave.
  local g_id = vim.api.nvim_create_augroup('my_term_bufnr_' .. term_obj.bufnr, {clear=true})
  vim.api.nvim_create_autocmd({"BufWinEnter", "BufWinLeave"}, {
    group = g_id,
    buffer = term_obj.bufnr,
    callback = function(params)
      --- callback
      if params.event == "BufWinEnter" and term_obj.on_open then
        term_obj.on_open(term_obj)
        return
      end
      --- callback
      if params.event == "BufWinLeave" and term_obj.on_close then
        term_obj.on_close(term_obj)
      end
    end,
    desc = "my_term: on_open() & on_close() callback",
  })

  vim.api.nvim_create_autocmd("WinClosed", {
    group = g_id,
    buffer = term_obj.bufnr,
    callback = function(params)
      --- persist window height
      --- NOTE: 在 WinClosed event 中, params.file & params.match 都是 win_id, 数据类型是 string.
      local win_id = tonumber(params.match)
      if win_id then
        win_height = vim.api.nvim_win_get_height(win_id)
      end
    end,
    desc = "my_term: persist window height",
  })

  --- delete augroup
  vim.api.nvim_create_autocmd("BufWipeout", {
    group = g_id,
    buffer = term_obj.bufnr,
    callback = function(params)
      --- stop job in buf_job_output()
      vim.fn.jobstop(term_obj.job_id)

      --- remove from global_my_term_cache
      M.global_my_term_cache[term_obj.id] = nil

      vim.api.nvim_del_augroup_by_id(g_id)
    end,
    desc = "my_term: delete augroup by id",
  })
end
-- -- }}}

--- 默认使用 termopen() 方法打开 terminal. eg: shell terminal
--- termopen(): 执行 cmd --------------------------------------------------------------------------- {{{
local function termopen_cmd(term_obj)
  local cmd = term_obj.cmd .. M.name_tag  .. term_obj.id
  if term_obj.print_cmd then
    cmd = 'echo -e "\\e[32m' .. vim.fn.escape(term_obj.cmd,'"') .. ' \\e[0m" && ' .. cmd
  end

  --- VVI: 使用 nvim_buf_call() 时 bufnr 必须被某一个 window 显示, 否则 vim 会创建一个看不见的临时 autocmd window
  --- 用于执行 function. 导致 TermOpen event 中获取的 win id 是这个临时 window, 会造成一些 bug.
  vim.api.nvim_buf_call(term_obj.bufnr, function()
    term_obj.job_id = vim.fn.termopen(cmd, {
      on_stdout = function(job_id, data, event)  -- event 是 'stdout'
        --- auto_scroll option
        buf_scroll_bottom(term_obj)

        --- callback
        if term_obj.on_stdout then
          term_obj.on_stdout(term_obj, job_id, data, event)
        end
      end,

      on_stderr = function(job_id, data, event)  -- event 是 'stderr'
        --- auto_scroll option
        buf_scroll_bottom(term_obj)

        --- callback
        if term_obj.on_stderr then
          term_obj.on_stderr(term_obj, job_id, data, event)
        end
      end,

      on_exit = function(job_id, exit_code, event)  -- event 是 'exit'
        --- callback
        if term_obj.on_exit then
          term_obj.on_exit(term_obj, job_id, exit_code, event)
        end

        --- jobdone option
        if term_obj.jobdone == 'exit' then
          --- VVI: 手动 :bw 删除 buffer 时会触发 TermClose, 导致重复 wipeout buffer 而报错.
          if M.term_buf_exist(term_obj.bufnr) then
            vim.api.nvim_buf_delete(term_obj.bufnr, {force=true})
          end
        elseif term_obj.jobdone == 'stopinsert' then
          --- jobdone 的时候 cursor 在 terminal window 中则执行 stopinsert.
          local term_wins = vim.fn.getbufinfo(term_obj.bufnr)[1].windows
          if vim.tbl_contains(term_wins, vim.api.nvim_get_current_win()) then
            vim.cmd('stopinsert')
          end
        end
      end,
    })
  end)
end
-- -- }}}

--- 使用 jobstart() 方法将 output 写入指定 buffer 中. eg: exec_term
--- buf_job_output(): 执行 cmd --------------------------------------------------------------------- {{{
--- nvim_buf_set_lines(0, 0) 在第一行前面写入.
--- nvim_buf_set_lines(0, 1) 在第一行写入.
--- nvim_buf_set_lines(0, -1) 删除所有, 然后在第一行写入.
--- nvim_buf_set_lines(-2, -2) 在最后一行前面写入, 即: 在倒数第二行后面写入.
--- nvim_buf_set_lines(-2, -1) 在最后一行写入.
--- nvim_buf_set_lines(-1, -1) 在最后一行后面写入, 相当于 append().
local function set_buf_line_output(bufnr, data, hl)
  local last_line_before_write = vim.api.nvim_buf_line_count(bufnr)

  --- 开启 modifiable 准备写入数据.
  vim.bo[bufnr].modifiable = true

  --- VVI: 处理 EOF, data 最后会多一行 empty line.
  --- `:help channel-callback`, `:help channel-lines`, 中说明: EOF is a single-item list: `['']`.
  if data[#data] == '' then
    table.remove(data, #data)
  end

  --- replace 所有的 '\n', 因为 '\n' 会造成 nvim_buf_set_lines() Error.
  --- 这里的 '\n' 其实是 byte(0) 本应该是 '\null' 但是只显示了第一个字符.
  for i, d in ipairs(data) do
    data[i] = string.gsub(d, '\n', '�')
  end

  --- write output to buffer
  vim.api.nvim_buf_set_lines(bufnr, -1, -1, true, data)
  vim.bo[bufnr].modifiable = false

  --- highlight lines
  for i = last_line_before_write, vim.api.nvim_buf_line_count(bufnr), 1 do
    vim.api.nvim_buf_add_highlight(bufnr, -1, hl, i, 0, -1)
  end
end

local function set_buf_line_exit(bufnr, exit_code)
  local last_line_before_write = vim.api.nvim_buf_line_count(bufnr)
  vim.bo[bufnr].modifiable = true
  vim.api.nvim_buf_set_lines(bufnr, -1, -1, true, {"", "[Process exited " .. exit_code .. "]"})

  --- highlight
  if exit_code == 0 then
    vim.api.nvim_buf_add_highlight(bufnr, -1, "my_output_sys", last_line_before_write+1, 0, -1)
  else
    vim.api.nvim_buf_add_highlight(bufnr, -1, "my_output_sys_error", last_line_before_write+1, 0, -1)
  end
  vim.bo[bufnr].modifiable = false
end

--- NOTE: neovim 是单线程, jobstart() 是异步函数.
local function buf_job_output(term_obj)
  vim.api.nvim_buf_call(term_obj.bufnr, function()
    local win_id = vim.api.nvim_get_current_win()

    --- 如果 window type 是 autocmd 表示 buffer 没有被任何 window 显示,
    --- 被 nvim_buf_call() 临时打开了一个 window.
    if vim.fn.win_gettype(win_id) == 'autocmd' then
      return
    end

    vim.api.nvim_set_option_value('wrap', true, { scope='local', win=win_id })
    vim.api.nvim_set_option_value('relativenumber', false, { scope='local', win=win_id })
    vim.api.nvim_set_option_value('signcolumn', 'no', { scope='local', win=win_id })

    --- listchars 添加空格标记
    local listchars = vim.wo[win_id].listchars .. ',space:·'
    vim.api.nvim_set_option_value('listchars', listchars, { scope='local', win=win_id })
  end)

  --- set bufname
  vim.api.nvim_buf_set_name(term_obj.bufnr, "term://" .. term_obj.cmd .. M.name_tag .. term_obj.id)

  if term_obj.print_cmd then
    vim.api.nvim_buf_set_lines(term_obj.bufnr, 0, -1, true, {term_obj.cmd})  -- clear buffer text & print cmd
    vim.api.nvim_buf_add_highlight(term_obj.bufnr, -1, "my_output_sys", 0, 0, -1)  -- highlight 第一行
    vim.bo[term_obj.bufnr].modifiable = false
  end

  --- keymap
  set_output_buf_keymaps(term_obj)

  term_obj.job_id = vim.fn.jobstart(term_obj.cmd, {
    on_stdout = function (job_id, data, event)  -- NOTE: fmt.Print()
      --- 防止 term buffer 在执行过程中被 wipeout 造成的 error.
      if not M.term_buf_exist(term_obj.bufnr) then
        return
      end

      --- write output to buffer
      set_buf_line_output(term_obj.bufnr, data, "my_output_stdout")

      --- auto_scroll option
      buf_scroll_bottom(term_obj)

      --- callback
      if term_obj.on_stdout then
        term_obj.on_stdout(term_obj, job_id, data, event)
      end
    end,

    on_stderr = function (job_id, data, event)  -- NOTE: log.Print()
      --- 防止 term buffer 在执行过程中被 wipeout 造成的 error.
      if not M.term_buf_exist(term_obj.bufnr) then
        return
      end

      --- write output to buffer
      set_buf_line_output(term_obj.bufnr, data, "my_output_stderr")

      --- auto_scroll option
      buf_scroll_bottom(term_obj)

      --- callback
      if term_obj.on_stderr then
        term_obj.on_stderr(term_obj, job_id, data, event)
      end
    end,

    on_exit = function(job_id, exit_code, event)
      --- callback
      if term_obj.on_exit then
        term_obj.on_exit(term_obj, job_id, exit_code, event)
      end

      --- 防止 term buffer 在执行过程中被 wipeout 造成的 error.
      if not M.term_buf_exist(term_obj.bufnr) then
        return
      end

      --- write exit to buffer
      set_buf_line_exit(term_obj.bufnr, exit_code)

      --- auto_scroll option
      buf_scroll_bottom(term_obj)
    end,
  })
end
-- -- }}}

--- 创建一个 window 用于 terminal 运行
M.create_term_win = function(bufnr)
  local exist_win_id = find_exist_term_win()
  if vim.fn.win_gotoid(exist_win_id) == 1 then
    --- at least 1 terminal window exist
    vim.api.nvim_open_win(bufnr, true, {split='right'})
  else
    --- no terminal window exist, create a botright window for terminals.
    vim.api.nvim_open_win(bufnr, true, {height=win_height, split='below'})
  end

  --- return win_id
  return vim.api.nvim_get_current_win()
end

--- 打开/创建 terminal window 用于 termopen() ------------------------------------------------------ {{{
--- NOTE: buffer 一旦运行过 termopen() 就不能再次运行 termopen() 了, Can only call this function in an unmodified buffer.
--- 所以需要删除旧的 bufnr 然后重新创建一个新的 scratch bufnr 给 termopen() 使用.
local function enter_term_win(curr_term_bufnr, old_term_bufnr)
  --- 如果 old_term_bufnr 不存在: 创建一个新的 term window 用于加载 new term.bufnr
  if not M.term_buf_exist(old_term_bufnr) then
    return M.create_term_win(curr_term_bufnr)
  end

  --- 这里是为了 re-use term window
  local win_id
  --- 获取 old_term_bufnr 所在的 windows id.
  local term_wins = vim.fn.getbufinfo(old_term_bufnr)[1].windows
  if #term_wins > 0 then
    --- 如果 old term buffer 存在, 同时 window 存在: 使用该 window 中加载 new term.bufnr
    win_id = term_wins[1]
    if vim.fn.win_gotoid(win_id) == 1 then
      vim.api.nvim_win_set_buf(win_id, curr_term_bufnr)  -- 将 bufnr 加载到指定 win_id.
    else
      error("term_win_id: " .. win_id .. " is not exist")
    end
  else
    --- 如果 old term buffer 存在, 但是 window 不存在: 创建一个新的 term window 加载 new term.bufnr.
    win_id = M.create_term_win(curr_term_bufnr)
  end

  --- NOTE: wipeout old_term_bufnr 放在最后避免关闭 old_term_bufnr 所在 window.
  vim.api.nvim_buf_delete(old_term_bufnr, {force=true})

  return win_id
end
-- -- }}}

--- Create new terminal ---------------------------------------------------------------------------- {{{
--- VVI: 以下执行顺序很重要!
--- 事件触发顺序和 `:edit term://cmd` 有所不同.
--- `:edit term://cmd` 中: 触发顺序 TermOpen -> BufEnter -> BufWinEnter.
--- my_term 中触发顺序 BufEnter -> BufWinEnter -> TermOpen.
--- NOTE: nvim_buf_call()
--- 可以使用 nvim_buf_call(bufnr, function() termopen() end) 做到 TermOpen -> BufEnter -> BufWinEnter 顺序,
--- 但在 nvim_buf_call() 的过程中 TermOpen event 获取到的 window id 是临时的 autocmd window 会导致很多问题.
local function create_my_term(term_obj)
  --- cache old term bufnr
  local old_term_bufnr = term_obj.bufnr

  --- 每次运行 termopen() 之前, 先创建一个新的 scratch buffer 给 terminal.
  term_obj.bufnr = vim.api.nvim_create_buf(false, true)  -- nobuflisted scratch buffer
  vim.bo[term_obj.bufnr].filetype = "my_term"

  --- 给 buffer 设置 var: my_term_id
  vim.b[term_obj.bufnr][M.bufvar_myterm] = term_obj.id

  --- autocmd 放在这里运行主要是有两个限制条件:
  --- 1. 在获取到 terminal bufnr 之后运行, 为了在 autocmd 中使用 bufnr 作为触发条件.
  --- 2. 在 term window 打开并加载 term bufnr 之前运行, 为了触发 BufWinEnter event.
  autocmd_callback(term_obj)

  --- 快捷键设置: 在获取到 term.bufnr 和 term.id 之后运行.
  set_buf_keymaps(term_obj)

  --- 进入一个选定的 term window 加载现有 term buffer, 同时 wipeout old_term_bufnr.
  local term_win_id = enter_term_win(term_obj.bufnr, old_term_bufnr)
  --- VVI: 必须在 bufnr 被 window 显示之后运行. 避免 nvim_buf_call() 生成一个临时 autocmd window.
  if term_obj.buf_output then
    buf_job_output(term_obj)
  else
    termopen_cmd(term_obj)
  end

  --- VVI: doautocmd "BufEnter & BufWinEnter term://"
  --- 触发时机在 after TermOpen & before TermClose
  --- 先触发 BufEnter, 再触发 BufWinEnter
  vim.api.nvim_exec_autocmds({"BufEnter", "BufWinEnter"}, { buffer = term_obj.bufnr })

  --- jobstart option. 在 termopen() 后执行.
  if term_obj.jobstart then
    if term_obj.jobstart == 'startinsert' then
      --- 判断当前是否是 term window. 防止 before_exec & after_exec 跳转到别的 window.
      if vim.api.nvim_get_current_win() == term_win_id then
        vim.cmd('startinsert')
      end
    elseif type(term_obj.jobstart) == "function" then
      term_obj.jobstart(term_obj)
    end
  end
end
-- -- }}}

--- NOTE: setmetatable() 将全部 term:methods() 放在 metatable 中, 如果 term 被 tbl_deep_extend() 则无法
--- 使用 methods, 因为 tbl_deep_extend() 无法 extend metatable.
M.metatable_funcs = function()
  local meta_funcs = {}

  --- opts:
  --- - print_cmd: print executed cmd in terminal.
  --- - buf_output: print stdout & stderr to scratch buffer.
  function meta_funcs:run()
    if self:job_status() == -1 then
      Notify("job_id is still running, please use `term:stop()` or `CTRL-C` first.", "WARN", {title="my_term"})
      return
    end

    create_my_term(self)

    --- cache terminal object
    M.global_my_term_cache[self.id] = self
  end

  --- 终止 job, 会触发 jobdone.
  function meta_funcs:stop()
    if self.job_id then
      vim.fn.jobstop(self.job_id)
    end
  end

  --- is_open(). true: window is opened; false: window is closed.
  function meta_funcs:is_open()
    if M.term_buf_exist(self.bufnr) then
      local term_wins = vim.fn.getbufinfo(self.bufnr)[1].windows
      if #term_wins > 0 then
        return true
      end
    end
  end

  --- open terminal window or goto terminal window, return win_id
  function meta_funcs:open_win()
    if M.term_buf_exist(self.bufnr) then
      local term_wins = vim.fn.getbufinfo(self.bufnr)[1].windows
      if #term_wins > 0 then
        --- 如果有 window 正在显示该 term buffer, 则跳转到该 window.
        if vim.fn.win_gotoid(term_wins[1]) == 0 then
          error('vim cannot win_gotoid(' .. term_wins[1] .. ')')
        end

        return term_wins[1]
      else
        --- 如果没有任何 window 显示该 terminal 则创建一个新的 window, 然后加载该 buffer.
        return M.create_term_win(self.bufnr)
      end
    end
  end

  --- close all windows which displays this term buffer.
  function meta_funcs:close_win()
    if M.term_buf_exist(self.bufnr) then
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
    if not M.term_buf_exist(self.bufnr) then
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

--- 以下函数用于 term buffer keymaps ---------------------------------------------------------------

--- NOTE: M.close() 没有实现, 可以使用 `:q` 代替.

--- close all other terms except term_id
M.close_others = function(term_id)
  local t = M.global_my_term_cache[term_id]
  if not t then
    Notify('term: "' .. term_id .. '" is not exist', "WARN")
    return
  end

  for _, term_obj in pairs(M.global_my_term_cache) do
    if term_obj.bufnr ~= t.bufnr then
      term_obj:close_win()
    end
  end
end

M.wipeout = function(term_id)
  local t = M.global_my_term_cache[term_id]
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
  local t = M.global_my_term_cache[term_id]
  if not t then
    Notify('term: "' .. term_id .. '" is not exist', "WARN")
    return
  end

  for _, term_obj in pairs(M.global_my_term_cache) do
    if term_obj.bufnr ~= t.bufnr then
      term_obj:wipeout()
    end
  end
end

return M
