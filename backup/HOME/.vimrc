vim9script

# NOTE: this is VIM 9.1 settings

# set option 在 vim9script 中可以使用
# - &option (:set option)
# - &g:option (:setglobal option - global only)
# - &l:option (:setlocal option - to buffer or window) 自动选择是 buffer-local, window-local
#set term=xterm-256color

# 防止颜色被不认识的 term 矫正, eg: xterm-ghostty
if $TERM_PROGRAM == "ghostty"
	g:loaded_colorresp = 1
endif

# cursor blink `:help terminal-output-codes`
#  - 0, 1 or none    blinking block cursor
#  - 2               block cursor
#  - 3               blinking underline cursor
#  - 4               underline cursor
#  - 5               blinking vertical bar cursor
#  - 6               vertical bar cursor
&t_SI = "\e[5 q"   # Insert Mode: 竖线闪烁
&t_SR = "\e[3 q"   # Replace Mode: 下划线闪烁
&t_EI = "\e[1 q"   # everything else: 块状闪烁

# `:help terminal-key-codes`
&t_kB = "\e[Z"  # 启用按键 <S-Tab>

# 设置 <leader>
g:mapleader = '\'  # 或者 "\\", single quote 内没有 escape

# mouse
set mouse=a

# 必须先加载 colorscheme, 否则以后的 highlight 设置可能无效.
colorscheme default

# VVI
filetype on # filetype detection on
syntax on   # syntax highlight

set notermguicolors  # 在 VIM 中不使用, 如果要使用的话用 Neovim.
set nowrap

# tabstop / shiftwidth 相关设置
const tab_width = 4
&tabstop = tab_width  # 相当于 set tabstop=4
&shiftwidth = tab_width

set softtabstop=-1  # -1: use shiftwidth
set noexpandtab
set nosmarttab
set textwidth=120

au FileType json,jsonc,javascript,javascriptreact,typescript,typescriptreact,
	\vue,svelte,html,css,less,scss,graphql,yaml,lua
	\ setlocal expandtab tabstop=2 shiftwidth=2

au FileType python setlocal expandtab textwidth=79

# 组合键延迟
set timeout
set timeoutlen=1000
set nottimeout
set ttimeoutlen=50

# netrw
g:netrw_banner = 0
g:netrw_liststyle = 3
g:netrw_list_hide = '\.DS_Store$,.*\~$,.*\.swp$'

au WinLeave Netrw* q!

# options
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

# ins-completion-menu
set completeopt=menuone,noinsert
set pumheight=16
#set pumwidth=15

# menu
set wildmenu
set wildmode=longest:full
set wildoptions+=fuzzy
set wildoptions+=pum

# listchars & fillchars
set list
set listchars=tab:│\ ,trail:·,extends:→,precedes:←,nbsp:␣
set fillchars=vert:│,fold:\ ,diff:\ ,eob:~,lastline:@

def MyToggleChars()
	if match(&listchars, 'lead') < 0
		set listchars=tab:│->,lead:·,trail:·,extends:→,precedes:←,nbsp:␣,eol:󱞣
		echo "'listchars' & 'fillchars': Enabled"
	else
		set listchars=tab:│\ ,trail:·,extends:→,precedes:←,nbsp:␣
		echo "'listchars' & 'fillchars': Disabled"
	endif
enddef
command! ToggleChars call <SID>MyToggleChars()

# search
set hlsearch
set ignorecase
set smartcase
set hlsearch

# style
set showtabline=2  # 顶部显示文件名
set laststatus=2
set noshowmode

set showcmd  # 屏幕右下角显示键入的快捷键, 不是 command.
set cmdheight=2

set number  # 行号
set relativenumber  # 相对行号

set cursorline
set cursorlineopt=number,screenline

#set cursorcolumn
set colorcolumn=+1  # highlight column after 'textwidth'
#set signcolumn=yes  # sign



