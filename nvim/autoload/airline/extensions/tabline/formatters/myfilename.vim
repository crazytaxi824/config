""" https://learnvimscriptthehardway.stevelosh.com/chapters/27.html

function! airline#extensions#tabline#formatters#myfilename#format(bufnr, buffers)
	let bufname = bufname(a:bufnr)
	if bufname ==# ''
		return '[No Name]'
	endif

	let fname = fnamemodify(bufname(a:bufnr), ':~:.')  " 优先获取当前目录相对路径. 然后获取 ~/ 相对路径
	let farr = split(fname, '/', 1)

	if farr[-1] ==# ''
		return '[No Name]'
	endif

	if fname[0]==#'~'    "相对 ~/ 的路径
		if len(farr) < 3
			return fname
		else
			return printf("~/…/%s", farr[-1])   " ~/…/abc.go
		endif

	elseif fname[0]==#'/'   "绝对路径
		" farr[0] 一定是空
		if len(farr) < 4
			return fname
		else
			return printf("/%s/…/%s", farr[1], farr[-1])   " /usr/…/abc.go
		endif

	else    "相对当前目录的路径 ./
		return fnamemodify(fname, ':t')    " 只打印文件名 abc.go
	endif
endfunction

