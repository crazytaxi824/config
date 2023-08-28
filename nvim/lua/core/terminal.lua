--- terminal 相关设置和 autocmd
--- `:help terminal-start`

--- termopen(), jobstart() 时触发
vim.api.nvim_create_autocmd('TermOpen', {
  pattern = {"*"},
  callback = function(params)
    --- 设置 terminal 不显示行号
    vim.opt_local.number = false
    vim.opt_local.relativenumber = false
    vim.opt_local.signcolumn = "no"

    --- VVI: <ESC> 进入 terminal Normal 模式.
    local opts = {buffer = params.buf, noremap = true, silent = true, desc = "Ternimal: Normal Mode"}
    vim.keymap.set('t', '<ESC>', '<C-\\><C-n>', opts)
  end,
  desc = "terminal: highlight filepath in terminal window",
})



