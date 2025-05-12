vim9script

hi clear TabLineFill
hi TabLineSel ctermfg=78 ctermbg=233
hi clear TabLine
hi TabLine ctermfg=246 ctermbg=236

# 自定义 highlight
hi Selected cterm=bold ctermbg=233 ctermfg=78
hi SelectedReadOnly cterm=bold ctermbg=233 ctermfg=208
hi SelectedModified cterm=bold ctermbg=233 ctermfg=81
hi SelectedReadOnlyModified cterm=bold ctermbg=233 ctermfg=167

hi NotSelected ctermbg=236 ctermfg=246
hi NotSelectedReadOnly ctermbg=236 ctermfg=246
hi NotSelectedModified ctermbg=236 ctermfg=68
hi NotSelectedReadOnlyModified cterm=bold ctermbg=167 ctermfg=233

hi myCurrentTab ctermfg=233 ctermbg=220
hi myOtherTab ctermfg=220
hi mySeparator ctermfg=246

def g:MyTabLine(): string
	var bn = filter(range(1, bufnr('$')), (_, val) => buflisted(val))
	var bufferNums = filter(bn, (_, val) => isdirectory(bufname(val)) == 0)  # do not include netrw dir
	#var bufferNums = filter(range(1, bufnr('$')), 'bufexists(v:val)')  # Debug
	
	var s = ''
	for i in bufferNums
		var name = bufname(i)
		if name == ''
			name = '[No Name]'
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

		s ..= ' ' .. i .. ': ' .. fnamemodify(name, ':t') .. ' %#mySeparator# '
	endfor

	s ..= '%#TabLineFill#%='

	# 显示 tabpagenr
	#'%1T 1 %T%1X × %X| %2T 2 %T%2X × %X|'  # 点击 tabnr goto tab [N], 点击 x :tabclose [N]
	#'%999X × '  # 点击 x :tabclose current
	var tabcount = tabpagenr('$')
	if tabcount > 1
		for tabnr in range(1, tabcount)
			if tabnr == tabpagenr()
				s ..= '%#myCurrentTab#%' .. tabnr .. 'T ' .. tabnr .. ' %T%#TabLineFill#'
			else
				s ..= '%#myOtherTab#%' .. tabnr .. 'T ' .. tabnr .. ' %T%#TabLineFill#'
			endif
		endfor
	endif

	return s
enddef

set tabline=%!MyTabLine()



