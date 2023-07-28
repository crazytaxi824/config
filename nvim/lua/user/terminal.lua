--- terminal 相关设置和 autocmd
--- `:help terminal-start`

local fp = require('user.utils.filepath')

--- TermClose 意思是 job done
--- TermLeave 意思是 term 关闭
--- TermOpen 在 jobstart 的时候触发
vim.api.nvim_create_autocmd('TermOpen', {
  pattern = {"term://*"},
  callback = function(params)
    local win_id = vim.api.nvim_get_current_win()

    --- 设置 terminal 不显示行号
    vim.wo[win_id].number = false
    vim.wo[win_id].relativenumber = false
    vim.wo[win_id].signcolumn = "no"

    --- 设置 keymaps
    local function opts(desc)
      return {
        buffer = params.buf,  -- local to Terminal buffer
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

--- NOTE: 这里是保证 terminal hidden 之后, 再次打开时显示 filepath
vim.api.nvim_create_autocmd('BufWinEnter', {
  pattern = {"term://*"},
  callback = function(params)
    fp.highlight(params.buf, vim.api.nvim_get_current_win())
  end,
  desc = "terminal: filepath highlight",
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



