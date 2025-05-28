vim9script

const pairs: list<list<string>> = [
	['(', ')'], ['[', ']'], ['{', '}'], ['<', '>'], ['"', '"'], ["'", "'"], ['`', '`']
]

def MyInputPairs(ps: list<list<string>>, reverse: bool = false): dict<string>
	var result: dict<string> = {}
	for p in ps
		if reverse
			result[p[1]] = p[0]
		else
			result[p[0]] = p[1]
		endif
	endfor
	return result
enddef

const input_pairs: dict<string> = MyInputPairs(pairs)
const del_pairs: dict<string> = MyInputPairs(pairs, true)

# insert mode 下获取 cursor 前后一个 char.
def MyCharAroundCursor(): list<string>
	var [_, lnum, charcol, _] = getcharpos('.')  # [bufnum, lnum, charcol, off]
	var line = getline(lnum)

	# 获取前后字符
	var char_before = (charcol > 1) ? strcharpart(line, charcol - 2, 1) : ''
	var char_after = (charcol <= strcharlen(line)) ? strcharpart(line, charcol - 1, 1) : ''
	return [char_before, char_after]
enddef

def MyClosePair(key: string): string
	var [bc, ac] = MyCharAroundCursor()
	if !empty(bc) && !empty(ac) && del_pairs->get(ac, '') == bc
		return "\<Right>"
	endif
	return key
enddef

def MyQuotePair(key: string): string
	var [bc, ac] = MyCharAroundCursor()
	if bc != key
		return key .. key .. "\<Left>"
	elseif bc == key && ac == key
		return "\<Right>"
	endif
	return key
enddef

def MyAutoDelPair(): string
	var [bc, ac] = MyCharAroundCursor()
	if !empty(bc) && !empty(ac) && input_pairs->get(bc, '') == ac
		return "\<Del>\<BS>"
	endif
	return "\<BS>"
enddef

# return [end_insert_str, mid_insert_str]
# mid_insert_str: cursor 单独一行, 需要多一级 indent.
# end_insert_str: 反括号行, 和回车行同一级 indent.
def MyIndentStr(line: string): list<string>
	# space-indent
	if &expandtab
		var spaces = matchstr(line, '^ *')
		var n = len(spaces) / &tabstop
		return [repeat(' ', n * &tabstop), repeat(' ', (n + 1) * &tabstop)]
	endif

	# tab-indent
	var spaces = matchstr(line, '^\t*')
	var n = len(spaces)
	return [repeat("\t", n), repeat("\t", n + 1)]
enddef

# auto indent
def MyCR()
	# for autocompletion
	if pumvisible()
		feedkeys("\<CR>", 'n')
		return
	endif

	var [_, lnum, charcol, _] = getcharpos('.')
	var line = getline(lnum)
	var [end_str, mid_str] = MyIndentStr(line)

	# (|), cursor 在括号内的情况.
	var [bc, ac] = MyCharAroundCursor()
	if !empty(bc) && !empty(ac) && input_pairs->get(bc, '') == ac
		setline(lnum, trim(strcharpart(line, 0, charcol - 1), '', 2))
		append(lnum, [mid_str, end_str .. trim(strcharpart(line, charcol - 1), '', 1)])
		setcursorcharpos(lnum + 1, strlen(mid_str) + 1)
		return
	endif

	# 一般情况
	setline(lnum, trim(strcharpart(line, 0, charcol - 1), '', 2))
	append(lnum, end_str .. trim(strcharpart(line, charcol - 1), '', 1))
	setcursorcharpos(lnum + 1, strlen(end_str) + 1)
enddef

# keymaps ------------------------------------------------------------
inoremap <CR> <cmd>call <SID>MyCR()<CR>
inoremap <expr> <BS> MyAutoDelPair()

inoremap ( ()<Left>
inoremap [ []<Left>
inoremap { {}<Left>
inoremap < <><Left>

inoremap <expr> ) MyClosePair(')')
inoremap <expr> ] MyClosePair(']')
inoremap <expr> } MyClosePair('}')
inoremap <expr> > MyClosePair('>')

#cnoremap ( ()<Left>
#cnoremap <expr> ) MyClosePair(')')

inoremap <expr> ' MyQuotePair("'")
inoremap <expr> " MyQuotePair('"')
inoremap <expr> ` MyQuotePair('`')

xnoremap <leader>" <C-c>`>a"<C-c>`<i"<C-c>v`><right><right>
xnoremap <leader>' <C-c>`>a'<C-c>`<i'<C-c>v`><right><right>
xnoremap <leader>` <C-c>`>a`<C-c>`<i`<C-c>v`><right><right>
xnoremap <leader>* <C-c>`>a*<C-c>`<i*<C-c>v`><right><right>
xnoremap <leader>_ <C-c>`>a_<C-c>`<i_<C-c>v`><right><right>
xnoremap <leader>$ <C-c>`>a$<C-c>`<i$<C-c>v`><right><right>
xnoremap <leader>{ <C-c>`>a}<C-c>`<i{<C-c>v`><right><right>
xnoremap <leader>} <C-c>`>a}<C-c>`<i{<C-c>v`><right><right>
xnoremap <leader>[ <C-c>`>a]<C-c>`<i[<C-c>v`><right><right>
xnoremap <leader>] <C-c>`>a]<C-c>`<i[<C-c>v`><right><right>
xnoremap <leader>( <C-c>`>a)<C-c>`<i(<C-c>v`><right><right>
xnoremap <leader>) <C-c>`>a)<C-c>`<i(<C-c>v`><right><right>
xnoremap <leader>> <C-c>`>a><C-c>`<i<<C-c>v`><right><right>
xnoremap <leader><lt> <C-c>`>a><C-c>`<lt>i<lt><C-c>v`><right><right>

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



