""" https://learnvimscriptthehardway.stevelosh.com/chapters/27.html

scriptencoding utf-8

""" 参考: ~/.local/share/nvim/site/pack/packer/start/vim-airline/autoload/airline/extensions/tabline/formatters/short_path.vim
" function! airline#extensions#tabline#formatters#myfilename#format(bufnr, buffers)
" 	let bufname = bufname(a:bufnr)
" 	if bufname ==# ''
" 		return '[No Name]'
" 	endif
"
" 	let fname = fnamemodify(bufname(a:bufnr), ':~:.')  " 优先获取当前目录相对路径. 然后获取 ~/ 相对路径
" 	let farr = split(fname, '/', 1)
"
" 	if farr[-1] ==# ''
" 		return '[No Name]'
" 	endif
"
" 	if fname[0]==#'~'    "相对 ~/ 的路径
" 		if len(farr) < 3
" 			return fname
" 		else
" 			return printf("~/…/%s", farr[-1])   " ~/…/abc.go
" 		endif
"
" 	elseif fname[0]==#'/'   "绝对路径
" 		" farr[0] 一定是空
" 		if len(farr) < 4
" 			return fname
" 		else
" 			return printf("/%s/…/%s", farr[1], farr[-1])   " /usr/…/abc.go
" 		endif
"
" 	else    "相对当前目录的路径 ./
" 		return fnamemodify(fname, ':t')    " 只打印文件名 abc.go
" 	endif
" endfunction


""" 参考: ~/.local/share/nvim/site/pack/packer/start/vim-airline/autoload/airline/extensions/tabline/formatters/short_path.vim
function s:my_short_name(bufnr)
	let bufname = bufname(a:bufnr)
	if empty(bufname)
		return '[No Name]'
	elseif bufname =~ 'term://'
		" Neovim Terminal, strings.Replace()
		return substitute(bufname, '\(term:\)//.*:\(.*\)', '\1 \2', '')
	else
		return fnamemodify(bufname, ":t")
	endif
endfunction


""" 参考: ~/.local/share/nvim/site/pack/packer/start/vim-airline/autoload/airline/extensions/tabline/formatters/unique_tail_improved.vim
let s:skip_symbol = '…'

" changes has made:
"   1: change function name to '#myfilename' match this file name.
"   2: change 2 places - return 'airline#extensions#tabline#formatters#default#format(a:bufnr, a:buffers)' to 's:my_short_name(a:bufnr)'
function! airline#extensions#tabline#formatters#myfilename#format(bufnr, buffers)
  if len(a:buffers) <= 1 " don't need to compare bufnames if has less than one buffer opened
    return s:my_short_name(a:bufnr)  " NOTE: changes 1
  endif

  let curbuf_tail = fnamemodify(bufname(a:bufnr), ':t')
  let do_deduplicate = 0
  let path_tokens = {}

  for nr in a:buffers
    let name = bufname(nr)
    if !empty(name) && nr != a:bufnr && fnamemodify(name, ':t') == curbuf_tail " only perform actions if curbuf_tail isn't unique
      let do_deduplicate = 1
      let tokens = reverse(split(substitute(fnamemodify(name, ':p:h'), '\\', '/', 'g'), '/'))
      let token_index = 0
      for token in tokens
        if token == '' | continue | endif
        if token == '.' | break | endif
        if !has_key(path_tokens, token_index)
          let path_tokens[token_index] = {}
        endif
        let path_tokens[token_index][token] = 1
        let token_index += 1
      endfor
    endif
  endfor

  if do_deduplicate == 1
    let path = []
    let token_index = 0
    for token in reverse(split(substitute(fnamemodify(bufname(a:bufnr), ':p:h'), '\\', '/', 'g'), '/'))
      if token == '.' | break | endif
      let duplicated = 0
      let uniq = 1
      let single = 1
      if has_key(path_tokens, token_index)
        let duplicated = 1
        if len(keys(path_tokens[token_index])) > 1 | let single = 0 | endif
        if has_key(path_tokens[token_index], token) | let uniq = 0 | endif
      endif
      call insert(path, {'token': token, 'duplicated': duplicated, 'uniq': uniq, 'single': single})
      let token_index += 1
    endfor

    let buf_name = [curbuf_tail]
    let has_uniq = 0
    let has_skipped = 0
    for token1 in reverse(path)
      if !token1['duplicated'] && len(buf_name) > 1
        call insert(buf_name, s:skip_symbol)
        let has_skipped = 0
        break
      endif

      if has_uniq == 1
        call insert(buf_name, s:skip_symbol)
        let has_skipped = 0
        break
      endif

      if token1['uniq'] == 0 && token1['single'] == 1
        let has_skipped = 1
      else
        if has_skipped == 1
          call insert(buf_name, s:skip_symbol)
          let has_skipped = 0
        endif
        call insert(buf_name, token1['token'])
      endif

      if token1['uniq'] == 1
        let has_uniq = 1
      endif
    endfor

    if has_skipped == 1
      call insert(buf_name, s:skip_symbol)
    endif

    return airline#extensions#tabline#formatters#default#wrap_name(a:bufnr, join(buf_name, '/'))
  else
    return s:my_short_name(a:bufnr)  " NOTE: changes 2
  endif
endfunction


