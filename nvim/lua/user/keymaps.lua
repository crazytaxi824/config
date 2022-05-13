--- Readme ----------------------------------------------------------------------------------------- {{{
-- vim.keymap.set() & vim.keymap.del()
-- vim.api.nvim_set_keymap() & vim.api.nvim_del_keymap()
-- vim.api.nvim_buf_set_keymap() & vim.api.nvim_buf_del_keymap()
-- vim.keymap.set() 可以同时设置多个模式, vim.api.nvim_set_keymap() 每次只能设置一个模式
-- <S-F12> 在 neovim 中是 <F24>, <C-F12> 是 <F36>, <C-S-F12> 是 <F48>. 其他组合键都可以通过 insert 模式打印出来.
--- }}}

--- NOTE: Close all terminal window function. 给 <leader>T 使用.
local function deleteAllTerm()
  -- 获取所有 bufnr, 判断 bufname 是否匹配 term://*
  for bufnr = vim.fn.bufnr('$'), 1, -1 do
    if string.match(vim.fn.bufname(bufnr), "^term://*") then
      vim.cmd('bdelete! '..bufnr)
    end
  end
end

--- VVI: for Search Highlight ----------------------------------------------------------------------
function _HlNextSearch(key)
  vim.cmd('normal! ' .. key)  -- 首先使用原本的功能

  for _ = 1, 2, 1 do  -- 循环3次
    local search_pat = '\\%#' .. vim.fn.getreg('/')
    local blink_time = '30m'
    local hl_id = vim.fn.matchadd('IncSearch', search_pat, 101)
    vim.cmd[[redraw]]
    vim.cmd('sleep '..blink_time)
    vim.fn.matchdelete(hl_id)
    vim.cmd[[redraw]]
    vim.cmd('sleep '..blink_time)
  end
end

-- vim.keymap.set() - option `:help :map-arguments`
-- noremap = { noremap = true },
-- nowait = { nowait = true },
-- slient = { silent = true },
-- buffer = { buffer = true },  -- buffer 有效
-- script = { script = true },
-- expr = { expr = true },
local opt = { noremap = true, silent = true }
local opt_silent = { silent = true }

