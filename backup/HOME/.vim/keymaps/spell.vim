vim9script

def ReplaceWord(cword: string, repl_str: string)
	var lnum = line('.')
	var lineText = getline(".")
	var col = col('.') - 1  # 0-based

	var pos = 0
	while pos < len(lineText)
		var [word, w_start, w_end] = matchstrpos(lineText, cword, pos)
		if empty(word)
			break
		endif
		if w_start <= col && col < w_end
			# 找到 <cword> 位置, replace <cword>
			var prefix = strcharpart(lineText, 0, charidx(lineText, w_start))
			var suffix = strcharpart(lineText, charidx(lineText, w_end))
			setline(lnum, prefix .. repl_str .. suffix)
			return
		endif
		pos = w_end  # 移动到匹配结束位置, 准备下次匹配
	endwhile
enddef

def PopupSpellSuggests()
	var cword = expand('<cword>')
	if empty(cword)
		return
	endif

	var popup_items = spellsuggest(cword)
	if empty(popup_items)
		return
	endif

	# 回调函数：当用户选择某个选项后执行
	def MyPopupCallback(winid: number, result: number)
		var idx = result - 1
		if idx >= 0
			var choice = popup_items[idx]
			ReplaceWord(cword, choice)
		endif
	enddef

	# `:help popup_create-arguments`
	popup_menu(popup_items, {
		callback: MyPopupCallback,
		title: "choose spell:",
		#border: [1],  # 上右下左, 1: 开启, 0: 关闭.
		padding: [0, 1, 0, 1],  # 上右下左, 空N格
		cursorline: true,  # highlight the cursor line in popup window
		#filter: 'popup_filter_menu',  # keymaps, 默认
		minwidth: 60,
		minheight: 6,
		maxheight: 18,
	})
enddef

nnoremap z= <cmd>call <SID>PopupSpellSuggests()<CR>


