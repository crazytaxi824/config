--- open terminal at bottom only.
--- NOTE: my_term 和 id 绑定, 同时只能有 0/1 个 buffer, bufnr 可能会变更.
--- my_term 可能会有多个 window 同时显示, win_id 随时可能变化. getbufinfo(bufnr) -> windows
--- startinsert & stopinsert 慎用. mode 是全局的, 无论 cursor 在哪一个 window 都会改变 mode,
--- 所以很有可能会受到 win_gotoid() 的影响.

--- 原理: nvim_create_buf() -> <cmd>botright sbuffer bufnr -> win_gotoid(win_id) -> termopen(cmd)

--- TODO:
--- jobstart() -> termopen()
--- auto_scroll
--- on_stdout, on_stderr

local M = {}

local global_my_term_cache = {}

local name_tag=';#my_term#'

local win_height = 16  -- persist window height

local default_opts = {
  id = 1,  -- v:count1, 保证每个 id 只和一个 bufnr 对应
  cmd = vim.go.shell,  -- 相当于 os.getenv('SHELL')

  startinsert = nil, -- true | false, 第一次 run() 的时候触发 startinsert, 在 goto previous window 的情况下不适用.
  jobdone = nil,  -- 'exit' | 'stopinsert'

  --- callback function
  on_init = nil,  -- func(term), new()
  on_open = nil,  -- func(term), BufWinEnter
  on_close = nil, -- func(term), BufWinLeave
  on_stdout = nil, -- func(term, jobid, data, event)
  on_stderr = nil, -- func(term, jobid, data, event)
  on_exit = nil,   -- func(term), TermClose, jobstop()
  before_exec = nil, -- func(term), run() before exec, 可以用检查/修改设置.
  after_exec = nil,  -- func(term), run() after exec, 不等待 jobdone. NOTE: 可用于 goto previous window.

  --- private property, should not be readonly.
  _bufnr = nil,
  _job_id = nil,
}

--- 调大/调小 terminal window
local function __keymap_resize(bufnr)
  local opt = {buffer = bufnr, silent = true, noremap = true}
  vim.keymap.set('n', 't<Up>', '<cmd>resize +5<CR>', opt)
  vim.keymap.set('n', 't<Down>', '<cmd>resize -5<CR>', opt)
end

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

--- 判断 terminal bufnr 是否存在, 是否有效.
local function __term_buf_exist(term_obj)
  if term_obj._bufnr and vim.api.nvim_buf_is_valid(term_obj._bufnr) then
    return true
  end
end

--- 根据 terminal bufnr 来触发 autocmd ------------------------------------------------------------- {{{
local function __autocmd_callback(term_obj)
  --- NOTE: 第一次运行 terminal 时触发 TermOpen, 但不会触发 BufWinEnter.
  --- 关闭 terminal window 之后再打开时触发 BufWinEnter, 但不会触发 TermOpen.
  vim.api.nvim_create_autocmd({"TermOpen", "BufWinEnter"}, {
    buffer = term_obj._bufnr,
    callback = function(params)
      if term_obj.on_open then
        term_obj.on_open(term_obj)
      end
    end
  })

  vim.api.nvim_create_autocmd("BufWinLeave", {
    buffer = term_obj._bufnr,
    callback = function(params)
      --- persist window height
      win_height = vim.api.nvim_win_get_height(vim.api.nvim_get_current_win())

      if term_obj.on_close then
        term_obj.on_close(term_obj)
      end
    end
  })
end
-- -- }}}

