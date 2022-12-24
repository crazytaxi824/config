local fp = require('user.utils.filepath')

--- terminal normal 模式跳转文件 -------------------------------------------------------------------
--- 操作方法: 在 Terminal Normal 模式中, 在行的任意位置使用 <CR> 跳转到文件.

--- TermClose 意思是 job done
--- TermLeave 意思是 term 关闭
--- TermOpen 类似 FileType 只在第一次打开 terminal 的时候触发.
vim.api.nvim_create_autocmd('TermOpen', {
  pattern = {"term://*"},
  callback = function(params)
    --- 显示 filepath, NOTE: 第一次打开 terminal 的时候不会触发 "BufEnter", 只能使用 "TermOpen"
    --- 但是 "TermOpen" 类似 "FileType" 只在第一次打开 terminal 的时候触发.
    local curr_win_id = vim.api.nvim_get_current_win()
    fp.highlight(params.buf, curr_win_id)

    --- 设置 keymaps
    vim.keymap.set('n', '<S-CR>',
      function() fp.n_jump(vim.fn.expand('<cWORD>')) end,
      {
        noremap = true,
        silent = true,
        buffer = params.buf,  -- local to Terminal buffer
        desc = "Jump to file",
      }
    )
  end,
  desc = "filepath highlight",
})

--- 这里是保证 terminal hidden 之后, 再次打开时显示 filepath
vim.api.nvim_create_autocmd('BufWinEnter', {
  pattern = {"term://*"},
  callback = function(params)
    local curr_win_id = vim.api.nvim_get_current_win()
    fp.highlight(params.buf, curr_win_id)
  end,
  desc = "filepath highlight",
})

--- VISIAL 模式跳转文件 ----------------------------------------------------------------------------
--- VISUAL 选中的 filepath, 不管在什么 filetype 中都跳转
--- 操作方法: visual select 'filepath:lnum', 然后使用 <S-CR> 跳转到文件.
vim.keymap.set('v', '<S-CR>',
  "<C-c><cmd>lua require('user.utils.filepath').v_jump()<CR>",
  {noremap = true, silent = true, desc = "Jump to file"}
)

--- 使用 system 打开文件.
vim.keymap.set('v', '<C-o>',
  "<C-c><cmd>lua require('user.utils.filepath').v_system_open()<CR>",
  {noremap = true, silent = true, desc = "System Open file"}
)

--- <ESC> 进入 terminal Normal 模式,
--- VVI: 同时也 press <ESC>, 用于退出 fzf 等 terminal 中的操作. 只对本 buffer 有效.
vim.cmd [[au TermOpen term://* tnoremap <buffer> <ESC> <ESC><C-\><C-n>]]

--- 设置 terminal 不显示行号.
vim.cmd [[au TermOpen term://* :setlocal nonumber norelativenumber]]

