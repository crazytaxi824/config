--- terminal 相关设置和 autocmd
--- `:help terminal-start`

local fp = require('user.utils.filepath')

--- termopen(), jobstart() 时触发
vim.api.nvim_create_autocmd('TermOpen', {
  pattern = {"*"},
  callback = function(params)
    --- 设置 terminal 不显示行号
    vim.opt_local.number = false
    vim.opt_local.relativenumber = false
    vim.opt_local.signcolumn = "no"

    --- 设置 keymaps
    local function opts(desc)
      return {
        buffer = params.buf,  -- local to buffer
        noremap = true,
        silent = true,
        desc = desc,
      }
    end

    --- 跳转到 cursor <cWORD> 文件.
    vim.keymap.set('n', '<S-CR>', function() fp.n_jump() end, opts("Jump to file"))
    --- VVI: <ESC> 进入 terminal Normal 模式.
    vim.keymap.set('t', '<ESC>', '<C-\\><C-n>', opts("Ternimal: Normal Mode"))
  end,
  desc = "terminal: highlight filepath in terminal window",
})

--- VISIAL 模式跳转文件 ----------------------------------------------------------------------------
--- VISUAL 选中的 filepath, 不管在什么 filetype 中都跳转
--- 操作方法: visual select 'filepath:lnum', 然后使用 <S-CR> 跳转到文件.
vim.keymap.set('v', '<S-CR>',
  "<C-c><cmd>lua require('user.utils.filepath').v_jump()<CR>",
  {noremap = true, silent = true, desc = "Jump to file"}
)

--- 使用 system 打开文件.
vim.keymap.set('v', '<C-S-CR>',
  "<C-c><cmd>lua require('user.utils.filepath').v_system_open()<CR>",
  {noremap = true, silent = true, desc = "System Open file"}
)



