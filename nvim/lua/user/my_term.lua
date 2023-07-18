local M = {}

local name_tag=';#my_term#'

--- create a terminal window at bottom of the screen with hight=12
function Create_bot_term(cmd, opts)
  opts = opts or {}
  opts = vim.tbl_deep_extend('keep', opts, {
    startinsert = true,
    winheight = 12,
    count = 1,
    jobdone_exit = true,
  })

  --- first: open a window for terminal, get win_id.
  vim.cmd('horizontal botright '  .. opts.winheight .. 'new')
  local win_id = vim.api.nvim_get_current_win()

  --- TODO: set winvar for terminal
  -- nvim_win_set_var()

  if opts.jobdone_exit then
    vim.api.nvim_create_autocmd("TermClose", {
      pattern = {'term://*' .. name_tag .. opts.count},
      callback = function(params)
        vim.api.nvim_win_close(win_id, true)
      end
    })
  end

  cmd = 'edit ' .. vim.fn.fnameescape('term://' .. cmd ..  name_tag  .. opts.count)
  if opts.startinsert then
    cmd = cmd .. ' | startinsert'
  end
  vim.cmd(cmd)

  --- 使用 termopen() 开打 terminal
  -- cmd = cmd .. name_tag  .. opts.count
  -- vim.fn.termopen(cmd)
  -- if opts.startinsert then
  --   vim.cmd('startinsert')
  -- end
end



