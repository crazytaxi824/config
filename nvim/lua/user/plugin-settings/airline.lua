--- 自定义 theme 文件在 '~/.config/nvim/autoload/airline/themes/mydark.vim'
vim.g.airline_theme = "mydark"
--vim.g.airline_theme = "dark"   -- 自带主题

vim.g['airline#extensions#tabline#enabled'] = 1  -- 上方开启 buffer list
vim.g['airline#extensions#tabline#buffer_idx_mode'] = 1  -- 给 buffer list 编号.
vim.g['airline#extensions#whitespace#checks'] = {'indent', 'trailing', 'conflicts'}  -- 检查文档

--- VVI: buffer unlist 指定文件名(pattern) / 文件类型.
vim.g['airline#extensions#tabline#keymap_ignored_filetypes'] = {'vimfiler', 'nerdtree', 'tagbar', 'Nvimtree'} -- unlist 文件类型
vim.g['airline#extensions#tabline#ignore_bufadd_pat'] = '!|term://|defx|gundo' -- 文件名部分匹配则 unlist

--- airline 插件设置, 默认都是开启状态.
--vim.g['airline#extensions#branch#enabled'] = 1  -- "tpope/vim-fugitive"
--vim.g['airline#extensions#tagbar#enabled'] = 1  -- "tagbar"

--- `:help mode()` 显示所有模式.
vim.g.airline_mode_map = {
	['n']     = ' NORMAL -',
	['t']     = ' TERMINAL',
	['v']     = ' VISUAL -',
	['V']     = ' VISUAL L',
	['']    = ' VISUAL B',
	['s']     = ' SELECT -',
	['S']     = ' SELECT L',
	['']    = ' SELECT B',
	['i']     = ' INSERT -',
	['niI']   = ' INSERT N',
	['ic']    = ' INSERT C',
	['ix']    = ' INSERT C',
	['c']     = ' COMMAND ',
	['R']     = 'REPLACE -',
	['niR']   = 'REPLACE N',
	['Rc']    = 'REPLACE C',
	['Rx']    = 'REPLACE C',
	['Rv']    = 'V-REPLACE -',
	['niV']   = 'V-REPLACE N',
}

--- 自定义 formatter 文件在 '~/.config/nvim/autoload/airline/extensions/tabline/formatters/myfilename.vim'
vim.g['airline#extensions#tabline#formatter'] = 'myfilename'
--vim.g['airline#extensions#tabline#formatter'] = 'unique_tail'

--- keymaps ----------------------------------------------------------------------------------------
local opt = { noremap = true, silent = true }
local airline_keymaps = {
  -- airline ---------------------------------------------------------------------------------------
  {'n', '<leader>1', '<Plug>AirlineSelectTab1', opt, 'which_key_ignore'},
  {'n', '<leader>2', '<Plug>AirlineSelectTab2', opt, 'which_key_ignore'},
  {'n', '<leader>3', '<Plug>AirlineSelectTab3', opt, 'which_key_ignore'},
  {'n', '<leader>4', '<Plug>AirlineSelectTab4', opt, 'which_key_ignore'},
  {'n', '<leader>5', '<Plug>AirlineSelectTab5', opt, 'which_key_ignore'},
  {'n', '<leader>6', '<Plug>AirlineSelectTab6', opt, 'which_key_ignore'},
  {'n', '<leader>7', '<Plug>AirlineSelectTab7', opt, 'which_key_ignore'},
  {'n', '<leader>8', '<Plug>AirlineSelectTab8', opt, 'which_key_ignore'},
  {'n', '<leader>9', '<Plug>AirlineSelectTab9', opt, 'which_key_ignore'},
  {'n', '<leader>0', '<Plug>AirlineSelectTab0', opt, 'which_key_ignore'},
  {'n', '<lt>', '<Plug>AirlineSelectPrevTab'},
  {'n', '>', '<Plug>AirlineSelectNextTab'},

  --- airline 关闭 buffers.
  --- bufnr("#") > 0 表示 '#' (previous buffer) 存在, 如果不存在则 bufnr('#') = -1.
  --- 如果 # 存在, 但处于 unlisted 状态, 则 bdelete # 报错. 因为 `:bdelete` 本质就是 unlist buffer.
  {'n', '<leader>d',
    ':execute "normal! \\<Plug>AirlineSelectNextTab" <bar> if bufnr("#") > 0 <bar> :bdelete # <bar> endif<CR>',
    opt, 'Close This Buffer'},
}

Keymap_set_and_register(airline_keymaps)



