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
set timeoutlen=600
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

set list
"set listchars=tab:│->,trail:·,extends:→,precedes:←,nbsp:␣,eol:󱞣
set listchars=tab:\ \ ,lead:·,trail:·,extends:→,precedes:←,nbsp:␣
set fillchars=vert:│,fold:\ ,diff:\ ,eob:~,lastline:@

set hlsearch
set ignorecase
set smartcase
set hlsearch

""" style
set showtabline=2  " 顶部显示文件名
set laststatus=2
"set showmode

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

""" tabline 顶部显示文件名
hi clear TabLineFill
hi TabLineSel ctermfg=78 ctermbg=233

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

hi StatusLine ctermbg=233 ctermfg=233
hi StatusLineNC ctermbg=233 ctermfg=233
hi StatusLineTerm ctermbg=233 ctermfg=233
hi StatusLineTermNC ctermbg=233 ctermfg=233

""" keymaps ----------------------------------------------------------------------------------------
nnoremap <S-Up> <C-u>
nnoremap <S-Down> <C-d>
tnoremap <ESC> <C-\><C-n>
vnoremap <leader>y "*y
"nnoremap <M-z> u

""" statusline -------------------------------------------------------------------------------------
"set statusline=%<%f\ %h%m%r%=%-14.(%l,%c%V%)\ %P
hi myInsertMode ctermbg=81  ctermfg=233 cterm=bold
hi myNormalMode ctermbg=220 ctermfg=233 cterm=bold
hi myReplaceMode ctermbg=124 ctermfg=251 cterm=bold
hi myVisualMode ctermbg=208 ctermfg=233 cterm=bold
hi myCommandMode ctermbg=65 ctermfg=233 cterm=bold
hi myNormalCommandB ctermbg=236 ctermfg=251
hi myNormalCommandC ctermbg=233 ctermfg=78
hi myInsertReplaceB ctermbg=20 ctermfg=251
hi myInsertReplaceC ctermbg=17 ctermfg=78
hi myVisualB ctermbg=202 ctermfg=233
hi myVisualC ctermbg=52 ctermfg=78
hi myInactive ctermbg=233 ctermfg=245

""" statusline
def MyStatusLine()
	var m = {
		n: "NORMAL", no: "O-PENDING", nov: "O-PENDING", noV: "O-PENDING", "no\<C-V>": "O-PENDING",
		niI: "NORMAL", niR: "NORMAL", niV: "NORMAL", nt: "NORMAL",
		v: "VISUAL", vs: "VISUAL", V: "V-LINE", Vs: "V-LINE", "\<C-v>": "V-BLOCK", "\<C-v>s": "V-BLOCK",
		s: "SELECT", S: "S-LINE", "\<C-s>": "S-BLOCK",
		i: "INSERT", ic: "INSERT", ix: "INSERT",
		R: "REPLACE", Rc: "REPLACE", Rx: "REPLACE", Rv: "V-REPLACE", Rvc: "V-REPLACE", Rvx: "V-REPLACE",
		c: "COMMAND", ct: "COMMAND", cr: "COMMAND",
		cv: "EX", cvr: "EX", ce: "EX",
		r: "REPLACE", rm: "MORE", 'r?': "CONFIRM", '!': "SHELL", t: "TERMINAL"
	}

	var normal = { A: "%#myNormalMode#", B: "%#myNormalCommandB#", C: "%#myNormalCommandC#" }
	var visual = { A: "%#myVisualMode#", B: "%#myVisualB#", C: "%#myVisualC#" }
	var insert = { A: "%#myInsertMode#", B: "%#myInsertReplaceB#", C: "%#myInsertReplaceC#" }
	var replace = { A: "%#myReplaceMode#", B: "%#myInsertReplaceB#", C: "%#myInsertReplaceC#" }
	var command = { A: "%#myCommandMode#", B: "%#myNormalCommandB#", C: "%#myNormalCommandC#" }
	var inactive = { A: "%#myInactive#" }

	var a = mode()
	var statuslineStr = "%%<%s %s %s %%h%%w%%m%%r%%=%%f %s %%y %s %%l:%%v (c:%%c) "

	var wins = getwininfo()
	for win in wins
		if win.winid == win_getid()
			if m[a] ==? "INSERT" || m[a] ==? "TERMINAL"
				&l:statusline = printf(statuslineStr, insert.A, m[a], insert.C, insert.B, insert.A)
				return
			elseif m[a] ==? "REPLACE" || m[a] ==? "V-REPLACE"
				&l:statusline = printf(statuslineStr, replace.A, m[a], replace.C, replace.B, replace.A)
				return
			elseif m[a] ==? "VISUAL" || m[a] ==? "V-LINE" || m[a] ==? "V-BLOCK" || m[a] ==? "SELECT" || m[a] ==? "S-LINE" || m[a] ==? "S-BLOCK"
				&l:statusline = printf(statuslineStr, visual.A, m[a], visual.C, visual.B, visual.A)
				return
			elseif m[a] ==? "COMMAND"
				&l:statusline = printf(statuslineStr, command.A, m[a], command.C, command.B, command.A)
				return
			else
				&l:statusline = printf(statuslineStr, normal.A, m[a], normal.C, normal.B, normal.A)
			endif
		else
			var inactiveSL = printf("%%<%s %%f %%m%%r%%=%%y ", inactive.A)
			setwinvar(win.winid, '&statusline', inactiveSL)
		endif
	endfor
enddef

""" autocmd
au VimEnter * ++once call MyStatusLine()
au WinEnter,BufEnter,Modechanged * call MyStatusLine()



