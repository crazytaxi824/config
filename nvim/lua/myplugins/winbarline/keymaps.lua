local wb_act = require('myplugins.winbarline.winbar_actions')


local M = {}

function M.set()
  local opt = { silent = true }
  local winbar_keymaps = {
    {'n', '<S-D-[>', function() wb_act.cycle('prev') end, opt, 'buffer: go to Prev buffer'},
    {'n', '<S-D-]>', function() wb_act.cycle('next')  end, opt, 'buffer: go to Next buffer'},
    {'n', '<S-D-w>', function()
      for _, win_id in ipairs(vim.api.nvim_tabpage_list_wins(0)) do
        -- NOTE: split window 中不会触发 BufWinEnter, 所以利用 WinResized 来解决.
        -- NOTE: "a buffer with read errors" 时所有的 buf events 都不会被触发, eg: [Permission Denied], LSP error ...
        -- window 中一定会显示一个 buffer
        local w = wb_act.binding_win_buf(win_id, vim.api.nvim_win_get_buf(win_id))
        if w then
          w:set_winbar()
        end
      end
    end, opt, 'win: refresh all winbarline'},

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
    end , opt, 'win: show all buffers in current window'},
  }

  require('utils.keymaps').set(winbar_keymaps)
end

return M
