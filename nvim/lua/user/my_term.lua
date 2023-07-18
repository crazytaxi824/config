-- local M = {}

local name_tag=';#my_term#'

local default_opts = {
  cmd = os.getenv("SHELL"),  -- bash | zsh | ...
  startinsert = true,
  jobdone_exit = true,
  win_height = 12,
  win_width = 60,
  count = 1,  -- v:count1
  direction = 'horizontal'  -- 'v' 'vertical' | 'h' 'horizontal' | TODO; 'f' 'float'
}

local persist_size = {
  direction = default_opts.direction,
  win_height = default_opts.win_height,
  win_width = default_opts.win_width,
}

--- 根据 term name_tag :bwipeout terminal buffer.
local function jobdone_autocmd(opts)
  vim.api.nvim_create_autocmd("TermClose", {
    pattern = {'term://*' .. name_tag .. opts.count},
    once = true,
    callback = function(params)
      if opts.jobdone_exit then
        vim.cmd('bwipeout ' .. params.buf)
      else
        vim.cmd('stopinsert')
      end
    end
  })
end

--- terminal open command
local function open_term(cmd, opts)
  cmd = 'edit ' .. vim.fn.fnameescape('term://' .. cmd ..  name_tag  .. opts.count) .. ' | setlocal nobuflisted'
  if opts.startinsert then
    cmd = cmd .. ' | startinsert'
  end
  vim.cmd(cmd)

  --- 使用 termopen() 开打 terminal --- {{{
  -- cmd = cmd .. name_tag  .. opts.count
  -- vim.fn.termopen(cmd)
  -- if opts.startinsert then
  --   vim.cmd('startinsert')
  -- end
  -- -- }}}
end

--- 创建一个 window 用于 terminal 运行.
local function create_new_term_win(opts, split_cmd)
  split_cmd = split_cmd or "new"
  local new_win_cmd
  if opts.direction == 'v' or opts.direction == 'vert' or opts.direction == 'vertical' then
    new_win_cmd = 'vertical botright ' .. opts.win_width .. split_cmd
  --- TODO: float window --- {{{
  -- elseif opts.direction == 'f' or opts.direction == 'float' then
  --   local scratch_bufnr = vim.api.nvim_create_buf(false, {})  -- create a [scratch] buffer
  --   return vim.api.nvim_open_win(scratch_bufnr, true, {
  --     relative='editor',  -- 'win' | 'cursor' | 'editor'
  --     col = 12,  -- margin
  --     row = 3,   -- margin
  --     width = 80,  -- float win size
  --     height = 30, -- float win size
  --   })
  -- -- }}}
  else
    new_win_cmd = 'horizontal botright ' .. opts.win_height .. split_cmd
  end

  vim.cmd(new_win_cmd)
  local win_id = vim.api.nvim_get_current_win()

  --- return win_id
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
function Create_term(cmd, opts)
  --- TODO 判断 #my_term#opts.count buffer 是否存在.

  cmd = cmd or os.getenv('SHELL')
  opts = opts or {}
  opts = vim.tbl_deep_extend('force', default_opts, opts)

  --- first: open a window for terminal, get win_id.
  local win_id = create_new_term_win(opts)

  --- TODO: set winvar for terminal
  -- nvim_win_set_var()

  jobdone_autocmd(opts)

  open_term(cmd, opts)
end

--- change terminal direction
function Term_toggle_direction()
  local win_id = vim.api.nvim_get_current_win()
  local bufnr = vim.api.nvim_win_get_buf(win_id)

  if vim.fn.getwininfo(win_id)[1].terminal ~= 1 then
    vim.notify("this is not a terminal window", vim.log.levels.WARN)
    return
  end

  --- close current term window
  vim.api.nvim_win_close(win_id, 'force')

  if persist_size.direction == 'horizontal' then
    persist_size.direction = 'vertical'
  else
    persist_size.direction = 'horizontal'
  end

  --- open a new window for term
  create_new_term_win(persist_size, 'split')

  --- load term buffer
  vim.cmd(bufnr .. 'buf')
end

--- TODO: multi term window

--- TODO: attach a quickfix list.
