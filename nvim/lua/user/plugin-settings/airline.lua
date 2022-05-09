--- 自定义 theme 文件在 '~/.config/nvim/autoload/airline/themes/mydark.vim'
vim.g.airline_theme = "mydark"
--vim.g.airline_theme = "dark"   -- 自带主题

vim.g['airline#extensions#tabline#enabled'] = 1
vim.g['airline#extensions#branch#enabled'] = 1
vim.g['airline#extensions#whitespace#checks'] = {'indent', 'trailing', 'conflicts'}
vim.g['airline#extensions#tabline#buffer_idx_mode'] = 1
vim.g['airline#extensions#tabline#keymap_ignored_filetypes'] = {'vimfiler', 'nerdtree', 'tagbar', 'Nvimtree'}

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


