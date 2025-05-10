vim9script

def MyCreateUndoDir()
	const undodir = '/tmp/vim/undo'
	if isdirectory(undodir) == 0
		const rs = systemlist('mkdir -p /tmp/vim/undo')
		if v:shell_error == 0
			echom " /tmp/vim/undo/ dir is created"
		else
			echohl WarningMsg
			for l in rs
				echom l
			endfor
			echohl None
		endif
	endif
enddef

augroup MyUndoGroup
	autocmd!
	au VimEnter * ++once MyCreateUndoDir()
augroup END
