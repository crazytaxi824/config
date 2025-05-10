""" this is not a vim9script

""" normal setting ---------------------------------------------------------------------------------
nnoremap <S-Up> <C-u>
nnoremap <S-Down> <C-d>
tnoremap <ESC> <C-\><C-n>
nnoremap <tab> <C-w><C-w>

nnoremap D "_dd
xnoremap D "_x

vnoremap <leader>y "*y

""" 进入文件夹
nnoremap <leader><CR> <cmd>execute("edit" .. fnamemodify(bufname(), ':p:h')) <CR>
nnoremap <leader>; <cmd>e .<CR>

""" 自动括号
vnoremap <leader>" <C-c>`>a"<C-c>`<i"<C-c>v`><right><right>
vnoremap <leader>' <C-c>`>a'<C-c>`<i'<C-c>v`><right><right>
vnoremap <leader>` <C-c>`>a`<C-c>`<i`<C-c>v`><right><right>
vnoremap <leader>* <C-c>`>a*<C-c>`<i*<C-c>v`><right><right>
vnoremap <leader>_ <C-c>`>a_<C-c>`<i_<C-c>v`><right><right>
vnoremap <leader>$ <C-c>`>a$<C-c>`<i$<C-c>v`><right><right>
vnoremap <leader>{ <C-c>`>a}<C-c>`<i{<C-c>v`><right><right>
vnoremap <leader>} <C-c>`>a}<C-c>`<i{<C-c>v`><right><right>
vnoremap <leader>[ <C-c>`>a]<C-c>`<i[<C-c>v`><right><right>
vnoremap <leader>] <C-c>`>a]<C-c>`<i[<C-c>v`><right><right>
vnoremap <leader>( <C-c>`>a)<C-c>`<i(<C-c>v`><right><right>
vnoremap <leader>) <C-c>`>a)<C-c>`<i(<C-c>v`><right><right>
vnoremap <leader>> <C-c>`>a><C-c>`<i<<C-c>v`><right><right>
vnoremap <leader><lt> <C-c>`>a><C-c>`<lt>i<lt><C-c>v`><right><right>

nnoremap <leader>" viw<C-c>`>a"<C-c>`<i"<C-c>
nnoremap <leader>' viw<C-c>`>a'<C-c>`<i'<C-c>
nnoremap <leader>` viw<C-c>`>a`<C-c>`<i`<C-c>
nnoremap <leader>* viw<C-c>`>a*<C-c>`<i*<C-c>
nnoremap <leader>_ viw<C-c>`>a_<C-c>`<i_<C-c>
nnoremap <leader>$ viw<C-c>`>a$<C-c>`<i$<C-c>
nnoremap <leader>{ viw<C-c>`>a}<C-c>`<i{<C-c>
nnoremap <leader>} viw<C-c>`>a}<C-c>`<i{<C-c>
nnoremap <leader>[ viw<C-c>`>a]<C-c>`<i[<C-c>
nnoremap <leader>] viw<C-c>`>a]<C-c>`<i[<C-c>
nnoremap <leader>( viw<C-c>`>a)<C-c>`<i(<C-c>
nnoremap <leader>) viw<C-c>`>a)<C-c>`<i(<C-c>
nnoremap <leader>> viw<C-c>`>a><C-c>`<i<<C-c>
nnoremap <leader><lt> viw<C-c>`>a><C-c>`<lt>i<lt><C-c>

""" <Nop>
nnoremap s <Nop>
inoremap s <Nop>
vnoremap s <Nop>

""" <Ctrl-Z> 是危险操作. 意思是 :stop. Suspend vim, 退出到 terminal 界面, 但保留 job.
""" 需要使用 `jobs -l` 列出 Suspended 列表, 使用 `fg %1` 恢复 job, 或者 `kill %1` (不推荐, 会留下 .swp 文件)
nnoremap <C-z> <Nop>
vnoremap <C-z> <Nop>

nnoremap ZZ <Nop>
nnoremap ZQ <Nop>

nnoremap <F1> <Nop>
inoremap <F1> <Nop>

""" 替换系统自动为 netrw 加载的 <buffer> keymaps
au FileType netrw nnoremap <buffer> - <Nop>
au FileType netrw nmap <buffer> <S-Up> <cmd>call <SID>MyShiftUp()<CR>
au FileType netrw nmap <buffer> <S-Down> <cmd>call <SID>MyShiftDown()<CR>

""" custome keymap function ------------------------------------------------------------------------
""" gk, gj 可以在 wrap 行内移动
""" PageUp / PageDown
def s:MyPageUp()
	var c = winheight(win_getid()) / 2
	execute("normal! " .. c .. "gk")
enddef

def s:MyPageDown()
	var c = winheight(win_getid()) / 2
	execute("normal! " .. c .. "gj")
enddef

nnoremap <PageUp> <cmd>call <SID>MyPageUp()<CR>
nnoremap <PageDown> <cmd>call <SID>MyPageDown()<CR>

""" Shift-Up/Down
let s:count = 3  " script scope var

def s:MyShiftUp()
	if v:count > 0
		count = v:count
	endif
	execute("normal! " .. count .. "gk")
enddef

def s:MyShiftDown()
	if v:count > 0
		count = v:count
	endif
	execute("normal! " .. count .. "gj")
enddef

nnoremap <S-Up> <cmd>call <SID>MyShiftUp()<CR>
nnoremap <S-Down> <cmd>call <SID>MyShiftDown()<CR>

""" HOME
def s:MyHome()
	var before_pos = getpos('.')
	execute("normal! ^")
	var after_pos = getpos('.')
	if before_pos[2] == after_pos[2]
		execute("normal! 0")
	endif
enddef

nnoremap <HOME> <cmd>call <SID>MyHome()<CR>

""" -, = switch buffer -----------------------------------------------------------------------------
def s:MyPrevBuffer()
	var bn = filter(range(1, bufnr('$')), (_, val) => buflisted(val))
	var bufferNums = filter(bn, (_, val) => isdirectory(bufname(val)) == 0)  # do not include netrw dir
	var i = index(bufferNums, bufnr('%'))

	if i < 1
		execute('buffer ' .. bufferNums[0])
	else
		execute('buffer ' .. bufferNums[i - 1])
	endif
enddef

def s:MyNextBuffer()
	var bn = filter(range(1, bufnr('$')), (_, val) => buflisted(val))
	var bufferNums = filter(bn, (_, val) => isdirectory(bufname(val)) == 0)  # do not include netrw dir
	var i = index(bufferNums, bufnr('%'))
	var l = len(bufferNums)

	if i < 0
		execute('buffer ' .. bufferNums[0])
	elseif i >= l - 1
		execute('buffer ' .. bufferNums[l - 1])
	else
		execute('buffer ' .. bufferNums[i + 1])
	endif
enddef

nnoremap - <cmd>call <SID>MyPrevBuffer()<CR>
nnoremap = <cmd>call <SID>MyNextBuffer()<CR>



