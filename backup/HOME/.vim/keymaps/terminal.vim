vim9script

def MyWipeAllTerminal()
	var x = filter(range(1, bufnr('$')), (_, buf) => getbufvar(buf, '&buftype') == 'terminal')
	execute('bdelete! ' .. join(x, ' '))
enddef

nnoremap <leader>tt <cmd>terminal<CR>
nnoremap <leader>tW <cmd>call <SID>MyWipeAllTerminal()<CR>

