vim9script

# `:help popup.txt`
# `:help ins-completion`
# `:help popupmenu-keys`

# 根据 current cursor line 获取 start | end line number, 用于 get keywords
def GetCursorlineRange(max_line: number = 600): list<number>
	var lnum_cur = line('.')  # 当前行
	var total = line('$')     # 总行数
	var half = float2nr(max_line / 2)

	var start = 1
	var end = 1
	if total <= max_line
		end = total
	elseif total - lnum_cur <= half
		start = total - max_line
		end = total
	elseif lnum_cur <= half
		start = 1
		end = max_line
	else
		start = lnum_cur - half
		end = lnum_cur + half
	endif
	return [start, end]
enddef

# 获取 window 内 buffer 显示的 start | end line number, 用于 get keywords
def GetWinLines(winid: number): list<number>
	var wininfo = getwininfo(winid)
	if empty(wininfo)
		return [-1, 0, 0]
	endif
	var bufnr = wininfo[0]->get('bufnr', -1)
	return [bufnr, line('w0', winid), line('w$', winid)]
enddef

# 获取 buffer 中的 keywords. 结果使用 dict 缓存, 自动去重
def GetBufferKeywords(bufnr: number, start: number, end: number): dict<bool>
	var result: dict<bool> = {}
	# 遍历每一行, 逐行读取内容而不是一次性读取所有行的内容.
	for lnum in range(start, end)
		var line = getbufoneline(bufnr, lnum)
		var pos = 0
		while pos < len(line)
			var [word, w_start, w_end] = matchstrpos(line, '\k\+', pos)
			if empty(word)
				break  # break while, not for loop
			endif
			if len(word) > 1
				result[word] = true  # 记录到字典中
			endif
			pos = w_end  # 移动到匹配结束位置, 准备下次匹配
		endwhile
	endfor
	return result
enddef

# insert mode 下, 获取光标前的 keywords
def CursorPrevKeyword(): list<string>
	# 这里不能使用 col('.'), 汉字长度和英文不同.
	var charCol = getcharpos('.')[2] - 1
	var line = getline('.')
	var prev_filepath = matchstr(line[0 : charCol - 1], '\f\+/$')
	var prev_keyword = matchstr(line[0 : charCol - 1], '\k\+$')
	return [prev_keyword, prev_filepath]
enddef

# NOTE: cache keywords, 减少计算量. 使用 dict 缓存, 自动去重.
var cached_keywords: list<string> = []
var cached_bufnr = -1
var cached_tick = -1

# completion for buffer keywords
def BufferCompletion(prev_keyword: string)
	var bufnr = bufnr()
	var tick = getbufvar(bufnr, 'changedtick')

	# 更新 current buffer keywords list
	if cached_bufnr != bufnr || cached_tick != tick
		var [start, end] = GetCursorlineRange()
		cached_keywords = keys(GetBufferKeywords(bufnr, start, end))
		cached_bufnr = bufnr
		cached_tick = tick
	endif

	# 获取其他 window 中正在显示的 lines 的 keywords
	var winwords: dict<bool> = {}
	for wininfo in getwininfo()
		if wininfo.bufnr != bufnr
			var [win_bufnr, win_start, win_end] = GetWinLines(wininfo.winid)
			if win_bufnr > 0
				extend(winwords, GetBufferKeywords(win_bufnr, win_start, win_end))
			endif
		endif
	endfor

	# 根据前缀生成动态候选项
	var matched_items = filter(copy(cached_keywords), (_, val) => val =~? '^' .. prev_keyword .. '\k')
	var win_items = filter(copy(keys(winwords)), (_, val) => val =~? '^' .. prev_keyword .. '\k')

	# insert & Replace mode 才执行 complete()
	if mode() =~# '^[iR]' && !empty(matched_items)
		# 执行补全，startcol 是 prev_keyword 的起始列（1-based）
		complete(col('.') - len(prev_keyword), uniq(sort(matched_items + win_items)))  # + 合并两个 list
	endif
enddef

# completion for filepath, prev_filepath 结尾必须是 /
def FilepathCompletion(prev_filepath: string)
	# glob() 中 ~/ 路径会被转成绝对路径
	var filepaths = glob(prev_filepath .. "*", true, true)

	# 入参 v 是 glob() 返回的路径
	# isdirectory() 不能判断 ~/ 相对路径, 这里正好和 glob() 配合使用.
	def KeepPrevFilepath(_, v: string): string
		var result = v
		var head = fnamemodify(v, ':h') .. '/'
		if head != prev_filepath
			# 如果 glob() 将 ~/ 转成了绝对路径, 则在这里转回 ~/
			result = substitute(v, head, prev_filepath, '')
		endif

		if isdirectory(v)
			return result .. '/'
		endif
		return result
	enddef
	filepaths = filepaths->map(KeepPrevFilepath)

	# insert & Replace mode 才执行 complete()
	if mode() =~# '^[iR]' && !empty(filepaths)
		# 执行补全，startcol 是 prev_keyword 的起始列（1-based）
		complete(col('.') - len(prev_filepath), filepaths)
	endif
enddef

def SmartCompletion(timer: number)
	# 如果complete menu 已经打开, 则不做任何操作.
	if pumvisible()
		return
	endif

	# 从光标前提取出一个 keyword 用于匹配
	var curprev_keyword = CursorPrevKeyword()
	var prev_keyword = curprev_keyword[0]
	var prev_filepath = curprev_keyword[1]
	if empty(prev_keyword) && empty(prev_filepath)
		return
	endif

	if !empty(prev_keyword)
		BufferCompletion(prev_keyword)
		return
	endif

	if !empty(prev_filepath)
		FilepathCompletion(prev_filepath)
		return
	endif
enddef

# 实现 time interval
var prev_timer_id = 0
def Interval()
	# 使用 500ms, 经测试 delete 过程中不会触发 auto cmp
	var id = timer_start(500, SmartCompletion)
	timer_stop(prev_timer_id)
	prev_timer_id = id
enddef

# ---  for keymaps ---------------------------------------------------------------------------------
def MyCompletionConfirm(fallback_key: string): string
	if pumvisible()
		return "\<C-y>"
	endif
	return fallback_key
enddef

def MyCompletionCancel(fallback_key: string): string
	if pumvisible()
		return "\<C-e>"
	endif
	return fallback_key
enddef

# 自动触发 completion menu
autocmd TextChangedI * Interval()

# confirm selection
inoremap <expr> <Tab> MyCompletionConfirm("\<Tab>")
#inoremap <expr> <CR>  MyCompletionConfirm("\<CR>")
#inoremap <expr> <ESC> MyCompletionCancel("\<ESC>")


