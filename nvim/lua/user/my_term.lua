--- open terminal at bottom only.
--- NOTE: my_term 和 id 绑定, 同时只能有 0/1 个 buffer, bufnr 可能会变更.
--- my_term 可能会有多个 window 同时显示, win_id 随时可能变化. getbufinfo(bufnr) -> windows
--- startinsert & stopinsert 慎用. mode 是全局的, 无论 cursor 在哪一个 window 都会改变 mode,
--- 所以很有可能会受到 win_gotoid() 的影响.

--- 原理: nvim_create_buf() -> <cmd>botright sbuffer bufnr -> win_gotoid(win_id) -> termopen(cmd)

--- TODO:
--- setmetatable() 将 methods 和 private properties 放在 metatable 中, 如果被 tbl_deep_extend 则无法使用 methods.
--- tbl_deep_extend() 无法 extend metatable.

local M = {}

local global_my_term_cache = {}  -- map-like table { id:term_obj }

local name_tag=';#my_term#'

local win_height = 16  -- persist window height

--- default_opts 相当于 global setting.
local default_opts = {
  --- VVI: 这三个属性不应该被外部手动修改.
  id = 1,  -- v:count1, VVI: 保证每个 id 只和一个 bufnr 对应. id 一旦设置应该无法改变.
  bufnr = nil,
  job_id = nil,

  cmd = vim.go.shell, -- 相当于 os.getenv('SHELL')
  startinsert = nil,  -- true | false, 在 before_exec() 之前触发.
  jobdone = nil,      -- 'exit' | 'stopinsert', on_exit() 时触发, 执行 `:silent! bwipeout! term_bufnr`
  auto_scroll = nil,  -- goto bottom of the terminal. 会影响 `:startinsert`

  --- callback function
  on_init = nil,  -- func(term), new()
  on_open = nil,  -- func(term), BufWinEnter
  on_close = nil, -- func(term), BufWinLeave
  on_stdout = nil, -- func(term, jobid, data, event), 可用于 auto_scroll.
  on_stderr = nil, -- func(term, jobid, data, event), 可用于 auto_scroll.
  on_exit = nil,   -- func(term, job_id, exit_code, event), TermClose, jobstop(), 可用于 `:silent! bwipeout! term_bufnr`
  before_exec = nil, -- func(term), run() before exec, 可以用于检查/修改设置, keymap.set()
  after_exec = nil,  -- func(term), run() after exec, 不等待 jobdone. NOTE: 可用于 win_gotoid(prev_win)
}

--- keymaps: terminal window 调大/调小 ------------------------------------------------------------- {{{
local function __keymaps(bufnr)
  local opt = {buffer = bufnr, silent = true, noremap = true}
  vim.keymap.set('n', 't<Up>', '<cmd>resize +5<CR>', opt)
  vim.keymap.set('n', 't<Down>', '<cmd>resize -5<CR>', opt)
end
-- -- }}}

--- 判断当前 windows 中是否有 my_term window, 返回 win_id ------------------------------------------ {{{
local function __find_exist_term_win()
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
local function __term_buf_exist(bufnr)
  if bufnr and vim.api.nvim_buf_is_valid(bufnr) then
    return true
  end
end
-- -- }}}

--- auto_scroll ------------------------------------------------------------------------------------ {{{
local function __auto_scroll(term_obj)
  if term_obj.auto_scroll then
    vim.api.nvim_buf_call(term_obj.bufnr, function()
      local info = vim.api.nvim_get_mode()
      if info and (info.mode == "n" or info.mode == "nt") then vim.cmd("normal! G") end
    end)
  end
end
-- -- }}}

