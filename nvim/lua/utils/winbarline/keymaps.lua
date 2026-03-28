local wb_act = require('utils.winbarline.winbar_actions')


--- set keymaps ------------------------------------------------------------------------------------
local opt = { silent = true }
local winbar_keymaps = {
  {'n', '<S-D-[>', function() wb_act.cycle('prev') end, opt, 'buffer: go to Prev buffer'},
  {'n', '<S-D-]>', function() wb_act.cycle('next')  end, opt, 'buffer: go to Next buffer'},
  {'n', '<leader>d', function() wb_act.delete_current_buf() end, opt, 'buffer: Close Current Buffer/Tab'},
  {'n', '<leader>D<Left>', function() wb_act.delete_buffers('left') end, opt, 'buffer: Close Left Side Buffers'},
  {'n', '<leader>D<Right>', function() wb_act.delete_buffers('right') end, opt, 'buffer: Close Right Side Buffers'},
  {'n', '<leader>Da', function() wb_act.delete_buffers('others') end, opt, 'buffer: Close all other buffers'},
  {'n', '<leader>\\', function()
    if vim.v.count == 0 then
      wb_act.list_win_buffers()
    else
      wb_act.goto(vim.v.count)
    end
  end , opt, 'which_key_ignore'},
}

require('utils.keymaps').set(winbar_keymaps)

