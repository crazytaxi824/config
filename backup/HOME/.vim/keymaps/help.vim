vim9script

def g:MyHelpVisual()
	# 中文字符和行使用 getpos() 获取的位置不对. 需要使用 getcharpos()
	# getpos() 获取视觉选区的起止位置
	var start = getcharpos("'<")
	var end = getcharpos("'>")

	if start[1] != end[1]
		return
	endif

	var line = getline(start[1])
	var msg = line[(start[2] - 1) : (end[2] - 1)]
	execute('help ' .. msg)
enddef

nnoremap K <cmd>call execute('help ' .. expand('<cword>'))<CR>
xnoremap K <C-c><cmd>call MyHelpVisual()<CR>

