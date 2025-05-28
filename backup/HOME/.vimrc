""" NOTE: this is VIM 9.1 settings

""" cursor shape `:help terminal-output-codes`
"   - 0, 1 or none    blinking block cursor
"   - 2               block cursor
"   - 3               blinking underline cursor
"   - 4               underline cursor
"   - 5               blinking vertical bar cursor
"   - 6               vertical bar cursor
let &t_SI = "\e[6 q"  " Insert Mode
let &t_SR = "\e[4 q"  " Replace Mode
let &t_EI = "\e[2 q"  " everything else

let mapleader = "\\"

""" mouse
"set term=xterm-256color
set mouse=a

""" 必须先加载 colorscheme, 否则以后的 highlight 设置可能无效.
colorscheme default

""" VVI
filetype on " filetype detection on
syntax on   " syntax highlight

set notermguicolors  " 在 VIM 中不使用, 如果要使用的话用 Neovim.
set nowrap

""" tabstop / shiftwidth 相关设置
const tab_width = 4
let &tabstop = tab_width  " 相当于 set tabstop=4
let &shiftwidth = tab_width
set softtabstop=-1  " -1: use shiftwidth
set noexpandtab
set nosmarttab
set textwidth=120

au FileType json,jsonc,javascript,javascriptreact,typescript,typescriptreact,
	\vue,svelte,html,css,less,scss,graphql,yaml,lua
	\ setlocal expandtab tabstop=2 shiftwidth=2

au FileType python set expandtab textwidth=79

""" 组合键延迟
set timeout
set timeoutlen=1000
set ttimeout
set ttimeoutlen=50

""" netrw
let g:netrw_banner=0
let g:netrw_liststyle=3
let g:netrw_list_hide='\.DS_Store$,.*\~$,.*\.swp$'

au WinLeave Netrw* q!

""" options
set history=300
set hidden
set noendofline
set nofixendofline
set splitbelow
set splitright
set scrolloff=4
set sidescrolloff=6
set display=lastline
set shortmess=ltToOCF

""" ins-completion-menu
set completeopt=menuone,noinsert
set pumheight=16
"set pumwidth=15

""" menu
set wildmenu
set wildmode=longest:full
set wildoptions+=fuzzy
set wildoptions+=pum

""" listchars & fillchars
set list
set listchars=tab:│\ ,trail:·,extends:→,precedes:←,nbsp:␣
set fillchars=vert:│,fold:\ ,diff:\ ,eob:~,lastline:@

def s:MyToggleChars()
	if match(&listchars, 'lead') < 0
		set listchars=tab:│->,lead:·,trail:·,extends:→,precedes:←,nbsp:␣,eol:󱞣
		echo "'listchars' & 'fillchars': Enabled"
	else
		set listchars=tab:│\ ,trail:·,extends:→,precedes:←,nbsp:␣
		echo "'listchars' & 'fillchars': Disabled"
	endif
enddef
command! ToggleChars call <SID>MyToggleChars()

""" search
set hlsearch
set ignorecase
set smartcase
set hlsearch

""" style
set showtabline=2  " 顶部显示文件名
set laststatus=2
set noshowmode

set showcmd  " 屏幕右下角显示键入的快捷键, 不是 command.
set cmdheight=2

set number  " 行号
set relativenumber  " 相对行号

set cursorline
set cursorlineopt=number,screenline

"set cursorcolumn
"set colorcolumn=+1  " highlight column after 'textwidth'
"set signcolumn=yes  " sign

""" plugins ----------------------------------------------------------------------------------------
source ~/.vim/statusline.vim
source ~/.vim/keymaps.vim
source ~/.vim/tabline.vim
source ~/.vim/format.vim
source ~/.vim/undo.vim
source ~/.vim/terminal.vim
source ~/.vim/highlights.vim
