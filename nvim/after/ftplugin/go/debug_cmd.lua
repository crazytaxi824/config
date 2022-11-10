--- VVI: 这里必须使用 nvim-dap 内置 command, 因为 nvim-dap 加载条件是使用 command.

--- set command :Debug
--vim.cmd([[command -buffer -bar Debug DapContinue]])
vim.api.nvim_buf_create_user_command(0, 'Debug', 'DapContinue', {
  bang=true, bar=true
})

--- set <F9> Toggle Breakpoint, 
--vim.cmd([[ nnoremap <buffer> <F9> <cmd>DapToggleBreakpoint<CR>]])
vim.keymap.set('n', '<F9>', '<cmd>DapToggleBreakpoint<CR>', {
  noremap=true, buffer=true, desc="debug: Toggle Breakpoint"
})



