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



