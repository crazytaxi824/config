vim9script

### custome keymap function ------------------------------------------------------------------------
### gk, gj 可以在 wrap 行内移动
### PageUp / PageDown
def MyPageUp()
	var c = winheight(win_getid()) / 2
	execute("normal! " .. c .. "gk")
enddef

def MyPageDown()
	var c = winheight(win_getid()) / 2
	execute("normal! " .. c .. "gj")
enddef

nnoremap <PageUp> <cmd>call <SID>MyPageUp()<CR>
nnoremap <PageDown> <cmd>call <SID>MyPageDown()<CR>

### Shift-Up/Down
var count = 3  # script scope var

def MyShiftUp()
	if v:count > 0
		count = v:count
	endif
	execute("normal! " .. count .. "gk")
enddef

def MyShiftDown()
	if v:count > 0
		count = v:count
	endif
	execute("normal! " .. count .. "gj")
enddef

nnoremap <S-Up> <cmd>call <SID>MyShiftUp()<CR>
inoremap <S-Up> <cmd>call <SID>MyShiftUp()<CR>
vnoremap <S-Up> <cmd>call <SID>MyShiftUp()<CR>
nnoremap <S-Down> <cmd>call <SID>MyShiftDown()<CR>
inoremap <S-Down> <cmd>call <SID>MyShiftDown()<CR>
vnoremap <S-Down> <cmd>call <SID>MyShiftDown()<CR>

nnoremap <S-CR> <CR>
vnoremap <S-CR> <CR>

### HOME
def MyHome()
	var before_pos = getpos('.')
	execute("normal! ^")
	var after_pos = getpos('.')
	if before_pos[2] == after_pos[2]
		execute("normal! 0")
	endif
enddef

nnoremap <HOME> <cmd>call <SID>MyHome()<CR>

### netrw ------------------------------------------------------------------------------------------
### 替换系统自动为 netrw 加载的 <buffer> keymaps
au FileType netrw nnoremap <buffer> <ESC> <cmd>bdelete<CR>
au FileType netrw nnoremap <nowait> <buffer> q <cmd>bdelete<CR>
au FileType netrw nnoremap <buffer> - <Nop>
au FileType netrw nnoremap <buffer> <S-Up> <cmd>call <SID>MyShiftUp()<CR>
au FileType netrw nnoremap <buffer> <S-Down> <cmd>call <SID>MyShiftDown()<CR>

### 进入文件夹 netrw
nnoremap <leader><CR> <cmd>execute("30Lexplore " .. expand('%:p:h')) <CR>
nnoremap <leader>; <cmd>execute("30Lexplore " .. getcwd())<CR>



