vim9script

set nobackup
set nowritebackup
#set backupdir=/tmp/vim,.

set swapfile
set dir=~/.vim/swap,.

set undofile
set undolevels=1000
set undodir=/tmp/vim/undo,.

def MyCreateUndoDir()
	const dirs = ['/tmp/vim/undo', expand('~/.vim/swap')]
	for dir in dirs
		if !isdirectory(dir)
			const rs = systemlist('mkdir -p ' .. dir)
			if !v:shell_error
				echom dir .. " dir is created"
			else
				echohl WarningMsg
				for l in rs
					echom l
				endfor
				echohl None
			endif
		endif
	endfor
enddef

augroup MyUndoGroup
	autocmd!
	au VimEnter * ++once MyCreateUndoDir()
augroup END