--- autocmd: 根据 terminal bufnr 触发 -------------------------------------------------------------- {{{
local function __autocmd_callback(term_obj)
  --- NOTE: 第一次运行 terminal 时触发 TermOpen, 但不会触发 BufWinEnter.
  --- 关闭 terminal window 之后再打开时触发 BufWinEnter, 但不会触发 TermOpen.
  local g_id = vim.api.nvim_create_augroup('my_term_' .. term_obj.id, {clear=true})
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

--- 使用 termopen() 执行 cmd ----------------------------------------------------------------------- {{{
local function __exec_cmd(term_obj)
  --- callback
  if term_obj.before_exec then
    term_obj.before_exec(term_obj)
  end

  --- startinsert option
  if term_obj.startinsert then
    vim.cmd('startinsert')
  end

  --- 使用 termopen() 开打 terminal
  term_obj.job_id = vim.fn.termopen(term_obj.cmd .. name_tag  .. term_obj.id, {
    on_stdout = function(job_id, data, event)  -- event 是 'stdout'
      --- auto_scroll option
      __auto_scroll(term_obj)

      --- callback
      if term_obj.on_stdout then
        term_obj.on_stdout(term_obj, job_id, data, event)
      end
    end,

    on_stderr = function(job_id, data, event)  -- event 是 'stderr'
      --- auto_scroll option
      __auto_scroll(term_obj)

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
        vim.cmd('stopinsert')
      end
    end,
  })

  --- callback
  if term_obj.after_exec then
    term_obj.after_exec(term_obj)
  end
end
-- -- }}}

--- 创建一个 window 用于 terminal 运行 ------------------------------------------------------------- {{{
--- creat: 创建一个 window, load scratch buffer 用于执行 termopen()
--- load:  创建一个 window, load exist terminal buffer.
local function __open_term_win(term_obj)
  local exist_win_id = __find_exist_term_win()
  if vim.fn.win_gotoid(exist_win_id) == 1 then
    --- at least 1 terminal window exist
    vim.cmd('vertical rightbelow sbuffer ' .. term_obj.bufnr)
  else
    --- no terminal window exist, create a botright window for terminals.
    vim.cmd('horizontal botright sbuffer' .. term_obj.bufnr .. ' | resize ' .. win_height)
  end

  --- return win_id
  return vim.api.nvim_get_current_win()
end
-- -- }}}

--- 进入指定的 terminal window. 用于 run() --------------------------------------------------------- {{{
--- NOTE: buffer 一旦运行过 termopen() 就不能再次运行了, Can only call this function in an unmodified buffer.
--- 所以需要删除旧的 bufnr 然后重新创建一个新的 scratch_bufnr 给 termopen() 使用.
local function __prepare_term_win(term_obj)
  local cache_term_bufnr = term_obj.bufnr
  term_obj.bufnr = vim.api.nvim_create_buf(false, true)  -- nobuflisted scratch buffer

  --- VVI: autocmd 放在这里运行主要是有两个限制条件:
  --- 1. 在获取到 terminal bufnr 之后运行, 为了在 autocmd 中使用 bufnr 作为触发条件.
  --- 2. 在 term window 打开并加载 term bufnr 之前运行, 为了触发 BufWinEnter event.
  __autocmd_callback(term_obj)

  --- 如果 term buffer 不存在: 创建一个新的 term window.
  if not __term_buf_exist(cache_term_bufnr) then
    return __open_term_win(term_obj)
  end

  --- 这里是为了 re-use term window
  local win_id
  local term_wins = vim.fn.getbufinfo(cache_term_bufnr)[1].windows
  --- 这里使用 win_gotoid 是为了和下面行为保持一致.
  if #term_wins > 0 and vim.fn.win_gotoid(term_wins[1]) == 1 then
    --- 如果 term buffer 存在, 同时 window 存在:
    --- 创建一个 scratch buffer, 加载到当前 term window 中, 然后 wipeout term buffer.
    win_id = term_wins[1]

    --- 先 load scratch buffer, 再 wipeout 之前的 terminal buffer, 否则会导致 window close.
    vim.api.nvim_set_current_buf(term_obj.bufnr)  -- ':buffer term_obj.bufnr'
    vim.api.nvim_buf_delete(cache_term_bufnr, {force=true})
  else
    --- 如果 term buffer 存在, 但是 window 不存在:
    --- 先 wipeout term buffer, 然后创建一个新的 term window 加载 scratch buffer.
    vim.api.nvim_buf_delete(cache_term_bufnr, {force=true})
    win_id = __open_term_win(term_obj)
  end

  return win_id
end
-- -- }}}

--- set all term:methods() to metatable for terminal object.
local function metatable_funcs()
  local meta_funcs = {}

  function meta_funcs:run()
    if self:job_status() == -1 then
      Notify("job_id is still running, please use `term.stop()` first.", "WARN", {title="my_term"})
      return
    end

    local term_win_id = __prepare_term_win(self)

    __keymaps(self.bufnr)

    if vim.fn.win_gotoid(term_win_id) == 0 then
      error("term_win_id: " .. term_win_id .. " is not exist")
    end
    __exec_cmd(self)
  end

  --- 终止 job, 会触发 jobdone.
  function meta_funcs:stop()
    if self.job_id then
      vim.fn.jobstop(self.job_id)
    end
  end

  --- open terminal window or goto terminal window, return win_id
  function meta_funcs:open_win()
    if __term_buf_exist(self.bufnr) then
      local wins = vim.fn.getbufinfo(self.bufnr)[1].windows
      if #wins > 0 then
        --- 如果有 window 正在显示该 term buffer, 则跳转到该 window.
        if vim.fn.win_gotoid(wins[1]) == 0 then
          error('vim cannot win_gotoid(' .. wins[1] .. ')')
        end

        return wins[1]
      else
        --- 如果没有任何 window 显示该 termimal 则打开新的 window, 然后加载该 buffer.
        return __open_term_win(self)
      end
    end
  end

  --- close all windows which displays this term buffer.
  function meta_funcs:close_win()
    if __term_buf_exist(self.bufnr) then
      local wins = vim.fn.getbufinfo(self.bufnr)[1].windows
      for _, w in ipairs(wins) do
        vim.api.nvim_win_close(w, 'force')
      end
    end
  end

  --- 将 terminal 重置为 default_opts
  function meta_funcs:clear()
    --- VVI: 这里不能简单的使用 tbl_deep_extend() 因为:
    --- 1. tbl_deep_extend() 会重新生成一个 table, 导致 global_my_term_cache 中的 term object 无效.
    --- 2. tbl_deep_extend() 不会保留 metatable, 会导致所有的 methods 丢失.
    for key, value in pairs(default_opts) do
      self[key] = value
    end
  end

  --- 检查 terminal 运行情况.
  function meta_funcs:job_status()
    --- `:help jobwait()`
    return vim.fn.jobwait({self.job_id}, 0)[1]
  end

  --- terminate 之后, 如果要使用相同 id 的 terminal 需要重新 New()
  function meta_funcs:__terminate()
    if __term_buf_exist(self.bufnr) then
      vim.api.nvim_buf_delete(self.bufnr, {force=true})
    end

    --- clear global cache and delete terminal
    global_my_term_cache[self.id] = nil
    self = nil
  end

  function meta_funcs:__debug()
    vim.print(global_my_term_cache)
  end

  return meta_funcs
end

M.new = function(opts)
  opts = vim.tbl_deep_extend('force', default_opts, opts or {})

  --- 已经存在的 terminal
  if global_my_term_cache[opts.id] then
    vim.notify('terminal instance is already exist, please use function "get_term_by_id()"', vim.log.levels.WARN)
    return
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

  --- set all term:methods() to terminal object's metatable
  setmetatable(my_term, { __index = mt })

  return my_term
end

--- return an term object by id
M.get_term_by_id = function(id)
  return global_my_term_cache[id]
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
    if __term_buf_exist(term_obj.bufnr) then
      local term_wins = vim.fn.getbufinfo(term_obj.bufnr)[1].windows
      if #term_wins < 1 then
        __open_term_win(term_obj)
      end
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

return M
