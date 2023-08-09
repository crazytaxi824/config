--- open terminal at bottom only.
--- NOTE: my_term 和 id 绑定, 同时只能有 0/1 个 buffer, bufnr 可能会变更.
--- my_term 可能会有多个 window 同时显示, win_id 随时可能变化. getbufinfo(bufnr) -> windows
--- startinsert & stopinsert 慎用. mode 是全局的, 无论 cursor 在哪一个 window 都会改变 mode,
--- 所以很有可能会受到 win_gotoid() 的影响.

--- 原理: nvim_create_buf() -> <cmd>botright sbuffer bufnr -> win_gotoid(win_id) -> termopen(cmd)

local M = {}

local global_my_term_cache = {}  -- map-like table { id:term_obj }

local name_tag=';#my_term#'

local bufvar_myterm = "my_term"

local win_height = 16  -- persist window height

--- default_opts 相当于 global setting.
local default_opts = {
  --- VVI: 这三个属性不应该被外部手动修改.
  id = 1,  -- v:count1, VVI: 保证每个 id 只和一个 bufnr 对应. id 一旦设置应该无法改变.
  bufnr = nil,
  job_id = nil,

  cmd = vim.go.shell, -- 相当于 os.getenv('SHELL')
  jobstart = nil,     -- 'startinsert' | func(term), 在 termopen() 之后触发. eg: win_gotoid()
  jobdone = nil,      -- 'stopinsert' | 'exit'. 在 on_exit 中触发. 如果要设置 func 可以在 on_exit 中设置.
  auto_scroll = nil,  -- goto bottom of the terminal. 在 on_stdout & on_stderr 中触发.

  on_init = nil,  -- func(term), new()
  on_open = nil,  -- func(term), BufWinEnter. NOTE: 每次 term:// buffer 被 win 显示的时候都会触发, 多个窗口显示时也会触发.
  on_close = nil, -- func(term), BufWinLeave. NOTE: BufWinLeave 只会在 buffer 离开最后一个 win 的时候触发.
  on_stdout = nil, -- func(term, jobid, data, event), 可用于 auto_scroll.
  on_stderr = nil, -- func(term, jobid, data, event), 可用于 auto_scroll.
  on_exit = nil,   -- func(term, job_id, exit_code, event), TermClose, jobstop(), 可用于 `:silent! bwipeout! term_bufnr`
}

--- keymaps: for terminal buffer only -------------------------------------------------------------- {{{
local function set_buf_keymaps(term_obj)
  local opt = {buffer = term_obj.bufnr, silent = true, noremap = true}
  local keys = {
    {'n', 't<Up>', '<cmd>resize +5<CR>', opt, 'my_term: resize +5'},
    {'n', 't<Down>', '<cmd>resize -5<CR>', opt, 'my_term: resize -5'},
    {'n', 'tc', function() M.close_others(term_obj.id) end,   opt, 'my_term: close other my_terms'},
    {'n', 'tw', function() M.wipeout_others(term_obj.id) end, opt, 'my_term: wipeout other my_terms'},
  }
  require('user.utils.keymaps').set(keys)
end
-- -- }}}

--- 判断当前 windows 中是否有 my_term window, 返回 win_id ------------------------------------------ {{{
--- 通过 buffer name regexp 查找.
local function find_exist_term_win()
  local win_id = -1
  for _, wi in ipairs(vim.fn.getwininfo()) do
    if wi.terminal == 1  -- is a terminal window
      and wi.winid > win_id  -- get last win_id
      and string.match(vim.api.nvim_buf_get_name(wi.bufnr), 'term://.*' .. name_tag .. '%d+')  --- it is my_term
    then
      win_id = wi.winid  -- cache win_id
    end
  end

  if win_id > 0 then
    return win_id
  end
end
-- -- }}}

--- 判断 terminal bufnr 是否存在, 是否有效 --------------------------------------------------------- {{{
local function term_buf_exist(bufnr)
  if bufnr and vim.api.nvim_buf_is_valid(bufnr) then
    return true
  end
end
-- -- }}}

