--- open terminal at bottom only.
--- NOTE: my_term 和 id 绑定, 同时只能有 0/1 个 buffer, bufnr 可能会变更.
--- my_term 可能会有多个 window 同时显示, win_id 随时可能变化. getbufinfo(bufnr) -> windows
--- startinsert & stopinsert 尽量不要用. mode 是全局的, 不论 cursor 在哪一个 window 都会改变 mode.
--- 可能会受到 win_gotoid() 的影响.

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
  on_exit = nil,  -- func(term), TermClose
  before_exec = nil, -- func(term), run() before exec
  after_exec = nil,  -- func(term), run() after exec

  --- private property, should not be readonly.
  -- _bufnr = nil,
  -- _job_id = nil,
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
    if wi.terminal == 1
      and string.match(vim.api.nvim_buf_get_name(wi.bufnr), 'term://.*' .. name_tag .. '%d+')  --- it is my_term
      and wi.winid > win_id
    then
      win_id = wi.winid
    end
  end
  if win_id < 0 then
    return nil
  else
    return win_id
  end
end
-- -- }}}

--- 判断 terminal bufnr 是否存在, 是否有效.
local function __term_buf_exist(term_obj)
  if term_obj._bufnr and vim.fn.bufexists(term_obj._bufnr) == 1 then
    return true
  end
end

--- 根据 terminal bufnr 来 wipeout terminal buffer.
local function __autocmd_jobdone(term_obj)
  vim.api.nvim_create_autocmd("TermClose", {
    buffer = term_obj._bufnr,
    callback = function(params)
      if term_obj.on_exit then
        term_obj.on_exit(term_obj)
      end

      if term_obj.jobdone == 'exit' then
        --- 必须使用 silent 否则可能因为重复 wipeout buffer 而报错.
        vim.cmd('silent! bwipeout! ' .. params.buf)
      elseif term_obj.jobdone == 'stopinsert' then
        vim.cmd('stopinsert')
      end
    end
  })
end

--- terminal window open/close 时的 autocmd
local function __autocmd_open_close(term_obj)
  vim.api.nvim_create_autocmd({"BufWinEnter", "BufWinLeave"}, {
    buffer = term_obj._bufnr,
    callback = function(params)
      if params.event == "BufWinEnter" and term_obj.on_open then
        term_obj.on_open(term_obj)
      end

      if params.event == "BufWinLeave" then
        --- persist window height
        win_height = vim.api.nvim_win_get_height(vim.api.nvim_get_current_win())

        if term_obj.on_close then
          term_obj.on_close(term_obj)
        end
      end
    end
  })
end

--- terminal goto win_id 执行 command, 然后`可选择`是否要返回 previous window.
--- 返回 previous window 不等待 jobdone. eg: 开启 http 服务后直接返回 previous window.
local function __exec_cmd(term_obj, term_win_id, prev_win_id)
  if term_win_id and vim.fn.win_gotoid(term_win_id) == 1 then
    --- 使用 termopen() 开打 terminal
    local cmd = term_obj.cmd .. name_tag  .. term_obj.id
    term_obj._job_id = vim.fn.termopen(cmd)

    --- VVI: goto previous window 必须放在最后执行.
    --- 如果需要 goto previous window 则不执行判 startinsert.
    if prev_win_id and vim.fn.win_gotoid(prev_win_id) == 0 then
      vim.notify("prev_win_id: " .. prev_win_id .. " is not exist", vim.log.levels.WARN)
    elseif not prev_win_id and term_obj.startinsert then
      vim.cmd('startinsert')
    end
  else
    vim.notify("term_win_id: " .. term_win_id .. " is not exist", vim.log.levels.ERROR)
  end
end

