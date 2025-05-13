""" -, = switch buffer -----------------------------------------------------------------------------
def s:MyPrevBuffer(): number
	var lbs = getbufinfo({'buflisted': 1})
	var fbs = filter(lbs, (_, item) => !isdirectory(item->get('name')))  # do not include netrw dir
	var bufferNums = map(copy(fbs), (_, item) => item->get('bufnr'))
	var i = index(bufferNums, bufnr('%'))
	var l = len(bufferNums)
	if l > 0
		if i < 0
			return bufferNums[0]
		elseif i > 0
			return bufferNums[i - 1]
		endif
	endif
	return -1
enddef

def s:MyNextBuffer(): number
	var lbs = getbufinfo({'buflisted': 1})
	var fbs = filter(lbs, (_, item) => !isdirectory(item->get('name')))  # do not include netrw dir
	var bufferNums = map(copy(fbs), (_, item) => item->get('bufnr'))
	var i = index(bufferNums, bufnr('%'))
	var l = len(bufferNums)
	if l > 0
		if i < 0
			return bufferNums[0]
		elseif i < l - 1
			return bufferNums[i + 1]
		endif
	endif
	return -1
enddef

""" <leader>d - delete buffer/tab ------------------------------------------------------------------
def s:MyDeleteBufferAndTab()
	var tabcount = tabpagenr('$')
	if tabcount <= 1
		# only 1 tab, close curren buffer
		var lbs = getbufinfo({'buflisted': 1})
		var fbs = filter(lbs, (_, item) => !isdirectory(item->get('name')))  # do not include netrw dir
		var bufferNums = map(copy(fbs), (_, item) => item->get('bufnr'))
		var i = index(bufferNums, bufnr('%'))
		var l = len(bufferNums)
		if l < 1
			# no buflisted buffer exists
			bdelete
			return
		endif

		if &modified
			echohl WarningMsg | echom "cannot :bdelete unsaved buffer" | echohl None
			return
		endif

		var curr_bufnr = bufnr('%')
		if i < 0
			execute('buffer ' .. bufferNums[0])
		elseif i == 0 && l <= 1
			echohl WarningMsg | echom "cannot :bdelete last listed-buffer" | echohl None
			return
		elseif i == 0 && l > 1
			execute('buffer ' .. bufferNums[1])
		else
			execute('buffer ' .. bufferNums[i - 1])
		endif

		execute('bdelete ' .. curr_bufnr)
		redrawtabline
		return
	endif

	# keep 1st tab
	if tabpagenr() == 1
		echohl WarningMsg | echom "cannot :tabclose 1-st tab" | echohl None
		return
	endif

	# tabclose & bdelete all the buffer in this tab
	var firstTabBufs = tabpagebuflist(1)
	var currTabBufs = tabpagebuflist()
	var bdBufs = filter(currTabBufs, (_, val) => index(firstTabBufs, val) < 0)

	for bufnr in bdBufs
		if getbufvar(bufnr, '&modified')
			echohl WarningMsg | echom "tabpage has unsaved buffers" | echohl None
			return
		endif
	endfor
	
	tabfirst
	execute('bdelete ' .. join(bdBufs, ' '))
	redrawtabline
enddef

def s:MyDeleteOtherBuffers()
	var listedbufs = getbufinfo({'buflisted': 1})
	for buf in listedbufs
		if !buf.changed && buf.hidden
			execute('bdelete ' .. buf.bufnr)
		endif
	endfor
	redrawtabline
enddef

def s:MyGotoBuffer(bufnr: number = v:count1)
	if bufexists(bufnr) && buflisted(bufnr) && !isdirectory(bufname(bufnr))
		execute('buffer ' .. bufnr)
	endif
enddef

nnoremap <leader>d <cmd>call <SID>MyDeleteBufferAndTab()<CR>
nnoremap <leader>Da <cmd>call <SID>MyDeleteOtherBuffers()<CR>

nnoremap - <cmd>call <SID>MyGotoBuffer(<SID>MyPrevBuffer())<CR>
nnoremap = <cmd>call <SID>MyGotoBuffer(<SID>MyNextBuffer())<CR>
nnoremap <leader>\ <cmd>call <SID>MyGotoBuffer()<CR>


