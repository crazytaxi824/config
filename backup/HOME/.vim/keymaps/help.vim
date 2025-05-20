vim9script

def g:MyHelpVisual()
	# 获取视觉选区的起止位置
	var start = getpos("'<")
	var end = getpos("'>")

	if start[1] != end[1]
		return
	endif

	var line = getline(start[1])
	execute('help ' .. line[(start[2] - 1) : (end[2] - 1)])
enddef

nnoremap K <cmd>call execute('help ' .. expand('<cword>'))<CR>
xnoremap K <C-c><cmd>call MyHelpVisual()<CR>

