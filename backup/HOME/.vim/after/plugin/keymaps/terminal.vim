vim9script

def MyWipeAllTerminal()
	var x = filter(range(1, bufnr('$')), (_, buf) => getbufvar(buf, '&buftype') == 'terminal')
	if len(x) > 0
		execute('bdelete! ' .. join(x, ' '))
	endif
enddef

# --- keymaps --------------------------------------------------------------------------------------
nnoremap <leader>tt <cmd>terminal<CR>
nnoremap <leader>tW <cmd>call <SID>MyWipeAllTerminal()<CR>