--- 使用 termopen() 执行 cmd.
local function __exec_cmd(term_obj)
  --- callback
  if term_obj.before_exec then
    term_obj.before_exec(term_obj)
  end

  --- 使用 termopen() 开打 terminal
  term_obj._job_id = vim.fn.termopen(term_obj.cmd .. name_tag  .. term_obj.id, {
    on_stdout = function(job_id, data, event)  -- event 是 'stdout'
      vim.api.nvim_buf_call(term_obj._bufnr, function()
        local info = vim.api.nvim_get_mode()
        if info and (info.mode == "n" or info.mode == "nt") then vim.cmd("normal! G") end
      end)
      if term_obj.on_stdout then
        term_obj.on_stdout(term_obj, job_id, data, event)
      end
    end,

    on_stderr = function(job_id, data, event)  -- event 是 'stdout'
      vim.print(job_id, data, event)
      vim.api.nvim_buf_call(term_obj._bufnr, function()
        local info = vim.api.nvim_get_mode()
        if info and (info.mode == "n" or info.mode == "nt") then vim.cmd("normal! G") end
      end)
      if term_obj.on_stderr then
        term_obj.on_stderr(term_obj, job_id, data, event)
      end
    end,

    on_exit = function(job_id, exit_code, event)  -- event 是 'exit'
      if term_obj.on_exit then
        term_obj.on_exit(term_obj, job_id, exit_code, event)
      end

      if term_obj.jobdone == 'exit' then
        --- VVI: 必须使用 `:silent! bwipeout! bufnr` 否则手动删除 buffer 时会触发 TermClose, 导致重复 wipeout buffer 而报错.
        pcall(vim.api.nvim_buf_delete, term_obj._bufnr, {force=true})
      elseif term_obj.jobdone == 'stopinsert' then
        vim.cmd('stopinsert')
      end
    end
  })

  --- callback
  if term_obj.after_exec then
    term_obj.after_exec(term_obj)
  end
end

--- 创建一个 window 用于 terminal 运行 ------------------------------------------------------------- {{{
--- creat: 创建一个 window, load scratch buffer 用于执行 termopen()
--- load:  创建一个 window, load exist terminal buffer.
local function __open_term_win(term_obj)
  local exist_win_id = __find_exist_term_win()
  if vim.fn.win_gotoid(exist_win_id) == 1 then
    --- at least 1 terminal window exist
    vim.cmd('vertical rightbelow sbuffer ' .. term_obj._bufnr)
  else
    --- no terminal window exist, create a botright window for terminals.
    vim.cmd('horizontal botright sbuffer' .. term_obj._bufnr .. ' | resize ' .. win_height)
  end

  --- return win_id
  return vim.api.nvim_get_current_win()
end
-- -- }}}

--- 进入指定的 terminal window. 用于 run() 函数 ---------------------------------------------------- {{{
local function __prepare_term_win(term_obj)
  --- 如果 term buffer 不存在: 创建一个新的 term window.
  if not __term_buf_exist(term_obj) then
    term_obj._bufnr = vim.api.nvim_create_buf(false, true)  -- nobuflisted scratch buffer
    return __open_term_win(term_obj)
  end

  --- 这里是为了 re-use term window
  local win_id
  local term_wins = vim.fn.getbufinfo(term_obj._bufnr)[1].windows
  if #term_wins > 0 and vim.fn.win_gotoid(term_wins[1]) == 1 then
    --- 如果 term buffer 存在, 同时 window 存在:
    --- 创建一个 scratch buffer, 加载到当前 term window 中, 然后 wipeout term buffer.
    win_id = term_wins[1]
    local term_bufnr = term_obj._bufnr
    term_obj._bufnr = vim.api.nvim_create_buf(false, true)  -- nobuflisted scratch buffer

    --- 先 load scratch buffer, 再 wipeout 之前的 terminal buffer, 否则会导致 window close.
    vim.api.nvim_set_current_buf(term_obj._bufnr)  -- ':buffer term_obj._bufnr'
    vim.api.nvim_buf_delete(term_bufnr, {force=true})
  else
    --- 如果 term buffer 存在, 但是 window 不存在:
    --- 先 wipeout term buffer, 然后创建一个新的 term window 加载 scratch buffer.
    vim.api.nvim_buf_delete(term_obj._bufnr, {force=true})
    term_obj._bufnr = vim.api.nvim_create_buf(false, true)  -- nobuflisted scratch buffer
    win_id = __open_term_win(term_obj)
  end

  return win_id
end
-- -- }}}

--- return an term object
M.get_term_by_id = function(id)
  return global_my_term_cache[id]
end