--- auto_scroll: 自动滚动到 terminal 底部 ---------------------------------------------------------- {{{
local function buf_scroll_bottom(term_obj)
  if term_obj.auto_scroll then
    vim.api.nvim_buf_call(term_obj.bufnr, function()
      local info = vim.api.nvim_get_mode()
      --- VVI: 只允许 Normal | terminal-Normal mode 下进行滚动, 否则报错.
      if info and (info.mode == "n" or info.mode == "nt") then vim.cmd("normal! G") end
    end)
  end
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
      win_height = vim.api.nvim_win_get_height(tonumber(params.match))
    end,
    desc = "my_term: persist window height",
  })

  --- delete augroup
  vim.api.nvim_create_autocmd("BufWipeout", {
    group = g_id,
    buffer = term_obj.bufnr,
    callback = function(params) vim.api.nvim_del_augroup_by_id(g_id) end,
    desc = "my_term: delete augroup by id",
  })
end
-- -- }}}

--- termopen(): 执行 cmd --------------------------------------------------------------------------- {{{
local function termopen_cmd(term_obj, print_cmd)
  --- VVI: 使用 nvim_buf_call() 时 bufnr 必须被某一个 window 显示, 否则 vim 会创建一个看不见的临时 autocmd window
  --- 用于执行 function. 导致 TermOpen event 中获取的 win id 是这个临时 window, 会造成一些 bug.
  vim.api.nvim_buf_call(term_obj.bufnr, function()
    local cmd = term_obj.cmd .. name_tag  .. term_obj.id
    if print_cmd then
      cmd = 'echo -e "\\e[32m' .. vim.fn.escape(term_obj.cmd,'"') .. ' \\e[0m" && ' .. cmd
    end

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
          --- VVI: 必须使用 `:silent! bwipeout! bufnr` 否则手动删除 buffer 时会触发 TermClose, 导致重复 wipeout buffer 而报错.
          pcall(vim.api.nvim_buf_delete, term_obj.bufnr, {force=true})
        elseif term_obj.jobdone == 'stopinsert' then
          --- jobdone 的时候 cursor 在 terminal window 中则执行 stopinsert.
          local wins = vim.fn.getbufinfo(term_obj.bufnr)[1].windows
          if vim.tbl_contains(wins, vim.api.nvim_get_current_win()) then
            vim.cmd('stopinsert')
          end
        end
      end,
    })
  end)
end
-- -- }}}

--- 创建一个 window 用于 terminal 运行 ------------------------------------------------------------- {{{
--- creat: 创建一个 window, load scratch buffer 用于执行 termopen()
--- load:  创建一个 window, load exist terminal buffer.
local function create_term_win(bufnr)
  local exist_win_id = find_exist_term_win()
  if vim.fn.win_gotoid(exist_win_id) == 1 then
    --- at least 1 terminal window exist
    vim.cmd('vertical rightbelow sbuffer ' .. bufnr)
  else
    --- no terminal window exist, create a botright window for terminals.
    vim.cmd('horizontal botright sbuffer' .. bufnr .. ' | resize ' .. win_height)
  end

  --- return win_id
  return vim.api.nvim_get_current_win()
end
-- -- }}}

