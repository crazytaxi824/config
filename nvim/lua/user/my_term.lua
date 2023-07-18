local M = {}

local name_tag=';#my_term#'

local default_opts = {
  cmd = os.getenv("SHELL"),  -- bash | zsh | ...
  startinsert = true,
  jobdone_exit = true,
  win_height = 12,
  win_width = 60,
  count = 1,  -- v:count1
  direction = 'h'  -- 'v' 'vertical' | 'h' 'horizontal' | 'f' 'float'
}

local persist_size = {
  direction = 'horizontal',  -- horizontal | vertical
  win_height = 12,
  win_width = 60,
}

--- 根据 term name_tag wipeout terminal buffer.
local function jobdone_exit(opts)
  vim.api.nvim_create_autocmd("TermClose", {
    pattern = {'term://*' .. name_tag .. opts.count},
    once = true,
    callback = function(params)
      vim.cmd('bwipeout ' .. params.buf)
    end
  })
end

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

local function create_new_term_win(opts)
  local direction
  local new_win_cmd
  if opts.direction == 'v' or opts.direction == 'vert' or opts.direction == 'vertical' then
    direction = 'vertical'
    new_win_cmd = 'vertical botright ' .. opts.win_width .. 'new'
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
    direction = 'horizontal'
    new_win_cmd = 'horizontal botright ' .. opts.win_height .. 'new'
  end

  vim.cmd(new_win_cmd)
  local win_id = vim.api.nvim_get_current_win()
  vim.api.nvim_win_set_var(win_id, "my_term", {direction = direction})

  --- return win_id
  return win_id
end

--- create a terminal window at bottom of the screen with hight=12
function Create_term(cmd, opts)
  --- TODO 判断 #my_term#opts.count buffer 是否存在.

  cmd = cmd or os.getenv('SHELL')
  opts = opts or {}
  opts = vim.tbl_deep_extend('force', default_opts, opts)

  --- first: open a window for terminal, get win_id.
  local win_id = create_new_term_win(opts)

  --- TODO: set winvar for terminal
  -- nvim_win_set_var()

  if opts.jobdone_exit then
    jobdone_exit(opts)
  end

  open_term(cmd, opts)
end