M.new = function(opts)
  opts = vim.tbl_deep_extend('force', default_opts, opts or {})

  --- 已经存在的 terminal
  if global_my_term_cache[opts.id] then
    vim.notify('terminal instance is already exist, please use function "get_term_by_id()"', vim.log.levels.WARN)
    return global_my_term_cache[opts.id]
  end
  -- local my_term = vim.tbl_deep_extend('force', global_my_term_cache[opts.id] or {}, opts)

  --- 新的 terminal
  local my_term = opts
  global_my_term_cache[my_term.id] = my_term

  if my_term.on_init then
    my_term.on_init(my_term)
  end

  my_term.run = function()
    if my_term.status() == -1 then
      Notify("job_id is still running, please use `term.stop()` first.", "WARN", {title="my_term"})
      return
    end

    local term_win_id = __prepare_term_win(my_term)

    --- VVI: 以下函数放在后面运行主要是为了保证获取到 bufnr.
    __autocmd_callback(my_term)
    __keymap_resize(my_term._bufnr)

    if term_win_id and vim.fn.win_gotoid(term_win_id) == 1 then
      __exec_cmd(my_term)
    else
      error("term_win_id: " .. term_win_id .. " is not exist")
    end
  end

  --- unlisted scratch buffer termopen(cmd)
  my_term.spawn = function()
    if my_term.status() == -1 then
      Notify("job_id is still running, please use `term.stop()` first.", "WARN", {title="my_term"})
      return
    end

    --- 如果 term bufnr 存在则删除, 因为 termopen() 不能用在 modified buffer 上.
    if __term_buf_exist(my_term) then
      vim.api.nvim_buf_delete(my_term._bufnr, {force=true})
    end

    --- 生成一个新的 scratch buffer 用于执行 termopen()
    my_term._bufnr = vim.api.nvim_create_buf(false, true)  -- nobuflisted scratch buffer
    vim.api.nvim_buf_call(my_term._bufnr, function()
      __exec_cmd(my_term)
    end)
  end

  --- 终止 job, 会触发 jobdone.
  my_term.stop = function()
    if my_term._job_id then
      vim.fn.jobstop(my_term._job_id)
    end
  end

  my_term.open_win = function()
    if __term_buf_exist(my_term) then
      local wins = vim.fn.getbufinfo(my_term._bufnr)[1].windows
      if #wins > 0 then
        if vim.fn.win_gotoid(wins[1]) == 0 then
          error('vim cannot win_gotoid(' .. wins[1] .. ')')
        end
      else
        __open_term_win(my_term)
      end

      return true
    end
  end

  my_term.close_win = function()
    if __term_buf_exist(my_term) then
      local wins = vim.fn.getbufinfo(my_term._bufnr)[1].windows
      for _, w in ipairs(wins) do
        vim.api.nvim_win_close(w, 'force')
      end
    end
  end

  --- 清除 terminal opts
  my_term.clear = function()
    my_term = default_opts
  end

  my_term.status = function()
    --- `:help jobwait()`
    return vim.fn.jobwait({my_term._job_id}, 0)[1]
  end

  --- terminate 之后, 如果要使用相同 id 的 terminal 需要重新 New()
  my_term.__terminate = function()
    if my_term._bufnr and vim.api.nvim_buf_is_valid(my_term._bufnr) then
      vim.api.nvim_buf_delete(my_term._bufnr, {force=true})
    end

    --- clear global cache and delete terminal
    global_my_term_cache[my_term.id] = nil
    my_term = nil
  end

  my_term.__debug = function()
    vim.print(global_my_term_cache)
  end

  return my_term
end

M.close_all = function()
  for _, wi in ipairs(vim.fn.getwininfo()) do
    if wi.terminal == 1
      and string.match(vim.api.nvim_buf_get_name(wi.bufnr), 'term://.*' .. name_tag .. '%d+')  --- it is my_term
    then
      vim.api.nvim_win_close(wi.winid, 'force')
    end
  end
end

M.open_all = function()
  for id, term_obj in pairs(global_my_term_cache) do
    if __term_buf_exist(term_obj) then
      local term_wins = vim.fn.getbufinfo(term_obj._bufnr)[1].windows
      if #term_wins < 1 then
        __open_term_win(term_obj)
      end
    end
  end
end

M.toggle_all = function()
  local open_winid_list= {}

  for _, wi in ipairs(vim.fn.getwininfo()) do
    if wi.terminal == 1
      and string.match(vim.api.nvim_buf_get_name(wi.bufnr), 'term://.*' .. name_tag .. '%d+')  --- it is my_term
    then
      table.insert(open_winid_list, wi.winid)
    end
  end

  if #open_winid_list > 0 then
    for _, win_id in ipairs(open_winid_list) do
      vim.api.nvim_win_close(win_id, 'force')
    end
    return
  end

  M.open_all()
end

return M
