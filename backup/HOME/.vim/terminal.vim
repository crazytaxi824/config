vim9script

autocmd TerminalWinOpen *
	\ setlocal nonumber | setlocal norelativenumber |
	\ setlocal sidescrolloff=0 | setlocal scrolloff=0 |
	\ setlocal signcolumn=no |
	\ setlocal nobuflisted
