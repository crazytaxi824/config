--- terminal 相关设置和 autocmd
--- `:help terminal-start`

--- termopen(), jobstart() 时触发
vim.api.nvim_create_autocmd('TermOpen', {
  pattern = {"*"},
  callback = function(params)
    local win_id = vim.api.nvim_get_current_win()
    local scope={ scope='local', win=win_id }

    --- 设置 terminal 不显示行号
    vim.api.nvim_set_option_value('number', false, scope)
    vim.api.nvim_set_option_value('relativenumber', false, scope)
    vim.api.nvim_set_option_value('signcolumn', 'no', scope)
    vim.api.nvim_set_option_value('sidescrolloff', 0, scope)
    vim.api.nvim_set_option_value('scrolloff', 0, scope)

    --- VVI: <ESC> 进入 terminal Normal 模式.
    local opts = {buffer = params.buf, noremap = true, silent = true, desc = "Ternimal: Normal Mode"}
    vim.keymap.set('t', '<ESC>', '<C-\\><C-n>', opts)
  end,
  desc = "terminal: highlight filepath in terminal window",
})



