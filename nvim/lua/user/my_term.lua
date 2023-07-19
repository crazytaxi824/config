--- open terminal at bottom only.
--- NOTE: my_term 和 id 绑定, 同时只能有 0/1 个 buffer, 可能会有多个 window 显示.

-- local M = {}

local name_tag=';#my_term#'

local global_my_term_cache = {}

local default_opts = {
  cmd = vim.go.shell,  --- 相当于 os.getenv('SHELL')
  startinsert = true,
  jobdone_exit = true,
  win_height = 16,
  id = 1,  -- v:count1
}

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

--- private functions
local function __start_insert(startinsert, win_id)
  if startinsert then
    --- go back to terminal window for `:startinsert`
    if win_id and vim.fn.win_gotoid(win_id) == 1 then
      vim.cmd('startinsert')
    else
      vim.notify("win_id: " .. win_id .. " is not exist", vim.log.levels.WARN)
    end
  end
end

--- 根据 term name_tag :bwipeout terminal buffer.
local function __jobdone_autocmd(term_obj)
  vim.api.nvim_create_autocmd("TermClose", {
    buffer = term_obj.bufnr,
    callback = function(params)
      if term_obj.jobdone_exit then
        vim.cmd('bwipeout ' .. params.buf)
      else
        vim.cmd('stopinsert')
      end
    end
  })
end

--- terminal open and exec command
local function __exec_cmd(term_obj, win_id)
  if win_id and vim.fn.win_gotoid(win_id) == 1 then
    --- 使用 termopen() 开打 terminal
    local cmd = term_obj.cmd .. name_tag  .. term_obj.id
    term_obj.job_id = vim.fn.termopen(cmd)
  else
    vim.notify("win_id: " .. win_id .. " is not exist", vim.log.levels.WARN)
  end
end

--- NOTE: 创建一个 window 用于 terminal 运行.
local function __create_new_term_win(term_obj)
  local exist_win_id = __find_exist_term_win()

  if vim.fn.win_gotoid(exist_win_id) == 1 then
    vim.cmd('vertical rightbelow new')  --- at least 1 terminal window exist
  else
    vim.cmd('horizontal botright ' .. term_obj.win_height .. 'new')  --- no terminal window exist
  end

  local win_id = vim.api.nvim_get_current_win()
  term_obj.bufnr = vim.api.nvim_get_current_buf()
  vim.bo[term_obj.bufnr].buflisted = false

  return win_id
end

local function __reload_exist_term_buffer(term_obj)
  local exist_win_id = __find_exist_term_win()

  if vim.fn.win_gotoid(exist_win_id) == 1 then
    vim.cmd('vertical rightbelow sbuffer ' .. term_obj.bufnr)  --- at least 1 terminal window exist
  else
    vim.cmd('horizontal botright sbuffer' .. term_obj.bufnr .. ' | resize ' .. term_obj.win_height)  --- no terminal window exist
  end

  term_obj.win_id = vim.api.nvim_get_current_win()
end

local function __term_buf_exist(term_obj)
  if term_obj.bufnr and vim.fn.bufexists(term_obj.bufnr) == 1 then
    return true
  end
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
function NewTerm(opts)
  opts = opts or {}
  local my_term = vim.tbl_deep_extend('force', default_opts, opts)

  my_term.run = function()
    --- first: open a window for terminal, get win_id.
    if __term_buf_exist(my_term) then
      --- TODO scrach buffer
      -- local scratch_bufnr = vim.api.nvim_create_buf(false, true)

      vim.cmd('bw '..my_term.bufnr)
    end

    local win_id = __create_new_term_win(my_term)

    __exec_cmd(my_term, win_id)

    __jobdone_autocmd(my_term)

    --- TODO: hooks on_open

    __start_insert(my_term.startinsert, win_id)  --- NOTE: after exec cmd, 单独执行避免过程中跳转到其他 window.
  end

  my_term.open = function()
    if __term_buf_exist(my_term) then
      __reload_exist_term_buffer(my_term)
    else
      vim.notify('Terminal: "#' .. my_term.id .. '" is not Active', vim.log.levels.WARN)
    end
  end

  return my_term
end
