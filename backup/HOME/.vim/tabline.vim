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
hi NotSelectedModified ctermbg=236 ctermfg=81
hi NotSelectedReadOnlyModified cterm=bold ctermbg=167 ctermfg=233

hi myCurrentTab ctermfg=233 ctermbg=220
hi myOtherTab ctermfg=220
hi mySeparator ctermfg=246

var cached_list_buffer: list<number> = []
def g:MyTabLine(): string
	var lbs = getbufinfo({'buflisted': 1})

	# bwipeout! netrw created [No Name] buffer
	for lb in lbs
		if !empty(getbufvar(lb.bufnr, 'netrw_browser_active')) && empty(lb.name)
			# VVI: 延迟执行
			timer_start(200, (timer: number) => {
				execute('bwipeout! ' .. lb.bufnr)
			})
		endif
	endfor

	# do not include netrw
	var fbs = filter(lbs, (_, buf) => empty(getbufvar(buf.bufnr, 'netrw_browser_active')))
	var bufferNums = map(copy(fbs), (_, buf) => buf.bufnr)
	#var bufferNums = filter(range(1, bufnr('$')), 'bufexists(v:val)')  # Debug
	cached_list_buffer = bufferNums  # cache listed bufnr

	var s = ''
	for i in range(len(cached_list_buffer))
		var bufnr = cached_list_buffer[i]
		var name = bufname(bufnr)
		if name == ''
			name = '[No Name]'
		endif

		if bufnr == bufnr('%')
			if getbufvar(bufnr, '&readonly') && getbufvar(bufnr, '&modified')
				s ..= '%#SelectedReadOnlyModified#'
			elseif getbufvar(bufnr, '&readonly') && !getbufvar(bufnr, '&modified')
				s ..= '%#SelectedReadOnly#'
			elseif !getbufvar(bufnr, '&readonly') && getbufvar(bufnr, '&modified')
				s ..= '%#SelectedModified#'
			else
				s ..= '%#Selected#'
			endif
		else
			if getbufvar(bufnr, '&readonly') && getbufvar(bufnr, '&modified')
				s ..= '%#NotSelectedReadOnlyModified#'
			elseif getbufvar(bufnr, '&readonly') && !getbufvar(bufnr, '&modified')
				s ..= '%#NotSelectedReadOnly#'
			elseif !getbufvar(bufnr, '&readonly') && getbufvar(bufnr, '&modified')
				s ..= '%#NotSelectedModified#'
			else
				s ..= '%#NotSelected#'
			endif
		endif

		s ..= ' ' .. (i + 1) .. '. ' .. fnamemodify(name, ':t') .. ' %#mySeparator# '
	endfor

	# separator to tabpagenr
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

# --- keymaps --------------------------------------------------------------------------------------
def MyGotoBuffer(idx: number = (v:count1 - 1))
	var bufnr = cached_list_buffer[idx]
	if bufexists(bufnr) && buflisted(bufnr) && !isdirectory(bufname(bufnr))
		execute('buffer ' .. bufnr)
	endif
enddef

def MyPrevBuffer(): number
	var i = index(cached_list_buffer, bufnr('%'))
	return i - 1
enddef

def MyNextBuffer(): number
	var i = index(cached_list_buffer, bufnr('%'))
	var l = len(cached_list_buffer)
	if i >= l - 1
		return 0
	endif
	return i + 1
enddef

nnoremap <leader>\ <cmd>call <SID>MyGotoBuffer()<CR>

nnoremap - <cmd>call <SID>MyGotoBuffer(<SID>MyPrevBuffer())<CR>
nnoremap = <cmd>call <SID>MyGotoBuffer(<SID>MyNextBuffer())<CR>



