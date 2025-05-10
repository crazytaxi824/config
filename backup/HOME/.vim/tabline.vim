vim9script

hi Selected cterm=bold ctermbg=233 ctermfg=78
hi SelectedReadOnly cterm=bold ctermbg=233 ctermfg=208
hi SelectedModified cterm=bold ctermbg=233 ctermfg=81
hi SelectedReadOnlyModified cterm=bold ctermbg=233 ctermfg=167

hi NotSelected ctermbg=236 ctermfg=246
hi NotSelectedReadOnly ctermbg=236 ctermfg=246
hi NotSelectedModified ctermbg=236 ctermfg=68
hi NotSelectedReadOnlyModified cterm=bold ctermbg=167 ctermfg=233

def g:MyTabLine(): string
	var s = ''
	var bufferNums = filter(range(1, bufnr('$')), 'buflisted(v:val)')
	#var bufferNums = filter(range(1, bufnr('$')), 'bufexists(v:val)')
	for i in bufferNums
		var name = bufname(i)
		if name == ''
			name = '[No Name]'
		endif

		# do not include netrw dir
		if isdirectory(name) == 1
			continue
		endif

		if i == bufnr('%')
			if getbufvar(i, '&readonly') && getbufvar(i, '&modified')
				s ..= '%#SelectedReadOnlyModified#'
			elseif getbufvar(i, '&readonly') && !getbufvar(i, '&modified')
				s ..= '%#SelectedReadOnly#'
			elseif !getbufvar(i, '&readonly') && getbufvar(i, '&modified')
				s ..= '%#SelectedModified#'
			else
				s ..= '%#Selected#'
			endif
		else
			if getbufvar(i, '&readonly') && getbufvar(i, '&modified')
				s ..= '%#NotSelectedReadOnlyModified#'
			elseif getbufvar(i, '&readonly') && !getbufvar(i, '&modified')
				s ..= '%#NotSelectedReadOnly#'
			elseif !getbufvar(i, '&readonly') && getbufvar(i, '&modified')
				s ..= '%#NotSelectedModified#'
			else
				s ..= '%#NotSelected#'
			endif
		endif

		s ..= ' ' .. i .. ': ' .. fnamemodify(name, ':t') .. ' │'
	endfor

	s ..= '%#TabLineFill#%T'
	return s
enddef

set tabline=%!MyTabLine()
