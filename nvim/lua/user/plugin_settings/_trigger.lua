--- NOTE: 本文件主要是设置可以触发 lazy 加载 packer-opt plugins 的 commands

--- nvim-dap ---------------------------------------------------------------------------------------
vim.api.nvim_create_autocmd("FileType", {
  pattern = {"go"},  --- NOTE: 目前只对 go 使用 debug
  callback = function()
    --- set command :Debug
    --vim.cmd([[command -buffer -bar Debug DapContinue]])
    vim.api.nvim_buf_create_user_command(0, 'Debug', 'DapContinue', {bang=true, bar=true})

    --- set <F9> Toggle Breakpoint
    --vim.cmd([[ nnoremap <buffer> <F9> <cmd>DapToggleBreakpoint<CR>]])
    vim.keymap.set('n', '<F9>', '<cmd>DapToggleBreakpoint<CR>', {noremap=true, buffer=true})

    --- which-key <F9> toggle_breakpoint
    local wk_status_ok, wk = pcall(require, "which-key")
    if wk_status_ok then
      wk.register({['<leader>c<F9>'] = {"Debug - Toggle Breakpoint"}}, {mode="n", buffer=0})
    end
  end,
})

--- nvim-tree --------------------------------------------------------------------------------------
vim.keymap.set('n', '<leader>,', ':NvimTreeToggle<CR>', { noremap = true, silent = true })