--- return keymap settings
--- { mode, key, remapkey, opt, description }  - description for 'which-key'
local keymaps = {
  --- common use -----------------------------------------------------------------------------------
  {'v', '<leader>y', '"*y', opt, 'Copy to system clipboard'},
  {'n', 'D', '"_dd', opt},
  {'v', 'D', '"_x', opt},
  {'n', 'O', 'O<C-c><Down>', opt},

  --- move cursor ----------------------------------------------------------------------------------
  {'n', '<S-Up>', '6gk', opt},
  {'v', '<S-Up>', '6gk', opt},
  {'i', '<S-Up>', '<C-o>6gk', opt},
  {'n', '<S-Down>', '6gj', opt},
  {'v', '<S-Down>', '6gj', opt},
  {'i', '<S-Down>', '<C-o>6gj', opt},

  {'n', '<PageUp>', 'zbH', opt},
  {'v', '<PageUp>', 'zbH', opt},
  {'i', '<PageUp>', '<C-o>zb<C-o>H', opt},
  {'n', '<PageDown>', 'ztL', opt},
  {'v', '<PageDown>', 'ztL', opt},
  {'i', '<PageDown>', '<C-o>zt<C-o>L', opt},

  {'n', '<C-Up>', '3<C-y>', opt},
  {'v', '<C-Up>', '3<C-y>', opt},
  {'i', '<C-Up>', '<C-o>3<C-y>', opt},
  {'n', '<C-Down>', '3<C-e>', opt},
  {'v', '<C-Down>', '3<C-e>', opt},
  {'i', '<C-Down>', '<C-o>3<C-e>', opt},

  {'n', 'G', 'Gzz', opt},  -- put last line in center

  --- Tab ------------------------------------------------------------------------------------------
  {'n', '<Tab>', '<C-w><C-w>', opt},

  --- Search ---------------------------------------------------------------------------------------
  {'n','*', '<cmd>lua _HlNextSearch("*")<CR>', opt},
  {'n','#', '<cmd>lua _HlNextSearch("#")<CR>', opt},
  {'n','g*', '<cmd>lua _HlNextSearch("g*")<CR>', opt, 'Search <cword> Next'},
  {'n','g#', '<cmd>lua _HlNextSearch("g#")<CR>', opt, 'Search <cword> Previous'},

  --- NOTE: "fy - copy VISUAL selected text to register "f"
  --    `let @/ = @f` - copy register "f" to register "/" (search register)
  {'v', '*', '"fy<cmd>let @/ = @f <bar> lua _HlNextSearch("*")<CR>', opt},
  {'v', '#', '"fy<cmd>let @/ = @f <bar> lua _HlNextSearch("#")<CR>', opt},
  {'v', 'g*', '"fy<cmd>let @/ = @f <bar> lua _HlNextSearch("g*")<CR>', opt, 'Search <cword> Next'},
  {'v', 'g#', '"fy<cmd>let @/ = @f <bar> lua _HlNextSearch("g#")<CR>', opt, 'Search <cword> Previous'},

  {'n','n', '<cmd>lua _HlNextSearch("n")<CR>', opt},
  {'n','N', '<cmd>lua _HlNextSearch("N")<CR>', opt},

  {'n','?', '<cmd>nohlsearch<CR>?', {noremap=true}},  -- NOTE: 这里不能使用 silent, 否则 command line 中不显示 '?' 和 '/'
  {'n','/', '<cmd>nohlsearch<CR>/', {noremap=true}},

  --- CTRL -----------------------------------------------------------------------------------------
  {'n', '<C-s>', ':update<CR>', opt},
  {'v', '<C-s>', '<C-c>:update<CR>', opt},
  {'i', '<C-s>', '<C-c>:update<CR>', opt},
  -- VVI: <Ctrl-Z> 是危险操作. 意思是 :stop. 直接退出 vim, 会留下 .swp 文件
  {'n', '<C-z>', 'u', opt},
  {'v', '<C-z>', '<Nop>', opt},
  {'i', '<C-z>', '<C-o>u', opt},

  --- fold -----------------------------------------------------------------------------------------
  {'n', '<leader>k1', 'zM', opt, "Close all folds"},
  {'n', '<leader>kj', 'zR', opt, "Open all folds"},

  --- 其他 -----------------------------------------------------------------------------------------
  {'n', 'ZZ', '<Nop>', opt, 'same as `:x`'},
  {'v', 'ZZ', '<Nop>', opt, 'same as `:x`'},

  --- <leader> -------------------------------------------------------------------------------------
  {'n', '<leader>W', '<C-w><C-o>', opt, 'Close All Other Windows'},

  -- NOTE: terminal key mapping 在 "toggleterm.lua" 中设置了.
  {'n', '<leader>T', deleteAllTerm, opt, "Close All Terminal Window"},

  {'n', '<leader>"', 'viw<C-c>`>a"<C-c>`<i"<C-c>', opt, 'which_key_ignore'},  -- 不在 which-key 中显示.
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

  --- plugins --------------------------------------------------------------------------------------
  -- nvim-tree -------------------------
  {'n', '<leader>,', ':NvimTreeToggle<CR>', opt_silent},  -- NOTE: 没有设置 description, 直接使用 binding 字符

  -- tagbar ----------------------------
  {'n', '<leader>.', ':TagbarToggle<CR>', opt_silent},

  -- comment ---------------------------
  {'n', '<leader>\\', '<Plug>(comment_toggle_current_linewise)', opt_silent, 'comment'},
  {'v', '<leader>\\', '<Plug>(comment_toggle_linewise_visual)', opt_silent, 'comment'},

  -- airline ---------------------------
  {'n', '<leader>1', '<Plug>AirlineSelectTab1', opt_silent, 'which_key_ignore'},
  {'n', '<leader>2', '<Plug>AirlineSelectTab2', opt_silent, 'which_key_ignore'},
  {'n', '<leader>3', '<Plug>AirlineSelectTab3', opt_silent, 'which_key_ignore'},
  {'n', '<leader>4', '<Plug>AirlineSelectTab4', opt_silent, 'which_key_ignore'},
  {'n', '<leader>5', '<Plug>AirlineSelectTab5', opt_silent, 'which_key_ignore'},
  {'n', '<leader>6', '<Plug>AirlineSelectTab6', opt_silent, 'which_key_ignore'},
  {'n', '<leader>7', '<Plug>AirlineSelectTab7', opt_silent, 'which_key_ignore'},
  {'n', '<leader>8', '<Plug>AirlineSelectTab8', opt_silent, 'which_key_ignore'},
  {'n', '<leader>9', '<Plug>AirlineSelectTab9', opt_silent, 'which_key_ignore'},
  {'n', '<leader>0', '<Plug>AirlineSelectTab0', opt_silent, 'which_key_ignore'},
  {'n', '<lt>', '<Plug>AirlineSelectPrevTab'},
  {'n', '>', '<Plug>AirlineSelectNextTab'},

  -- 关闭 buffers
  {'n', '<leader>d', ':execute "normal! \\<Plug>AirlineSelectNextTab" <bar> :bdelete #<CR>', opt_silent, 'Close This Buffer'},
  {'n', '<leader>D', ':%bdelete <bar> :edit # <bar> :bwipeout #<CR>', opt, 'Close All Other Buffers'},

  --- telescope fzf --------------------
  --- Picker functions, https://github.com/nvim-telescope/telescope.nvim#pickers
  --- 使用 `:Telescope` 列出所有 Picker
  {'n', '<leader>ff', "<cmd>lua require('telescope.builtin').find_files()<cr>", opt, 'Telescope - fd'},
  {'n', '<leader>fg', "<cmd>lua require('telescope.builtin').live_grep()<cr>", opt, 'Telescope - rg'},
  {'n', '<leader>fb', "<cmd>lua require('telescope.builtin').buffers()<cr>", opt, 'Telescope - Buffer List'},
  {'n', '<leader>fh', "<cmd>lua require('telescope.builtin').help_tags()<cr>", opt, 'Telescope - Vim Help Doc'},
  {'n', '<leader>fc', "<cmd>lua require('telescope.builtin').command_history()<cr>", opt, 'Telescope - Command History'},
  {'n', '<leader>fs', "<cmd>lua require('telescope.builtin').search_history()<cr>", opt, 'Telescope - Search History'},
  {'n', '<leader>fk', "<cmd>lua require('telescope.builtin').keymaps()<cr>", opt, 'Telescope - Keymap normal Mode'},
  {'n', 'z=', "<cmd>lua require('telescope.builtin').spell_suggest()<cr>", opt, 'Telescope - Spell Suggests'},  -- NOTE: 也可以使用 which-key 显示

  --- Vimspector -----------------------
  {'n', '<leader>cs', '<Plug>VimspectorContinue', opt, 'Debug - Continue(Start)'},
  {'n', '<leader>ce', '<Plug>VimspectorStop', opt, 'Debug - End(Stop)'},
  {'n', '<leader>cr', '<Plug>VimspectorRestart', opt, 'Debug - Restart'},
  {'n', '<leader>cq', ':VimspectorReset<CR>', opt, 'Debug - Quit'},
  {'n', '<leader>cc', '<Plug>VimspectorBalloonEval', opt, 'Debug - Popup Value under cursor'},
  {'n', '<F9>',  '<Plug>VimspectorToggleBreakpoint', opt, 'Debug - Toggle Breakpoint'},
  {'n', '<F10>', '<Plug>VimspectorStepOver', opt, 'Debug - Step Over'},
  {'n', '<F11>', '<Plug>VimspectorStepInto', opt, 'Debug - Step Into'},
  {'n', '<F23>', '<Plug>VimspectorStepOut', opt, 'Debug - Step Out'},  -- <S-F11>
}

