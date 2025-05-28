vim9script

# `:help popup.txt`
# `:help ins-completion`
# `:help popupmenu-keys`

# insert mode 下, 获取光标前的 keywords
def MyCursorPrevKeyword(): list<string>
	# 这里不能使用 col('.'), 汉字长度和英文不同.
	var [_, lnum, charcol, _] = getcharpos('.')
	var line = getline(lnum)

	# regexp 匹配 filepath | keywrod
	var prev_keyword = matchstr(strcharpart(line, 0, charcol - 1), '\k\+$')
	var prev_filepath = matchstr(strcharpart(line, 0, charcol - 1), '\f\+/$')
	return [prev_keyword, prev_filepath]
enddef

def MyTab(): string
	if pumvisible()
		return "\<C-y>"
	endif

	var [prev_keyword, prev_filepath] = MyCursorPrevKeyword()
	if !empty(prev_keyword)
		return "\<C-x>\<C-n>"
	elseif !empty(prev_filepath)
		return "\<C-x>\<C-f>"
	endif

	return "\<Tab>"
enddef

inoremap <expr><silent> <Tab> MyTab()
inoremap <S-Tab> <Tab>

