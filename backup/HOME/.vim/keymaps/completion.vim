vim9script

# `:help popup.txt`
# `:help ins-completion`
# `:help popupmenu-keys`

# insert mode 下, 获取光标前的 keywords
def CursorPrevKeyword(): list<string>
	# 这里不能使用 col('.'), 汉字长度和英文不同.
	var charCol = getcharpos('.')[2] - 1
	var line = getline('.')
	var prev_filepath = matchstr(line[0 : charCol - 1], '\f\+/$')
	var prev_keyword = matchstr(line[0 : charCol - 1], '\k\+$')
	return [prev_keyword, prev_filepath]
enddef

def MyTab(): string
	if pumvisible()
		return "\<C-y>"
	endif

	var [prev_keyword, prev_filepath] = CursorPrevKeyword()
	if !empty(prev_keyword)
		return "\<C-x>\<C-n>"
	elseif !empty(prev_filepath)
		return "\<C-x>\<C-f>"
	endif

	return "\<Tab>"
enddef

inoremap <expr> <Tab> MyTab()
inoremap <S-Tab> <Tab>



