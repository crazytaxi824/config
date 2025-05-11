""" NOTE: this is VIM9 settings

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

""" VVI
const tab_width = 4
let &tabstop = tab_width  " 相当于 set tabstop=4
let &softtabstop = -1
let &shiftwidth = tab_width
set noexpandtab
set nosmarttab
set textwidth=120
set nowrap
set notermguicolors  " 在 VIM 中不使用, 如果要使用的话用 Neovim.

syntax on  " syntax highlight

""" 组合键延迟
set timeout
set timeoutlen=1000
set ttimeout
set ttimeoutlen=50

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

""" listchars & fillchars
set list
"set listchars=tab:│->,trail:·,extends:→,precedes:←,nbsp:␣,eol:󱞣
set listchars=tab:│\ ,lead:\ ,trail:·,extends:→,precedes:←,nbsp:␣
set fillchars=vert:│,fold:\ ,diff:\ ,eob:~,lastline:@

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

""" highlight -------------------------------------------------------------------------------------
""" CursorLine
hi clear CursorLine
hi CursorLine ctermbg=236

""" Visual selected
hi clear Visual
hi Visual ctermbg=24

""" split window
hi clear VertSplit
hi VertSplit ctermfg=236

""" 括号 {} [] ()
hi clear MatchParen
hi MatchParen cterm=underline,bold ctermfg=220

""" listchars
hi NonText ctermfg=238
hi! link SpecialKey NonText

""" Search
hi Search ctermfg=233 ctermbg=220
hi IncSearch cterm=bold ctermfg=233 ctermbg=213
hi! link CurSearch IncSearch

""" fold
hi clear Folded
hi Folded ctermfg=67

""" 行号 set number
hi LineNr ctermfg=240
hi CursorLine ctermbg=236
hi CursorLineNr ctermfg=220 cterm=bold

""" msg
hi ErrorMsg ctermfg=255 ctermbg=167
hi WarningMsg ctermfg=208

hi Todo ctermfg=22 ctermbg=255 cterm=reverse
hi SpecialComment ctermfg=63 ctermbg=255 cterm=reverse
hi Directory cterm=bold ctermfg=81

""" code
hi Keyword ctermfg=74
hi Function ctermfg=78
hi Type ctermfg=79
hi! link Identifier Normal
hi Constant ctermfg=75

hi Conditional ctermfg=213
hi! link Statement Conditional
hi! link Include Conditional

hi String ctermfg=173
hi! link Character String

hi Number ctermfg=151
hi! link Float Number

hi Boolean ctermfg=74
hi! link Special Boolean
hi! link PreProc Boolean

hi Comment ctermfg=65

""" plugins ----------------------------------------------------------------------------------------
source ~/.vim/statueline.vim
source ~/.vim/keymaps.vim
source ~/.vim/tabline.vim
source ~/.vim/format.vim
source ~/.vim/undo.vim
