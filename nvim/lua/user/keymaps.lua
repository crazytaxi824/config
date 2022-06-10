----------------------------------------------------------------------------------------------------
--- NOTE: 全局 keymap 设置
----------------------------------------------------------------------------------------------------
--- Readme ----------------------------------------------------------------------------------------- {{{
-- vim.keymap.set() & vim.keymap.del()
-- vim.api.nvim_set_keymap() & vim.api.nvim_del_keymap()
-- vim.api.nvim_buf_set_keymap() & vim.api.nvim_buf_del_keymap()
-- vim.keymap.set() 可以同时设置多个模式, vim.api.nvim_set_keymap() 每次只能设置一个模式
-- <S-F12> 在 neovim 中是 <F24>, <C-F12> 是 <F36>, <C-S-F12> 是 <F48>. 其他组合键都可以通过 insert 模式打印出来.
-- -- }}}

--- functions for key mapping ---------------------------------------------------------------------- {{{
--- close all terminal window function. 给 <leader>T 使用.
local function delete_all_terminals()
  -- 获取所有 bufnr, 判断 bufname 是否匹配 term://*
  for bufnr = vim.fn.bufnr('$'), 1, -1 do
    if string.match(vim.fn.bufname(bufnr), "^term://*") then
      vim.cmd('bdelete! '..bufnr)
    end
  end
end

--- for Search Highlight
function _HlNextSearch(key)
  local status, errmsg = pcall(vim.cmd, 'normal! ' .. key)
  if not status then
    vim.notify(errmsg, vim.log.levels.ERROR) -- 这里不要使用 notify 插件, 显示错误信息.
    return
  end

  local search_pat = '\\%#' .. vim.fn.getreg('/')
  local blink_time = '40m'
  for _ = 1, 2, 1 do  -- 循环闪烁
    local hl_id = vim.fn.matchadd('HLNextSearch', search_pat, 101)
    vim.cmd[[redraw]]
    vim.cmd('sleep '..blink_time)
    vim.fn.matchdelete(hl_id)
    vim.cmd[[redraw]]
    vim.cmd('sleep '..blink_time)
  end
end

--- 删除其他 buffer, TODO in same window.
local function delete_all_other_buffers()
  local buf_list = {}
  for _, bufinfo in ipairs(vim.fn.getbufinfo()) do  -- 所有 buffer, table list
    if bufinfo.listed == 1      -- 是 listed buffer. NOTE: nvimtree, tagbar, terminal 不会被关闭.
      and bufinfo.changed == 0  -- 没有未保存内容
      and bufinfo.loaded == 1   -- 已经加载完成
      and bufinfo.hidden == 1   -- 隐藏状态的 buffer, 如果不是 hidden 状态, 例如当前 buffer, 不会被删除.
    then
      table.insert(buf_list, bufinfo.bufnr)
    end
  end
  if #buf_list > 0 then
    -- print('bdelete ' .. vim.fn.join(buf_list, ' ')) -- DEBUG
    vim.cmd('bdelete ' .. vim.fn.join(buf_list, ' '))
  end
end

-- -- }}}

-- vim.keymap.set() - option `:help :map-arguments`
-- noremap = { noremap = true },
-- nowait = { nowait = true },
-- silent = { silent = true },
-- buffer = { buffer = true },  -- buffer 有效
-- script = { script = true },
-- expr = { expr = true },
local opt = { noremap = true, silent = true }

--- NOTE: { mode, key, remap, opt, description }  - description for 'which-key'
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
  {'v', '*', '"fy<cmd>let @/ = "\\\\<"..@f.."\\\\>" <bar> lua _HlNextSearch("n")<CR>', opt},
  {'v', '#', '"fy<cmd>let @/ = "\\\\<"..@f.."\\\\>" <bar> lua _HlNextSearch("N")<CR>', opt},
  {'v', 'g*', '"fy<cmd>let @/ = @f <bar> lua _HlNextSearch("n")<CR>', opt, 'Search <cword> Next'},
  {'v', 'g#', '"fy<cmd>let @/ = @f <bar> lua _HlNextSearch("N")<CR>', opt, 'Search <cword> Previous'},

  {'n','n', '<cmd>lua _HlNextSearch("n")<CR>', opt},
  {'n','N', '<cmd>lua _HlNextSearch("N")<CR>', opt},

  --- NOTE: 这里不能使用 silent, 否则 command line 中不显示 '?' 和 '/'
  --- ':echo v:hlsearch' 显示目前 hlsearch 状态.
  --{'n', '?', 'v:hlsearch ? ":nohlsearch<CR>" : "?"', {noremap=true, expr=true}},  -- 三元表达式
  --{'n', '/', 'v:hlsearch ? ":nohlsearch<CR>" : "/"', {noremap=true, expr=true}},
  {'n', '?', ":nohlsearch<CR>?", {noremap=true}},
  {'n', '/', ":nohlsearch<CR>/", {noremap=true}},

  --- CTRL -----------------------------------------------------------------------------------------
  {'n', '<C-s>', ':update<CR>', opt},
  {'v', '<C-s>', '<C-c>:update<CR>', opt},
  {'i', '<C-s>', '<C-c>:update<CR>', opt},
  --- VVI: <Ctrl-Z> 是危险操作. 意思是 :stop. 直接退出 vim, 会留下 .swp 文件
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

  --- 关闭所有其他 buffers
  {'n', '<leader>D', delete_all_other_buffers, opt, 'Close All Other Buffers'},
  --{'n', '<leader>d', 'bdelete', opt, 'Close This Buffer'},  -- 使用 airline 的功能删除 buffer.

  --- 关闭所有其他窗口
  {'n', '<leader>W', '<C-w><C-o>', opt, 'Close All Other Windows'},

  --- NOTE: terminal key mapping 在 "toggleterm.lua" 中设置了.
  {'n', '<leader>T', delete_all_terminals, opt, "Close All Terminal Window"},
}

--- 这里是设置所有 key mapping 的地方 --------------------------------------------------------------
Keymap_set_and_register(keymaps, {
  key_desc = {k = {name = "Fold Method"}},
  opts = {mode='n', prefix='<leader>'}
})



