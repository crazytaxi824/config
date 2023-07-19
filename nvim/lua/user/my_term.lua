--- open terminal at bottom only.
--- NOTE: my_term 和 id 绑定, 同时只能有 0/1 个 buffer, 可能会有多个 window 显示.
--- getbufinfo(bufnr) -> windows

-- local M = {}

local global_my_term_cache = {}

local name_tag=';#my_term#'

local win_height = 16  -- persist window height

local default_opts = {
  cmd = vim.go.shell,  --- 相当于 os.getenv('SHELL')
  startinsert = true,
  jobdone_exit = true,
  id = 1,  -- v:count1, 保证每个 id 只和一个 bufnr 对应
}

--- 调大/调小 terminal window
local function __keymap_resize(bufnr)
  local opt = {buffer = bufnr, silent = true, noremap = true}
  vim.keymap.set('n', 't<Up>', '<cmd>resize +5<CR>', opt)
  vim.keymap.set('n', 't<Down>', '<cmd>resize -5<CR>', opt)
end

--- 判断当前 windows 中是否有 my_term window, 返回 win_id.
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

--- 判断 terminal bufnr 是否存在, 是否有效.
local function __term_buf_exist(term_obj)
  if term_obj.bufnr and vim.fn.bufexists(term_obj.bufnr) == 1 then
    return true
  end
end

--- 根据 terminal bufnr 来 wipeout terminal buffer.
local function __autocmd_jobdone(term_obj)
  vim.api.nvim_create_autocmd("TermClose", {
    buffer = term_obj.bufnr,
    callback = function(params)
      if term_obj.on_exit then
        term_obj.on_exit(term_obj)
      end

      if term_obj.jobdone_exit then
        --- 必须使用 silent 否则可能因为重复 wipeout buffer 而报错.
        vim.cmd('silent! bwipeout! ' .. params.buf)
      end
    end
  })
end

--- terminal window open/close 时的 autocmd
local function __autocmd_open_close(term_obj)
  vim.api.nvim_create_autocmd({"BufWinEnter", "BufWinLeave"}, {
    buffer = term_obj.bufnr,
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
local function __exec_cmd(term_obj, win_id, prev_win_id)
  if win_id and vim.fn.win_gotoid(win_id) == 1 then
    --- 使用 termopen() 开打 terminal
    local cmd = term_obj.cmd .. name_tag  .. term_obj.id
    term_obj.job_id = vim.fn.termopen(cmd)

    --- VVI: goto prev_win 必须放在最后执行.
    if vim.fn.win_gotoid(prev_win_id) == 0 and term_obj.startinsert then
      vim.cmd('startinsert')
    end
  else
    vim.notify("win_id: " .. win_id .. " is not exist", vim.log.levels.ERROR)
  end
end

--- 创建一个 window 用于 terminal 运行.
local function __create_new_term_win(term_obj)
  term_obj.bufnr = vim.api.nvim_create_buf(false, true)  -- nobuflisted scratch buffer

  local exist_win_id = __find_exist_term_win()
  if vim.fn.win_gotoid(exist_win_id) == 1 then
    -- vim.cmd('vertical rightbelow new')  --- at least 1 terminal window exist
    vim.cmd('vertical rightbelow sbuffer ' .. term_obj.bufnr)  --- at least 1 terminal window exist
  else
    vim.cmd('horizontal botright sbuffer' .. term_obj.bufnr .. ' | resize ' .. win_height)  --- no terminal window exist
  end

  --- return win_id
  return vim.api.nvim_get_current_win()
end

--- 创建一个新的 window 用于加载 exist terminal bufnr.
local function __reload_exist_term_buffer(term_obj)
  local exist_win_id = __find_exist_term_win()

  if vim.fn.win_gotoid(exist_win_id) == 1 then
    vim.cmd('vertical rightbelow sbuffer ' .. term_obj.bufnr)  --- at least 1 terminal window exist
  else
    vim.cmd('horizontal botright sbuffer' .. term_obj.bufnr .. ' | resize ' .. win_height)  --- no terminal window exist
  end

  --- return win_id
  return vim.api.nvim_get_current_win()
end

--- 进入指定的 terminal window. 用于 run() 函数.
local function __enter_term_win(term_obj)
  local win_id

  --- 这里是为了 re-use term window
  if __term_buf_exist(term_obj) then
    local term_wins = vim.fn.getbufinfo(term_obj.bufnr)[1].windows
    if #term_wins > 0 and vim.fn.win_gotoid(term_wins[1]) == 1 then
      --- 如果 term buffer 存在, 同时 window 存在:
      --- 创建一个 scratch buffer, 加载到当前 term window 中, 然后 wipeout term buffer.
      win_id = term_wins[1]
      local term_bufnr = term_obj.bufnr
      term_obj.bufnr = vim.api.nvim_create_buf(false, true)

      vim.cmd('buffer ' .. term_obj.bufnr)
      vim.cmd('bwipeout! '.. term_bufnr)
    else
      --- 如果 term buffer 存在, 但是 window 不存在:
      --- 先 wipeout term buffer, 然后创建一个新的 term window. 因为 create_new_term_win 会给 term.bufnr 重新赋值.
      vim.cmd('bwipeout! '..term_obj.bufnr)
      win_id = __create_new_term_win(term_obj)
    end
  else
    --- 如果 term buffer 不存在: 创建一个新的 term window.
    win_id = __create_new_term_win(term_obj)
  end

  return win_id
end

--- set quickfix list for terminal list. --- {{{
-- local function set_term_qf(win_id, opts)
--   local bufnr = vim.api.nvim_win_get_buf(win_id)
--   vim.fn.setqflist({{bufnr=bufnr, module="my_term" .. opts.id}}, 'a')
--   vim.cmd('vertical botright copen 20')  -- 最小值为 20
--   vim.fn.win_gotoid(win_id)  -- go back to terminal window for `:startinsert`
-- end
-- -- }}}

--- return an term object
function GetTerm(id)
  return global_my_term_cache[id]
end

function New(opts)
  opts = opts or {}
  opts = vim.tbl_deep_extend('force', default_opts, opts)

  --- 已经存在的 terminal
  if global_my_term_cache[opts.id] then
    vim.notify('terminal instance is already exist, please use function "get_term(id)"', vim.log.levels.WARN)
    return global_my_term_cache[opts.id]
  end

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
    __keymap_resize(my_term.bufnr)

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
      local wins = vim.fn.getbufinfo(my_term.bufnr)[1].windows
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
    vim.fn.jobstop(my_term.job_id)
  end

  --- terminate 之后, 如果要使用相同 id 的 terminal 需要重新 New()
  my_term.terminate = function()
    if my_term.bufnr and vim.fn.bufexists(my_term.bufnr) == 1 then
      vim.cmd('bwipeout! ' .. my_term.bufnr)
    end

    --- clear global cache and delete terminal
    global_my_term_cache[my_term.id] = nil
    my_term = nil
  end

  my_term.debug = function()
    print(global_my_term_cache[my_term.id])
  end

  return my_term
end
