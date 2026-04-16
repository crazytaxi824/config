vim9script

def MyGetCommentPrefix(): string
	var comment_char = {
		'python': '#',
		'sh': '#',
		'vim': '"',
		'javascript': '//',
		'typescript': '//',
		'go': '//',
		'lua': '--',
		'c': '//',
		'cpp': '//',
		'java': '//',
		'rust': '//',
		'json': '//',
		'toml': '#',
	}
	if &filetype == 'vim' && getbufoneline(bufnr(), 1) =~? 'vim9script'
		comment_char['vim'] = '#'
	endif
	return comment_char->get(&filetype, '//')  # 默认用 //
enddef

# 获取 line 中第一个字符的 charpos
def MyIndentStr(line: string): string
	# space-indent
	if &expandtab
		var spaces = matchstr(line, '^ *')
		var n = len(spaces) / &tabstop
		return repeat(' ', n * &tabstop)
	endif

	# tab-indent
	var tabs = matchstr(line, '^\t*')
	var n = len(tabs)
	return repeat("\t", n)
enddef

def MyToggleComment(start: number, end: number)
	var comm_chars = MyGetCommentPrefix()
	var lines = getline(start, end)

	# 检查是否已经注释
	var is_commented = true
	var n = 999
	var indent_prefix = ''
	for line in lines
		if line !~ '^\s*' .. comm_chars
			is_commented = false
		endif
		if line != ''
			var ip = MyIndentStr(line)
			if n > len(ip)
				n = len(ip)
				indent_prefix = ip
			endif
		endif
	endfor

	# 注释或取消注释
	for i in range(lines->len())
		var lnum = start + i
		if is_commented
			if lines[i] =~ '^\s*' .. comm_chars .. '$'
				# 取消空行注释
				setline(lnum, substitute(lines[i], '^\s*' .. comm_chars .. '$', '', ''))
			else
				# 正常取消注释, 注释字符后有一个或者没有空格.
				setline(lnum, substitute(lines[i], '^\s*' .. comm_chars .. ' \?', indent_prefix, ''))
			endif
		else
			if lines[i] != ''
				# 正常注释
				setline(lnum, indent_prefix .. comm_chars .. ' ' .. strcharpart(lines[i], n))
			else
				# 给空行注释
				setline(lnum, indent_prefix .. comm_chars)
			endif
		endif
	endfor
enddef

# --- keymaps --------------------------------------------------------------------------------------
nnoremap gc <cmd>call <SID>MyToggleComment(line('.'), line('.'))<CR>
xnoremap gc <C-c><cmd>call <SID>MyToggleComment(line("'<"), line("'>"))<CR>



