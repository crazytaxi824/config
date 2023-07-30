local fp_hl = require('user.utils.filepath.highlight')
local fp_jump = require('user.utils.filepath.jump_to_file')

local M = {
  highlight = fp_hl.highlight_filepath,
  highlight_clear = fp_hl.highlight_filepath_clear,

  n_jump = fp_jump.n_jump_cWORD,
  v_jump = fp_jump.v_jump_selected,
  v_system_open = fp_jump.v_system_open_selected,
}

--- 在 terminal 和 dap window 中显示 filepath highlight.
vim.api.nvim_create_autocmd('BufWinEnter', {
  pattern = {"*"},
  callback = function(params)
    local curr_win_id = vim.api.nvim_get_current_win()

    --- terminal and dap
    --- VVI: 这里需要使用 schedule() 延迟运行, 因为使用 my_term 的情况下, BufWinEnter 的时候还是 scratch buffer,
    --- buftype 是 nofile 还不是 termimal. 在运行了 termopen() 之后 buftype 才会变成 terminal.
    vim.schedule(function()
      if vim.bo[params.buf].buftype == 'terminal' or vim.bo[params.buf].filetype == 'dap-repl' then
        fp_hl.highlight_filepath(curr_win_id)
      else
        fp_hl.highlight_filepath_clear(curr_win_id)
      end
    end)
  end,
  desc = "terminal: filepath highlight",
})

return M