--- 打开/创建 terminal window 用于 termopen() ------------------------------------------------------ {{{
--- NOTE: buffer 一旦运行过 termopen() 就不能再次运行了, Can only call this function in an unmodified buffer.
--- 所以需要删除旧的 bufnr 然后重新创建一个新的 scratch bufnr 给 termopen() 使用.
local function enter_term_win(curr_term_bufnr, old_term_bufnr)
  --- 如果 old_term_bufnr 不存在: 创建一个新的 term window 用于加载 new term.bufnr
  if not term_buf_exist(old_term_bufnr) then
    return create_term_win(curr_term_bufnr)
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
    win_id = create_term_win(curr_term_bufnr)
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
local function create_my_term(term_obj, print_cmd)
  --- cache old term bufnr
  local old_term_bufnr = term_obj.bufnr

  --- 每次运行 termopen() 之前, 先创建一个新的 scratch buffer 给 terminal.
  term_obj.bufnr = vim.api.nvim_create_buf(false, true)  -- nobuflisted scratch buffer

  --- 给 buffer 设置 var
  vim.b[term_obj.bufnr][bufvar_myterm] = term_obj.id

  --- VVI: 在 window 加载 term buffer 之前更改 buffer name. 主要作用是为了触发 'BufEnter & BufWinEnter term://'.
  vim.api.nvim_buf_set_name(term_obj.bufnr, 'term://'..term_obj.cmd .. name_tag .. term_obj.id)

  --- autocmd 放在这里运行主要是有两个限制条件:
  --- 1. 在获取到 terminal bufnr 之后运行, 为了在 autocmd 中使用 bufnr 作为触发条件.
  --- 2. 在 term window 打开并加载 term bufnr 之前运行, 为了触发 BufWinEnter event.
  autocmd_callback(term_obj)

  --- 快捷键设置: 在获取到 term.bufnr 和 term.id 之后运行.
  set_buf_keymaps(term_obj)

  --- 进入一个选定的 term window 加载现有 term buffer, 同时 wipeout old_term_bufnr.
  local term_win_id = enter_term_win(term_obj.bufnr, old_term_bufnr)

  --- termopen(): 必须在 bufnr 被 window 显示之后运行. 避免 nvim_buf_call() 生成一个临时 autocmd window.
  termopen_cmd(term_obj, print_cmd)

  --- jobstart option. 在 termopen() 后执行.
  if term_obj.jobstart then
    if term_obj.jobstart == 'startinsert' then
      --- 判断当前是否是 term window. 防止 before_exec & after_exec 跳转到别的 window.
      if vim.api.nvim_get_current_win() == term_win_id  then
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
local function metatable_funcs()
  local meta_funcs = {}

  function meta_funcs:run(print_cmd)
    if self:job_status() == -1 then
      Notify("job_id is still running, please use `term.stop()` first.", "WARN", {title="my_term"})
      return
    end

    create_my_term(self, print_cmd)
  end

  --- 终止 job, 会触发 jobdone.
  function meta_funcs:stop()
    if self.job_id then
      vim.fn.jobstop(self.job_id)
    end
  end

  --- is_open(). true: window is opened; false: window is closed.
  function meta_funcs:is_open()
    if term_buf_exist(self.bufnr) then
      local wins = vim.fn.getbufinfo(self.bufnr)[1].windows
      if #wins > 0 then
        return true
      end
    end
  end

  --- open terminal window or goto terminal window, return win_id
  function meta_funcs:open_win()
    if term_buf_exist(self.bufnr) then
      local wins = vim.fn.getbufinfo(self.bufnr)[1].windows
      if #wins > 0 then
        --- 如果有 window 正在显示该 term buffer, 则跳转到该 window.
        if vim.fn.win_gotoid(wins[1]) == 0 then
          error('vim cannot win_gotoid(' .. wins[1] .. ')')
        end

        return wins[1]
      else
        --- 如果没有任何 window 显示该 termimal 则创建一个新的 window, 然后加载该 buffer.
        return create_term_win(self.bufnr)
      end
    end
  end

  --- close all windows which displays this term buffer.
  function meta_funcs:close_win()
    if term_buf_exist(self.bufnr) then
      local wins = vim.fn.getbufinfo(self.bufnr)[1].windows
      for _, w in ipairs(wins) do
        vim.api.nvim_win_close(w, 'force')
      end
    end
  end

  --- 将 terminal 重置为 default_opts
  function meta_funcs:clear()
    --- VVI: 这里不能简单的使用 self = default_opts 因为:
    --- 1. 导致 global_my_term_cache 中的 term object 无效.
    --- 2. 不会保留 metatable, 会导致所有的 methods 丢失.
    for key, value in pairs(default_opts) do
      self[key] = value
    end
  end

  --- 检查 terminal 运行情况.
  function meta_funcs:job_status()
    --- `:help jobwait()`
    return vim.fn.jobwait({self.job_id}, 0)[1]
  end

  return meta_funcs
end

M.new = function(opts)
  opts = vim.tbl_deep_extend('force', default_opts, opts or {})

  --- NOTE: terminal 已经存在, 无法使用相同 id 创建新的 terminal.
  if global_my_term_cache[opts.id] then
    error('terminal id='.. opts.id .. ' is already created')
  end

  --- terminal object
  local my_term = opts

  --- cache terminal object
  global_my_term_cache[my_term.id] = my_term

  --- callback
  if my_term.on_init then
    my_term.on_init(my_term)
  end

  --- generate metatable - term:methods()
  local mt = metatable_funcs()

  --- VVI: set all term:methods() to terminal object's metatable
  setmetatable(my_term, { __index = mt })

  return my_term
end

M.open_shell_term = function()
  if vim.v.count1 > 999 then
    Notify("my_term id should be 1~999 in this method", "INFO")
    return
  end

  local t = M.get_term_by_id(vim.v.count1)
  --- terminal 没有被缓存则 :new()
  if not t then
    t = M.new({
      id = vim.v.count1,
      jobdone = 'exit',
      jobstart = 'startinsert',
    })
    t:run()
    return
  end

  --- terminal 存在, 但是无法 open_win(), 则 run()
  if not t:open_win() then
    t:run()
  end
end

--- return an term object by id
M.get_term_by_id = function(id)
  return global_my_term_cache[id]
end

--- get term_id by term_win_id
M.get_term_id_by_win = function(win_id)
  if vim.api.nvim_win_is_valid(win_id) then
    local bufnr = vim.api.nvim_win_get_buf(win_id)
    return vim.b[bufnr][bufvar_myterm]
  end
end

--- close all my_term windows
M.close_all = function()
  for _, wi in ipairs(vim.fn.getwininfo()) do
    if wi.terminal == 1
      and string.match(vim.api.nvim_buf_get_name(wi.bufnr), 'term://.*' .. name_tag .. '%d+')  --- it is my_term
    then
      vim.api.nvim_win_close(wi.winid, 'force')
    end
  end
end

--- open all terms which are cached in global_my_term_cache and bufnr is valid.
M.open_all = function()
  for id, term_obj in pairs(global_my_term_cache) do
    if term_buf_exist(term_obj.bufnr) then
      local term_wins = vim.fn.getbufinfo(term_obj.bufnr)[1].windows
      if #term_wins < 1 then
        create_term_win(term_obj.bufnr)
      end
    end
  end
end

--- close all other terms except term_id
M.close_others = function(term_id)
  local t = global_my_term_cache[term_id]
  if not t then
    Notify('term: "' .. term_id .. '" is not exist', "WARN")
    return
  end

  for _, term_obj in pairs(global_my_term_cache) do
    if term_buf_exist(term_obj.bufnr) and term_obj.bufnr ~= t.bufnr then
      local wins = vim.fn.getbufinfo(term_obj.bufnr)[1].windows
      for _, w in ipairs(wins) do
        vim.api.nvim_win_close(w, 'force')
      end
    end
  end
end

M.wipeout_others = function(term_id)
  local t = global_my_term_cache[term_id]
  if not t then
    Notify('term: "' .. term_id .. '" is not exist', "WARN")
    return
  end

  for _, term_obj in pairs(global_my_term_cache) do
    if term_buf_exist(term_obj.bufnr) and term_obj.bufnr ~= t.bufnr then
      vim.api.nvim_buf_delete(term_obj.bufnr, {force=true})
    end
  end
end

--- close all first, then open all
M.toggle_all = function()
  --- 获取所有的 my_term windows
  local open_winid_list= {}
  for _, wi in ipairs(vim.fn.getwininfo()) do
    if wi.terminal == 1
      and string.match(vim.api.nvim_buf_get_name(wi.bufnr), 'term://.*' .. name_tag .. '%d+')  --- it is my_term
    then
      table.insert(open_winid_list, wi.winid)
    end
  end

  --- 如果有任何 my_term window 是打开的状态, 则全部关闭.
  if #open_winid_list > 0 then
    for _, win_id in ipairs(open_winid_list) do
      vim.api.nvim_win_close(win_id, 'force')
    end
    return
  end

  --- 如果所有 my_term window 都是关闭状态, 则 open_all()
  M.open_all()
end

--- terminate 之后, 如果要使用相同 id 的 terminal 需要重新 new()
M.__terminate = function(term_id)
  local t = global_my_term_cache[term_id]
  if not t then
    return
  end

  if term_buf_exist(t.bufnr) then
    vim.api.nvim_buf_delete(t.bufnr, {force=true})
  end

  --- clear global cache and delete terminal
  global_my_term_cache[t.id] = nil
end

--- debug ------------------------------------------------------------------------------------------
function Get_all_my_terms()
  vim.print(global_my_term_cache)
end

function Remove_my_term_by_id(id)
  M.__terminate(id)
end

function Get_my_term_by_id(id)
  return M.get_term_by_id(id) or M.new({id=id})
end

return M
