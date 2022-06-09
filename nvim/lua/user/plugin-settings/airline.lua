--- 自定义 theme 文件在 '~/.config/nvim/autoload/airline/themes/mydark.vim'
vim.g.airline_theme = "mydark"
--vim.g.airline_theme = "dark"   -- 自带主题

vim.g['airline#extensions#tabline#enabled'] = 1
vim.g['airline#extensions#whitespace#checks'] = {'indent', 'trailing', 'conflicts'}
vim.g['airline#extensions#tabline#buffer_idx_mode'] = 1
vim.g['airline#extensions#tabline#keymap_ignored_filetypes'] = {'vimfiler', 'nerdtree', 'tagbar', 'Nvimtree'}
vim.g['airline#extensions#branch#enabled'] = 1  -- "tpope/vim-fugitive"

-- `:help mode()` 显示所有模式.
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
  {'n', '<leader>d', ':execute "normal! \\<Plug>AirlineSelectNextTab" <bar> :bdelete #<CR>', opt, 'Close This Buffer'},
}

Keymap_list_set(airline_keymaps)



