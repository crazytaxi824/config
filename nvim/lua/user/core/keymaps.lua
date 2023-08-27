--- 全局 keymap 设置

local key_fn = require('user.utils.keymaps')
local mt = require('user.utils.my_term')  -- my_term terminal

--- README ----------------------------------------------------------------------------------------- {{{
--- vim.keymap.set() & vim.keymap.del()
--- vim.api.nvim_set_keymap() & vim.api.nvim_del_keymap()
--- vim.api.nvim_buf_set_keymap() & vim.api.nvim_buf_del_keymap()
--- vim.keymap.set({'n','i'}, ...) 可以同时设置多个 Mode, vim.api.nvim_(buf)_set_keymap('n', ...) 每次只能设置一个模式.
--- <S-F12> 在 neovim 中是 <F24>, <C-F12> 是 <F36>, <C-S-F12> 是 <F48>. 其他组合键都可以通过 insert 模式打印出来.
---
---  `:help map-table`
---           Mode  | Norm | Ins | Cmd | Vis | Sel | Opr | Term | Lang | ~
---  Command        +------+-----+-----+-----+-----+-----+------+------+ ~
---  [nore]map      | yes  |  -  |  -  | yes | yes | yes |  -   |  -   |
---  n[nore]map     | yes  |  -  |  -  |  -  |  -  |  -  |  -   |  -   |
---  [nore]map!     |  -   | yes | yes |  -  |  -  |  -  |  -   |  -   |
---  i[nore]map     |  -   | yes |  -  |  -  |  -  |  -  |  -   |  -   |
---  c[nore]map     |  -   |  -  | yes |  -  |  -  |  -  |  -   |  -   |
---  v[nore]map     |  -   |  -  |  -  | yes | yes |  -  |  -   |  -   |
---  x[nore]map     |  -   |  -  |  -  | yes |  -  |  -  |  -   |  -   |
---  s[nore]map     |  -   |  -  |  -  |  -  | yes |  -  |  -   |  -   |
---  o[nore]map     |  -   |  -  |  -  |  -  |  -  | yes |  -   |  -   |
---  t[nore]map     |  -   |  -  |  -  |  -  |  -  |  -  | yes  |  -   |
---  l[nore]map     |  -   | yes | yes |  -  |  -  |  -  |  -   | yes  |
---
--- 常用组合键前缀:
---   - <leader>
---   - g
---   - z
---   - i_CTRL-R | c_CTRL-R  NOTE: 在 insert/command 模式下 paste register 到 file/command line.
---                          eg: insert/command 模式下输入 <CTRL-R>0 相当于 normal 模式下 "0p
---                          后面接 = 可以填入 expr. eg: insert/command 模式下输入 <CTRL-R>=100-80, 得到 20.
---   - "        - registers. 可以用在 y,p,d,x 等复制/剪切/粘贴功能上. eg: "*y
---   - @        - execute content of register, like macro.
---   - ` 和 '   - marks
---   - [ | ]  - navigation in file
---
--- 常用固定组合键:
---   - i_CTRL-X_CTRL-O  - omni completion
---   - i_CTRL-O  - 用于在 insert mode 中执行一个 command 然后回到 insert mode.
---   - i_CTRL-C | v_CTRL-C  - insert/visual 退回到 normal mode.
---   - v_CTRL-G  - 切换 visual/select mode, select mode 是 visual 的一个子模式, 多用于代码补全的默认值.
-- -- }}}

--- vim.keymap.set() - option `:help :map-arguments`
--- { noremap = true },
--- { nowait = true },
--- { silent = true },
--- { buffer = number },  -- 针对 bufnr 有效, 0 - current buffer
--- { script = true },
--- { expr = true },
--- { desc = "key_description" }  -- 会影响 which-key 显示.
local opt = { noremap = true, silent = true }

--- NOTE: { mode, key, remap, opt, description }  - description for 'which-key'
local keymaps = {
  --- common use -----------------------------------------------------------------------------------
  --- `:help registers`
  {'n', 'D', '"_dd', opt, "delete line No Copy"},
  {'v', 'D', '"_x',  opt, "delete line No Copy"},
  {'n', 'O', 'O<C-c><Down>', opt, "add new line above cursor"},

  --- move cursor ----------------------------------------------------------------------------------
  --- NOTE: <PageUp> / <PageDown> / <Home> / <End> 在 mac 中的默认快捷键是 <fn-Up/Down/Left/Right>,
  --- 需要在 alacritty 中将 <Command-...> 也设置为 <PageUp> / <PageDown> / <Home> / <End>.
  --- 这里是模拟 vscode 中 PageUp / PageDown 的行为.
  {'n', '<PageUp>', 'zbH', opt, 'which_key_ignore'},
  {'v', '<PageUp>', 'zbH', opt, 'which_key_ignore'},
  {'i', '<PageUp>', '<C-o>zb<C-o>H', opt, 'which_key_ignore'},
  {'n', '<PageDown>', 'ztL', opt, 'which_key_ignore'},
  {'v', '<PageDown>', 'ztL', opt, 'which_key_ignore'},
  {'i', '<PageDown>', '<C-o>zt<C-o>L', opt, 'which_key_ignore'},

  --- NOTE: vim 中 <S-Up> / <S-Down> 默认和 <PageUp> / <PageDown> 作用相同.
  {'n', '<S-Up>', '3gk', opt, 'which_key_ignore'},
  {'v', '<S-Up>', '3gk', opt, 'which_key_ignore'},
  {'i', '<S-Up>', '<C-o>3gk', opt, 'which_key_ignore'},
  {'n', '<S-Down>', '3gj', opt, 'which_key_ignore'},
  {'v', '<S-Down>', '3gj', opt, 'which_key_ignore'},
  {'i', '<S-Down>', '<C-o>3gj', opt, 'which_key_ignore'},

  --- NOTE: <Ctrl-Up/Down/Left/Right> 被 mac 系统占用, 无法直接使用,
  --- 需要在 alacritty 中使用 <option-...> 代替.
  {'n', '<C-Up>', '3<C-y>', opt, 'win: scroll Upwards'},
  {'v', '<C-Up>', '3<C-y>', opt, 'win: scroll Upwards'},
  {'i', '<C-Up>', '<C-o>3<C-y>', opt, 'win: scroll Upwards'},
  {'n', '<C-Down>', '3<C-e>', opt, 'win: scroll Downwards'},
  {'v', '<C-Down>', '3<C-e>', opt, 'win: scroll Downwards'},
  {'i', '<C-Down>', '<C-o>3<C-e>', opt, 'win: scroll Downwards'},

  --- NOTE: zh | zl 在 wrap file 中无法使用.
  --- scroll left/right 用到的机会比较少, 因为大部分情况下不会让 line 超出屏幕宽度.
  {'n', '<C-S-Left>', '6zh', opt, 'win: scroll left'},
  {'v', '<C-S-Left>', '6zh', opt, 'win: scroll left'},
  {'i', '<C-S-Left>', '<C-o>6zh', opt, 'win: scroll left'},  -- 默认在 insert mode 下和 <S-Left> 相同.
  {'n', '<C-S-Right>', '6zl', opt, 'win: scroll right'},
  {'v', '<C-S-Right>', '6zl', opt, 'win: scroll right'},
  {'i', '<C-S-Right>', '<C-o>6zl', opt, 'win: scroll right'},  -- 默认在 insert mode 下和 <S-Right> 相同.
  --- 需要在 alacritty 中使用 <option-...> 代替.
  {'n', '<M-S-Left>', '6zh', opt, 'win: scroll left'},
  {'v', '<M-S-Left>', '6zh', opt, 'win: scroll left'},
  {'i', '<M-S-Left>', '<C-o>6zh', opt, 'win: scroll left'},  -- 默认在 insert mode 下和 <S-Left> 相同.
  {'n', '<M-S-Right>', '6zl', opt, 'win: scroll right'},
  {'v', '<M-S-Right>', '6zl', opt, 'win: scroll right'},
  {'i', '<M-S-Right>', '<C-o>6zl', opt, 'win: scroll right'},  -- 默认在 insert mode 下和 <S-Right> 相同.

  --- NOTE: <Home> 模拟 vscode 行为; <End> 使用默认行为.
  {'n', '<Home>', function() key_fn.home_key.nowrap() end, opt, 'which_key_ignore'},
  {'v', '<Home>', function() key_fn.home_key.nowrap() end, opt, 'which_key_ignore'},
  {'i', '<Home>', '<C-o><cmd>lua require("user.utils.keymaps").home_key.nowrap()<CR>', opt, 'which_key_ignore'},

  {'n', 'G', 'Gzz', opt, 'which_key_ignore'},  -- put last line in center

  --- Tab ------------------------------------------------------------------------------------------
  {'n', '<Tab>', '<C-w><C-w>', opt, 'which_key_ignore'},  -- 切换到另一个窗口.

  --- Search ---------------------------------------------------------------------------------------
  {'n','*',  function() key_fn.hl_search.normal("*") end,  opt, 'search: \\<cword\\> Forward'},
  {'n','#',  function() key_fn.hl_search.normal("#") end,  opt, 'search: \\<cword\\> Backward'},
  {'n','g*', function() key_fn.hl_search.normal("g*") end, opt, 'search: <cword> Forward'},
  {'n','g#', function() key_fn.hl_search.normal("g#") end, opt, 'search: <cword> Backward'},

  --- NOTE: "fy - copy VISUAL selected text to register "f"
  --    `let @/ = @f` - copy register "f" to register "/" (search register)
  {'v', '*',  function() key_fn.hl_search.visual('n', true) end, opt, 'search: \\<cword\\> Forward'},
  {'v', '#',  function() key_fn.hl_search.visual('N', true) end, opt, 'search: \\<cword\\> Backward'},
  {'v', 'g*', function() key_fn.hl_search.visual('n') end, opt, 'search: <cword> Forward'},
  {'v', 'g#', function() key_fn.hl_search.visual('N') end, opt, 'search: <cword> Backward'},

  --- hl next/prev result
  {'n','n', function() key_fn.hl_search.normal("n") end, opt, 'search: Forward'},
  {'n','N', function() key_fn.hl_search.normal("N") end, opt, 'search: Backward'},

  --- NOTE: 这里不能使用 silent, 否则 command line 中不显示 '?' 和 '/'
  --- ':echo v:hlsearch' 显示目前 hlsearch 状态.
  {'n', '?', "<cmd>lua require('user.utils.keymaps').hl_search.delete()<CR>?", {noremap=true}, 'which_key_ignore'},
  {'n', '/', "<cmd>lua require('user.utils.keymaps').hl_search.delete()<CR>/", {noremap=true}, 'which_key_ignore'},

  --- CTRL -----------------------------------------------------------------------------------------
  --- 可以使用的 Ctrl keymap ----------------------------------------------------------------------- {{{
  --- <C-q> 容易退出程序, 不要使用. 默认 Visual-Block mode
  --- <C-s> = remap save file.
  --- <C-z> = remap undo, 默认 ":stop" 中止 job.
  --- <C-j> = remap toggle Comments, 默认相当于 j (cursor down)
  --- <C-t> 默认 tag stack. NOTE: 还未 remap.
  --- <C-g> 默认 print current filename. NOTE: 还未 remap.
  -- -- }}}
  {'n', '<C-s>', function() key_fn.save_file() end, opt, 'which_key_ignore'},
  {'v', '<C-s>', '<C-c><cmd>lua require("user.utils.keymaps").save_file()<CR>', opt, 'which_key_ignore'},
  {'i', '<C-s>', '<C-c><cmd>lua require("user.utils.keymaps").save_file()<CR>', opt, 'which_key_ignore'},

  --- VVI: <Ctrl-Z> 是危险操作. 意思是 :stop. Suspend vim, 退出到 terminal 界面, 但保留 job.
  --- 需要使用 `jobs -l` 列出 Suspended 列表,
  --- 使用 `fg %1` 恢复 job,
  --- 或者 `kill %1` 终止 job (不推荐, 会留下 .swp 文件).
  {'n', '<C-z>', 'u', opt, 'which_key_ignore'},
  {'v', '<C-z>', '<Nop>', opt, 'which_key_ignore'},
  {'i', '<C-z>', '<C-o>u', opt, 'which_key_ignore'},

  --- <leader> -------------------------------------------------------------------------------------
  --- copy / paste
  --- NOTE: 如果是 linux server 系统, 则没有系统级 clipboard, 则无法使用该 copy 方式.
  ---       在没有 cilpboard 的情况下如果想要粘贴 register 中的内容到 command line,
  ---       需要使用 |:<CTRL-R> {register}|. `:help c_CTRL-R`.
  {'v', '<leader>y', '"*y', opt, 'Copy to system clipboard'},

  --- fold code, 这里是模拟 vscode keymaps.
  {'n', '<leader>kj', 'zR', opt, "Open all folds"},
  {'n', '<leader>k0', 'zM', opt, "Close all folds"},
  {'n', '<leader>k1', 'zMzO', opt, "Context Focus & Close other folds"},

  --- <leader> keymaps 默认会显示在 which-key list 中, 所以需要使用 'which_key_ignore' 阻止显示
  {'n', '<leader>"', 'viw<C-c>`>a"<C-c>`<i"<C-c>', opt, 'which_key_ignore'},
  {'n', "<leader>'", "viw<C-c>`>a'<C-c>`<i'<C-c>", opt, 'which_key_ignore'},
  {'n', '<leader>`', 'viw<C-c>`>a`<C-c>`<i`<C-c>', opt, 'which_key_ignore'},
  {'n', '<leader>*', 'viw<C-c>`>a*<C-c>`<i*<C-c>', opt, 'which_key_ignore'},
  {'n', '<leader>_', 'viw<C-c>`>a_<C-c>`<i_<C-c>', opt, 'which_key_ignore'},
  {'n', '<leader>|', 'viw<C-c>`>a|<C-c>`<i|<C-c>', opt, 'which_key_ignore'},
  {'n', '<leader>$', 'viw<C-c>`>a$<C-c>`<i$<C-c>', opt, 'which_key_ignore'},
  {'n', '<leader>{', 'viw<C-c>`>a}<C-c>`<i{<C-c>', opt, 'which_key_ignore'},
  {'n', '<leader>}', 'viw<C-c>`>a}<C-c>`<i{<C-c>', opt, 'which_key_ignore'},
  {'n', '<leader>[', 'viw<C-c>`>a]<C-c>`<i[<C-c>', opt, 'which_key_ignore'},
  {'n', '<leader>]', 'viw<C-c>`>a]<C-c>`<i[<C-c>', opt, 'which_key_ignore'},
  {'n', '<leader>(', 'viw<C-c>`>a)<C-c>`<i(<C-c>', opt, 'which_key_ignore'},
  {'n', '<leader>)', 'viw<C-c>`>a)<C-c>`<i(<C-c>', opt, 'which_key_ignore'},
  {'n', '<leader>>', 'viw<C-c>`>a><C-c>`<i<<C-c>', opt, 'which_key_ignore'},
  {'n', '<leader><lt>', 'viw<C-c>`>a><C-c>`<lt>i<lt><C-c>', opt, 'which_key_ignore'},  -- '<' 使用 <lt> 代替.

  {'v', '<leader>"', '<C-c>`>a"<C-c>`<i"<C-c>v`><right><right>', opt, 'which_key_ignore'},
  {'v', "<leader>'", "<C-c>`>a'<C-c>`<i'<C-c>v`><right><right>", opt, 'which_key_ignore'},
  {'v', '<leader>`', '<C-c>`>a`<C-c>`<i`<C-c>v`><right><right>', opt, 'which_key_ignore'},
  {'v', '<leader>*', '<C-c>`>a*<C-c>`<i*<C-c>v`><right><right>', opt, 'which_key_ignore'},
  {'v', '<leader>_', '<C-c>`>a_<C-c>`<i_<C-c>v`><right><right>', opt, 'which_key_ignore'},
  {'v', '<leader>|', '<C-c>`>a|<C-c>`<i|<C-c>v`><right><right>', opt, 'which_key_ignore'},
  {'v', '<leader>$', '<C-c>`>a$<C-c>`<i$<C-c>v`><right><right>', opt, 'which_key_ignore'},
  {'v', '<leader>{', '<C-c>`>a}<C-c>`<i{<C-c>v`><right><right>', opt, 'which_key_ignore'},
  {'v', '<leader>}', '<C-c>`>a}<C-c>`<i{<C-c>v`><right><right>', opt, 'which_key_ignore'},
  {'v', '<leader>[', '<C-c>`>a]<C-c>`<i[<C-c>v`><right><right>', opt, 'which_key_ignore'},
  {'v', '<leader>]', '<C-c>`>a]<C-c>`<i[<C-c>v`><right><right>', opt, 'which_key_ignore'},
  {'v', '<leader>(', '<C-c>`>a)<C-c>`<i(<C-c>v`><right><right>', opt, 'which_key_ignore'},
  {'v', '<leader>)', '<C-c>`>a)<C-c>`<i(<C-c>v`><right><right>', opt, 'which_key_ignore'},
  {'v', '<leader>>', '<C-c>`>a><C-c>`<i<<C-c>v`><right><right>', opt, 'which_key_ignore'},
  {'v', '<leader><lt>', '<C-c>`>a><C-c>`<lt>i<lt><C-c>v`><right><right>', opt, 'which_key_ignore'},  -- '<' 使用 <lt> 代替.

  --- 关闭所有其他 buffers
  {'n', '<leader>Da', function() key_fn.close_other_bufs() end, opt, 'buffer: Close All Other Buffers'},
  --{'n', '<leader>d', 'bdelete', opt, 'buf: Close Current Buffer'},

  --- Window 控制
  {'n', '<leader>w', function() key_fn.win_choose() end, opt, 'win: Jump to Window'},  -- 跳转到指定 window
  {'n', '<leader>W', '<cmd>only!<CR>', opt, 'win: Close All Other Windows'},  -- 关闭所有其他窗口, 快捷键 <C-w><C-o>

  --- NOTE: terminal key mapping 在其他 plugin 中也有设置.
  {'n', 'tt', function() mt.open_shell_term() end, opt, "my_term: open/new Terminal #(1~999)"},
  {'n', 'tC', function() mt.close_all() end,   opt, "my_term: close All Terminals window"},
  {'n', 'tO', function() mt.open_all() end,    opt, "my_term: open All Terminals window"},
  {'n', 'tT', function() mt.toggle_all() end,  opt, "my_term: toggle All Terminals window"},
  {'n', 'tW', function() mt.wipeout_all() end, opt, "my_term: wipeout All Terminals"},
  -- {'n', 'tW', function() key_fn.wipe_all_term_bufs() end, opt, "terminal: wipeout All Terminals"},

  --- 其他 -----------------------------------------------------------------------------------------
  --- ZZ same as `:x`
  {'n', 'ZZ', '<Nop>', opt},
  {'v', 'ZZ', '<Nop>', opt},

  --- <F1> :help help, 避免误操作.
  {'n', '<F1>', '<Nop>', opt},
  {'i', '<F1>', '<Nop>', opt},

  --- filepath jump to file
  --- VISUAL 选中的 filepath, 不管在什么 filetype 中都跳转.
  --- VVI: 这里需要使用 <CTRL-C> 先退出 VISUAL mode.
  {'v', '<S-CR>', '<C-c><cmd>lua require("user.utils.filepath").v_jump()<CR>', opt, 'filepath: Jump to file'},
  {'v', '<C-S-CR>', '<C-c><cmd>lua require("user.utils.filepath").v_system_open()<CR>', opt, 'filepath: System Open file'},

  --- ` 和 ' 默认都是 `:help marks`, 这里禁止使用 ` 因为有时候 ` 需要作为 <leader>.
  {'n', '`', '<Nop>', opt},

  --- 利用 treesitter 跳转到 prev/next root node.
  {'n', '[[', function() key_fn.section.goto_prev() end, opt, 'Jump to Prev Section'},
  {'n', ']]', function() key_fn.section.goto_next() end, opt, 'Jump to Next Section'},

  --- 切换 buffer, 目前使用 bufferline 进行 buffer 切换, 如果不使用 buffer line 则使用以下设置.
  --{'n', '<lt>', ':bprevious<CR>', opt, 'go to previous buffer'},
  --{'n', '>', ':bnext<CR>', opt, 'go to next buffer'},

  ---TODO: hi Normal ctermbg=234 | hi Normal ctermbg=NONE 切换 bg 颜色
  {'n', '<leader>b', function() key_fn.toggle_editor_bg_color() end, opt, 'change editor background color'},

  --- alacritty settings window.option_as_alt 设置 Option 当做 ALT key 使用.
  {'n', '<M-a>', function() print("<M-a> Option/Alt-A") end, opt, 'Test Option/ALT key'},
}

--- 这里是设置所有 key mapping 的地方 --------------------------------------------------------------
key_fn.set(keymaps, {
  key_desc = {
    k = {name = "Fold Method"},
    D = {name = "Close Buffers"},
  },
  opts = {mode='n', prefix='<leader>'}
})

--- for key desc only
key_fn.set({}, {
  key_desc = {
    ['['] = {name="Section Jump Prev"},
    [']'] = {name="Section Jump Next"},
    g = {name="g"},
    z = {name="z"},
    t = {name="Terminal"},
    ['<leader>'] = {name=vim.g.mapleader or "\\"},

    --- 以下 key 在 which-key 中默认显示为 'Nvim builtin', 所以这里重新更名.
    Y = {'copy whole line without "\\n"'},
    ['<C-L>'] = {':nohlsearch | diffupdate'},
    ['&'] = {"repeat last ':s' replace command"},
  },
  opts = {mode='n'},
})



