--- 全局 keymap 设置

local key_fn = require('utils.keymaps')
local mt = require('utils.my_term')  -- my_term terminal

--- DOCS ------------------------------------------------------------------------------------------- {{{
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
--- { remap = false }, { noremap = true }
--- { nowait = true },
--- { silent = true },
--- { buffer = number },  -- 针对 bufnr 有效, 0 - current buffer
--- { script = true },
--- { expr = true },
--- { unique = true }, define a new mapping or abbreviation, the command will fail if the mapping or abbreviation already exists.
--- { desc = "key_description" }  -- 会影响 which-key 显示.
local opt = { silent = true }

--- { mode, key, remap, opt, description }  - description for 'which-key'
local keymaps = {
  --- VVI: <ESC> 退出 Ternimal (Insert) Mode 进入 (Terminal) Normal 模式.
  {'t', '<ESC>', '<C-\\><C-n>', opt, "Ternimal: Normal Mode"},

  --- VVI: <ESC> close popup window & nohlsearch
  {'n', '<ESC>', function()
    --- nohlsearch
    if vim.v.hlsearch == 1 then
      vim.cmd.nohlsearch()
      return
    end

    --- close all popup windows
    if key_fn.close_popup_wins() then
      return
    end

    --- default <ESC> function
    -- local esc = vim.api.nvim_replace_termcodes('<ESC>', true, false, true)
    -- vim.api.nvim_feedkeys(esc, 'n', false)
    vim.fn.feedkeys("\\<ESC>", 'n')
  end, opt, "which_key_ignore"},

  --- common use -----------------------------------------------------------------------------------
  --- `:help registers`
  {'n', 'D', '"_dd', opt, "delete line No Copy"},
  {'x', 'D', '"_x',  opt, "delete line No Copy"},

  --- move cursor ----------------------------------------------------------------------------------
  --- NOTE: alacritty 中重新 map 了一些组合键:
  --- <Command-Up>    = <PageUp>;   <Shift-Command-Up>    != <S-PageUp>
  --- <Command-Down>  = <PageDown>; <Shift-Command-Down>  != <S-PageDown>
  --- <Command-Left>  = <Home>;     <Shift-Command-Left>  != <S-Home>
  --- <Command-Right> = <End>;      <Shift-Command-Right> != <S-End>
  --- <PageUp> / <PageDown> / <Home> / <End> 在 mac 中的默认快捷键是 <fn-Up/Down/Left/Right>,
  {{'n','i','v'}, '<PageUp>', function() key_fn.page.up() end, opt, 'which_key_ignore'},
  {{'n','i','v'}, '<PageDown>', function() key_fn.page.down() end, opt, 'which_key_ignore'},
  {{'n','i','v'}, '<D-Up>', function() key_fn.page.up() end, opt, 'which_key_ignore'}, -- Alacritty: <D-Up> = <PageUp>, 该设置主要是备用.
  {{'n','i','v'}, '<D-Down>', function() key_fn.page.down() end, opt, 'which_key_ignore'}, -- Alacritty: <D-Down> = <PageDown>, 该设置主要是备用.

  --- NOTE: vim 中 <S-Up> / <S-Down> 默认和 <PageUp> / <PageDown> 作用相同.
  {{'n','i','v'}, '<S-Up>', function() key_fn.shift.up() end, opt, 'which_key_ignore'},
  {{'n','i','v'}, '<S-Down>', function() key_fn.shift.down() end, opt, 'which_key_ignore'},

  --- <Home> 模拟 vscode 行为
  {{'n','i','v'}, '<Home>', function() key_fn.home.nowrap() end, opt, 'which_key_ignore'},
  {{'n','i','v'}, '<D-Left>', function() key_fn.home.nowrap() end, opt, 'which_key_ignore'}, -- Alacritty: <D-Left> = <Home>, 该设置主要是备用.
  {{'n','i','v'}, '<S-D-Left>', function() key_fn.home.wrap() end, opt, 'which_key_ignore'}, -- <S-D-Left> 并不等于 <S-Home>, <S-Home> 需要使用组合键 Shift-Fn-Left.
  --- <End> 使用默认行为
  {{'n', 'v'}, '<D-Right>', '$', opt, 'which_key_ignore'},  -- Alacritty: <D-Right> = <End>, 该设置主要是备用.
  {'i', '<D-Right>', '<C-o>$', opt, 'which_key_ignore'},  -- Alacritty: <D-Right> = <End>, 该设置主要是备用.
  {{'n', 'v'}, '<S-D-Right>', 'g$', opt, 'which_key_ignore'}, -- <S-D-Right> 并不等于 <S-End>, <S-End> 需要使用组合键 Shift-Fn-Right.
  {'i', '<S-D-Right>', '<C-o>g$', opt, 'which_key_ignore'}, -- <S-D-Right> 并不等于 <S-End>, <S-End> 需要使用组合键 Shift-Fn-Right.

  --- Alacritty setting: <D-Left> = <Home>; <D-Right> = <End>
  --- <S-D-Left> 并不等于 <S-Home>, <S-Home> 需要使用组合键 Shift-Fn-Left.
  {{'n','v'}, '<S-Home>', '12zh', opt, 'screen: scroll left'},
  {'i', '<S-Home>', '<C-o>12zh', opt, 'screen: scroll left'},
  --- <S-D-Right> 并不等于 <S-End>, <S-End> 需要使用组合键 Shift-Fn-Right.
  {{'n','v'}, '<S-End>', '12zl', opt, 'screen: scroll right'},
  {'i', '<S-End>', '<C-o>12zl', opt, 'screen: scroll right'},

  --- NOTE: <Ctrl-Up/Down/Left/Right> 被 mac 系统占用, 无法直接使用.
  {{'n','v'}, '<M-Up>', '3<C-y>', opt, 'screen: scroll Upwards'},
  {'i', '<M-Up>', '<C-o>3<C-y>', opt, 'screen: scroll Upwards'},
  {{'n','v'}, '<M-Down>', '3<C-e>', opt, 'screen: scroll Downwards'},
  {'i', '<M-Down>', '<C-o>3<C-e>', opt, 'screen: scroll Downwards'},

  --- Tab ------------------------------------------------------------------------------------------
  {'n', '<Tab>', '<C-w><C-w>', opt, 'which_key_ignore'},  -- 切换到另一个窗口.

  --- CMD ------------------------------------------------------------------------------------------
  --- save/write file
  {'n', '<D-s>', function() key_fn.save_file() end, opt, 'which_key_ignore'},
  {{'v', 'i'}, '<D-s>', '<C-c><cmd>lua require("utils.keymaps").save_file()<CR>', opt, 'which_key_ignore'},

  --- undo / redo
  {'n', '<D-z>', 'u', opt, 'do: undo'},
  {'i', '<D-z>', '<C-o>u', opt, 'do: undo'},
  {'n', '<S-D-z>', '<C-r>', opt, 'which_key_ignore'},  -- redo
  {'i', '<S-D-z>', '<C-o><C-r>', opt, 'which_key_ignore'}, -- redo
  {'n', '<D-r>', '<C-r>', opt, 'do: redo'},
  {'i', '<D-r>', '<C-o><C-r>', opt, 'do: redo'},

  --- `gc` & `gcc` is remap by default.
  {'n', '<D-/>', 'gcc', {remap=true}, 'Comment current line'},
  {'i', '<D-/>', '<C-o>gcc', {remap=true}, 'Comment current line'},
  {'v', '<D-/>', 'gc', {remap=true}, 'Comment Visual selected'},

  --- <leader> -------------------------------------------------------------------------------------
  --- copy / paste
  --- 如果是 linux server 系统, 则没有系统级 clipboard, 则无法使用该 copy 方式.
  --- 在没有 cilpboard 的情况下如果想要粘贴 register 中的内容到 command line,
  --- 需要使用 |:<CTRL-R> {register}|. `:help c_CTRL-R`.
  {'x', '<leader>y', '"*y', opt, 'Copy to system clipboard'},

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
  {'n', '<leader>$', 'viw<C-c>`>a$<C-c>`<i$<C-c>', opt, 'which_key_ignore'},
  {'n', '<leader>{', 'viw<C-c>`>a}<C-c>`<i{<C-c>', opt, 'which_key_ignore'},
  {'n', '<leader>}', 'viw<C-c>`>a}<C-c>`<i{<C-c>', opt, 'which_key_ignore'},
  {'n', '<leader>[', 'viw<C-c>`>a]<C-c>`<i[<C-c>', opt, 'which_key_ignore'},
  {'n', '<leader>]', 'viw<C-c>`>a]<C-c>`<i[<C-c>', opt, 'which_key_ignore'},
  {'n', '<leader>(', 'viw<C-c>`>a)<C-c>`<i(<C-c>', opt, 'which_key_ignore'},
  {'n', '<leader>)', 'viw<C-c>`>a)<C-c>`<i(<C-c>', opt, 'which_key_ignore'},
  {'n', '<leader>>', 'viw<C-c>`>a><C-c>`<i<<C-c>', opt, 'which_key_ignore'},
  {'n', '<leader><lt>', 'viw<C-c>`>a><C-c>`<lt>i<lt><C-c>', opt, 'which_key_ignore'},  -- '<' 使用 <lt> 代替.

  {'x', '<leader>"', '<C-c>`>a"<C-c>`<i"<C-c>v`><right><right>', opt, 'which_key_ignore'},
  {'x', "<leader>'", "<C-c>`>a'<C-c>`<i'<C-c>v`><right><right>", opt, 'which_key_ignore'},
  {'x', '<leader>`', '<C-c>`>a`<C-c>`<i`<C-c>v`><right><right>', opt, 'which_key_ignore'},
  {'x', '<leader>*', '<C-c>`>a*<C-c>`<i*<C-c>v`><right><right>', opt, 'which_key_ignore'},
  {'x', '<leader>_', '<C-c>`>a_<C-c>`<i_<C-c>v`><right><right>', opt, 'which_key_ignore'},
  {'x', '<leader>$', '<C-c>`>a$<C-c>`<i$<C-c>v`><right><right>', opt, 'which_key_ignore'},
  {'x', '<leader>{', '<C-c>`>a}<C-c>`<i{<C-c>v`><right><right>', opt, 'which_key_ignore'},
  {'x', '<leader>}', '<C-c>`>a}<C-c>`<i{<C-c>v`><right><right>', opt, 'which_key_ignore'},
  {'x', '<leader>[', '<C-c>`>a]<C-c>`<i[<C-c>v`><right><right>', opt, 'which_key_ignore'},
  {'x', '<leader>]', '<C-c>`>a]<C-c>`<i[<C-c>v`><right><right>', opt, 'which_key_ignore'},
  {'x', '<leader>(', '<C-c>`>a)<C-c>`<i(<C-c>v`><right><right>', opt, 'which_key_ignore'},
  {'x', '<leader>)', '<C-c>`>a)<C-c>`<i(<C-c>v`><right><right>', opt, 'which_key_ignore'},
  {'x', '<leader>>', '<C-c>`>a><C-c>`<i<<C-c>v`><right><right>', opt, 'which_key_ignore'},
  {'x', '<leader><lt>', '<C-c>`>a><C-c>`<lt>i<lt><C-c>v`><right><right>', opt, 'which_key_ignore'},  -- '<' 使用 <lt> 代替.

  --- 关闭所有其他 buffers
  --{'n', '<leader>Da', function() key_fn.close_other_bufs() end, opt, 'buffer: Close All Other Buffers'},
  --{'n', '<leader>d', 'bdelete', opt, 'buf: Close Current Buffer'},

  --- Window 控制
  {'n', '<leader>w', function() key_fn.win_choose() end, opt, 'win: Jump to Window'},  -- 跳转到指定 window
  {'n', '<leader>W', '<cmd>only!<CR>', opt, 'win: Close All Other Windows'},  -- 关闭所有其他窗口, 快捷键 <C-w><C-o>

  --- NOTE: terminal key mapping 在其他 plugin 中也有设置.
  {'n', '<leader>tt', function() mt.open_shell_term() end, opt, "open/new Terminal #(1~999)"},
  {'n', '<leader>ta', function() mt.toggle_all() end,  opt, "toggle All Terminals windows"},
  {'n', '<leader>tC', function() mt.close_all() end,   opt, "close All Terminals windows"},
  {'n', '<leader>tO', function() mt.open_all() end,    opt, "open All Terminals windows"},
  {'n', '<leader>tW', function() mt.wipeout_all() end, opt, "wipeout All Terminals"},
  -- {'n', '<leader>tW', function() key_fn.wipe_all_term_bufs() end, opt, "wipeout All Terminals"},  -- alternative

  --- 其他 -----------------------------------------------------------------------------------------
  --- filepath jump to file, {'n', 'i'} 被 lspconfig keymaps 使用.
  {'x', '<S-CR>', '<C-c><cmd>lua require("utils.filepath").v_jump()<CR>', opt, 'filepath: Jump to file'},

  --- 利用 treesitter 跳转到 prev/next root node.
  {{'n','v'}, '[[', function() key_fn.section.goto_prev() end, opt, 'Jump to Prev Section'},
  {{'n','v'}, ']]', function() key_fn.section.goto_next() end, opt, 'Jump to Next Section'},

  --- 切换 buffer, 目前使用 bufferline 进行 buffer 切换, 如果不使用 bufferline.nvim 则使用以下设置.
  --{'n', '<lt>', '<cmd>bprevious<CR>', opt, 'go to previous buffer'},
  --{'n', '>', '<cmd>bnext<CR>', opt, 'go to next buffer'},

  --- hi Normal ctermbg=234 | hi Normal ctermbg=NONE 切换 bg 颜色
  {'n', '<leader>C', function() key_fn.toggle_comments_color() end, opt, 'change Comments color'},

  --- NOTE: <D-k> 被用于 system shortcut
  {'n', '<C-k>', '<cmd>mes clear<CR>', opt, 'message clear'},

  --- move ) ] } to end of line/word
  {'i', '<M-e>', function() key_fn.move_char.move_next_char('$') end, opt, 'move next char to end of line' },
  {'i', '<M-w>', function() key_fn.move_char.move_next_char('e') end, opt, 'move next char to end of word' },
  {'i', '<S-M-W>', function() key_fn.move_char.move_next_char('E') end, opt, 'move next char to end of word' },

  --- TEST: alacritty settings window.option_as_alt 设置 Option 当做 ALT key 使用.
  -- {'n', '<S-C-CR>', function() print("<S-C-CR>") end, opt, 'Test: Shift-Contrl-Enter'},
  -- {'n', '<S-M-CR>', function() print("<S-M-CR>") end, opt, 'Test: Shift-Opt/Alt-Enter'},
  -- {'n', '<S-D-CR>', function() print("<S-D-CR>") end, opt, 'Test: Shift-Cmd/Super-Enter'},
  -- {'n', '<C-M-CR>', function() print("<C-M-CR>") end, opt, 'Test: Ctrl-Cmd/Super-Enter'},
  -- {'n', '<D-M-CR>', function() print("<D-M-CR>") end, opt, 'Test: Ctrl-Cmd/Super-Enter'},
  -- {'n', '<C-D-CR>', function() print("<C-D-CR>") end, opt, 'Test: Ctrl-Cmd/Super-Enter'},

  --- VVI: <Nop> do nothing ------------------------------------------------------------------------
  --- <Ctrl-Z> 是危险操作. 意思是 :stop. Suspend vim, 退出到 terminal 界面, 但保留 job.
  --- 需要使用 `jobs -l` 列出 Suspended 列表,
  --- 使用 `fg %1` 恢复 job,
  --- 或者 `kill %1` 终止 job (不推荐, 会留下 .swp 文件).
  {{'n','v'}, '<C-z>', function() end, opt, 'which_key_ignore'},

  --- BUG: nvim v0.11.0. 'gc' Overlapping with 'gcc'
  {'n', 'gc', '<Nop>', opt, 'Toggle Comment'},

  --- <F1> :help help, 避免误操作.
  {{'n','i'}, '<F1>', function() end, opt, 'which_key_ignore'},

  --- ":help t", 使用 fF 更容易. t 用作 terminal.
  {'n', 't', function() end, opt, 'which_key_ignore'},
  {'n', 'T', function() end, opt, 'which_key_ignore'},
}

--- 这里是设置所有 key mapping 的地方 --------------------------------------------------------------
key_fn.set(keymaps, {
  { "<leader>D", group = "Buffers Close" },
  { "<leader>k", group = "Fold" },
  { "<leader>c", group = "Code" },

  --- for key desc only
  { "<leader>", group = "<leader>" },
  { "[", group = "Section Jump Prev" },
  { "]", group = "Section Jump Next" },
  { "g", group = "g" },
  { "z", group = "z" },
  { "<leader>t", group = "my_term" },

  { "&", desc = "repeat last ':s' replace command" },  -- `:help &-default`
  { "<C-L>", desc = "nohlsearch | diffupdate" },  -- `:help CTRL-L-default`

  --- which-key hidden default keymaps
  { "H", hidden = true },  -- To line from top of window
  { "L", hidden = true },  -- To line from bottom of window
  { "M", hidden = true },  -- To Middle line of window

  { "O", hidden = true },  -- Begin a new line
  { "D", hidden = true },  -- Delete characters
  { "Y", hidden = true },  -- yank lines
})