--- 这里是设置所有 key binding 的地方.
for _, kv in ipairs(keymaps) do
  vim.keymap.set(kv[1], kv[2], kv[3], kv[4])
end


--- which-key --------------------------------------------------------------------------------------
--- 添加自定义属性
--- https://github.com/folke/which-key.nvim#%EF%B8%8F-mappings
local status_ok, which_key = pcall(require, "which-key")
if not status_ok then
  return
end

--- https://github.com/folke/which-key.nvim#%EF%B8%8F-mappings
--- NOTE: 只用 which key 只读取 description, keymapping 不在这里设置.
for _, keymap in ipairs(keymaps) do
  if keymap[5] then
    which_key.register({[keymap[2]] = keymap[5]},{mode = keymap[1]})
  end
end

--- plugins 设置 -----------------------------------------------------------------------------------
--- group name -------------------------
which_key.register({
  k = {name = "Fold Method"},
  c = {name = "Code Action"},
  f = {name = "Telescope Find"},
},{mode='n',prefix='<leader>'})

which_key.register({
  --- LSP ---
  ['a'] = "LSP - Code Action",  -- lsp/setup_opts.lua 中设置
  --- Vimspector -------------------------
  ['<F9>'] = "Debug - Toggle Breakpoint",
  ['<F10>'] = "Debug - Step Over",
  ['<F11>'] = "Debug - Step Into",
  ['<S-F11>'] = "Debug - Step Out",
},{mode='n',prefix='<leader>c'})




