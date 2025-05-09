vim9script

def g:MyTabLine(): string
	var s = ''
	var bufferNums = filter(range(1, bufnr('$')), 'buflisted(v:val)')
	for i in bufferNums
		var name = bufname(i)
		if name == ''
			name = '[No Name]│'
		endif

		if isdirectory(name) == 0
			if i == bufnr('%')
				s ..= '%#TabLineSel#'
			else
				s ..= '%#TabLine#'
			endif
			s ..= ' ' .. i .. ': ' .. fnamemodify(name, ':t') .. ' │'
		endif
	endfor
	s ..= '%#TabLineFill#%T'
	return s
enddef

set tabline=%!MyTabLine()