--- 创建一个 window 用于 terminal 运行 ------------------------------------------------------------- {{{
local function __create_new_term_win(term_obj)
  term_obj._bufnr = vim.api.nvim_create_buf(false, true)  -- nobuflisted scratch buffer

  local exist_win_id = __find_exist_term_win()
  if vim.fn.win_gotoid(exist_win_id) == 1 then
    -- vim.cmd('vertical rightbelow new')  --- at least 1 terminal window exist
    vim.cmd('vertical rightbelow sbuffer ' .. term_obj._bufnr)  --- at least 1 terminal window exist
  else
    vim.cmd('horizontal botright sbuffer' .. term_obj._bufnr .. ' | resize ' .. win_height)  --- no terminal window exist
  end

  --- return win_id
  return vim.api.nvim_get_current_win()
end
-- -- }}}

--- 创建一个新的 window 用于加载 exist terminal bufnr ---------------------------------------------- {{{
local function __reload_exist_term_buffer(term_obj)
  local exist_win_id = __find_exist_term_win()

  if vim.fn.win_gotoid(exist_win_id) == 1 then
    vim.cmd('vertical rightbelow sbuffer ' .. term_obj._bufnr)  --- at least 1 terminal window exist
  else
    vim.cmd('horizontal botright sbuffer' .. term_obj._bufnr .. ' | resize ' .. win_height)  --- no terminal window exist
  end

  --- return win_id
  return vim.api.nvim_get_current_win()
end
-- -- }}}

--- 进入指定的 terminal window. 用于 run() 函数 ---------------------------------------------------- {{{
local function __enter_term_win(term_obj)
  local win_id

  --- 这里是为了 re-use term window
  if __term_buf_exist(term_obj) then
    local term_wins = vim.fn.getbufinfo(term_obj._bufnr)[1].windows
    if #term_wins > 0 and vim.fn.win_gotoid(term_wins[1]) == 1 then
      --- 如果 term buffer 存在, 同时 window 存在:
      --- 创建一个 scratch buffer, 加载到当前 term window 中, 然后 wipeout term buffer.
      win_id = term_wins[1]
      local term_bufnr = term_obj._bufnr
      term_obj._bufnr = vim.api.nvim_create_buf(false, true)

      vim.cmd('buffer ' .. term_obj._bufnr)
      vim.cmd('bwipeout! '.. term_bufnr)
    else
      --- 如果 term buffer 存在, 但是 window 不存在:
      --- 先 wipeout term buffer, 然后创建一个新的 term window. 因为 create_new_term_win 会给 term.bufnr 重新赋值.
      vim.cmd('bwipeout! '..term_obj._bufnr)
      win_id = __create_new_term_win(term_obj)
    end
  else
    --- 如果 term buffer 不存在: 创建一个新的 term window.
    win_id = __create_new_term_win(term_obj)
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

  my_term.run = function(prev_win_id)
    local win_id = __enter_term_win(my_term)

    --- VVI: autocmd 放在这里运行主要是为了保证获取到 bufnr.
    __autocmd_jobdone(my_term)
    __autocmd_open_close(my_term)
    __keymap_resize(my_term._bufnr)

    if my_term.before_exec then
      my_term.before_exec(my_term, win_id)
    end

    __exec_cmd(my_term, win_id, prev_win_id)

    if my_term.after_exec then
      my_term.after_exec(my_term, win_id)
    end
  end

  my_term.open_win = function()
    if __term_buf_exist(my_term) then
      __reload_exist_term_buffer(my_term)
      return true
    end
    -- terminal buffer is not exist
    return false
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

  --- 终止 job, 会触发 jobdone.
  my_term.jobstop = function()
    vim.fn.jobstop(my_term._job_id)
  end

  --- terminate 之后, 如果要使用相同 id 的 terminal 需要重新 New()
  my_term.terminate = function()
    if my_term._bufnr and vim.fn.bufexists(my_term._bufnr) == 1 then
      vim.cmd('bwipeout! ' .. my_term._bufnr)
    end

    --- clear global cache and delete terminal
    global_my_term_cache[my_term.id] = nil
    my_term = nil
  end

  my_term._debug = function()
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
    -- nvim_win_set_buf()
    if __term_buf_exist(term_obj) then
      local term_wins = vim.fn.getbufinfo(term_obj._bufnr)[1].windows
      if #term_wins < 1 then
        __reload_exist_term_buffer(term_obj)
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
