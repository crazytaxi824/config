--- open terminal at bottom only.

-- local M = {}

local name_tag=';#my_term#'

local default_opts = {
  cmd = vim.go.shell,  --- 相当于 os.getenv('SHELL')
  startinsert = true,
  jobdone_exit = true,
  win_height = 16,
  count = 1,  -- v:count1
}

local function find_exist_term_win()
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

local function startinsert(win_id, opts)
  if opts.startinsert then
    --- go back to terminal window for `:startinsert`
    if vim.fn.win_gotoid(win_id) == 1 then
      vim.cmd('startinsert')
    end
  end
end

--- 根据 term name_tag :bwipeout terminal buffer.
local function jobdone_autocmd(opts, bufnr)
  vim.api.nvim_create_autocmd("TermClose", {
    buffer = bufnr,
    callback = function(params)
      if opts.jobdone_exit then
        vim.cmd('bwipeout ' .. params.buf)
      else
        vim.cmd('stopinsert')
      end
    end
  })
end

--- terminal open and exec command
local function open_term(win_id, opts)
  if vim.fn.win_gotoid(win_id) == 1 then
    --- 使用 termopen() 开打 terminal
    local cmd = opts.cmd .. name_tag  .. opts.count
    local job_id = vim.fn.termopen(cmd)
    return job_id
  end

  --- TODO; 如果 count 相同则 bw 之前的 buffer. 先打开新的 term 再删除就的
end

--- NOTE: 创建一个 window 用于 terminal 运行.
local function create_new_term_win(opts)
  local exist_win_id = find_exist_term_win()

  if exist_win_id and vim.fn.win_gotoid(exist_win_id) == 1 then
    vim.cmd('vertical rightbelow new')  --- at least 1 terminal window exist
  else
    vim.cmd('horizontal botright ' .. opts.win_height .. 'new')  --- no terminal window exist
  end

  local win_id = vim.api.nvim_get_current_win()
  local bufnr = vim.api.nvim_get_current_buf()
  vim.bo[bufnr].buflisted = false

  return win_id, bufnr
end

--- load a hidden term buffer to split window next to exist term window
function Reload_exist_term_buffer(bufnr)
  local exist_win_id = find_exist_term_win()

  if exist_win_id and vim.fn.win_gotoid(exist_win_id) == 1 then
    vim.cmd('vertical rightbelow sbuffer ' .. bufnr)  --- at least 1 terminal window exist
  else
    vim.cmd('horizontal botright sbuffer' .. bufnr .. ' | resize ' .. default_opts.win_height)  --- no terminal window exist
  end

  local win_id = vim.api.nvim_get_current_win()
  return win_id
end

--- set quickfix list for terminal list.
local function set_term_qf(win_id, opts)
  local bufnr = vim.api.nvim_win_get_buf(win_id)
  vim.fn.setqflist({{bufnr=bufnr, module="my_term" .. opts.count}}, 'a')
  vim.cmd('vertical botright copen 20')  -- 最小值为 20
  vim.fn.win_gotoid(win_id)  -- go back to terminal window for `:startinsert`
end

--- main terminal control function
function Create_term(opts)
  opts = opts or {}
  opts = vim.tbl_deep_extend('force', default_opts, opts)

  --- first: open a window for terminal, get win_id.
  local win_id, bufnr = create_new_term_win(opts)

  jobdone_autocmd(opts, bufnr)

  open_term(win_id, opts)

  --- NOTE: after exec cmd, 单独执行避免过程中跳转到其他 window.
  startinsert(win_id, opts)
end


