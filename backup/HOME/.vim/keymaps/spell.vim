vim9script

# 主要函数 matchstrpos() 只能用于 byte-indexing, col().
# 所以前面使用 getpos(), 而后面需要 charidx() 来转换 index.
def ReplaceWord(cword: string, repl_str: string)
	var [_, lnum, col, _] = getpos('.')
	col = col - 1  # 0-based
	var line = getline(lnum)

	var pos = 0
	while pos < len(line)
		var [word, w_start, w_end] = matchstrpos(line, cword, pos)
		# 匹配结束
		if empty(word)
			return
		endif

		# 已找到 <cword> 位置, replace <cword>
		if col < w_end
			var prefix = strcharpart(line, 0, charidx(line, w_start))
			var suffix = strcharpart(line, charidx(line, w_end))
			setline(lnum, prefix .. repl_str .. suffix)
			cursor(lnum, w_start + 1)
			return
		endif

		# 移动到匹配结束位置, 准备下次匹配
		pos = w_end
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

	# `:help popup_create-arguments`
	popup_menu(popup_items, {
		title: "choose spell:",
		#border: [1],  # 上右下左, 1: 开启, 0: 关闭.
		padding: [0, 1, 0, 1],  # 上右下左, 空N格
		cursorline: true,  # highlight the cursor line in popup window
		#filter: 'popup_filter_menu',  # keymaps, 默认
		minwidth: 60,
		minheight: 6,
		maxheight: 18,
		callback: (winid: number, result: number) => {
			var idx = result - 1
			if idx >= 0
				var choice = popup_items[idx]
				ReplaceWord(cword, choice)
			endif
		},
	})
enddef

nnoremap z= <cmd>call <SID>PopupSpellSuggests()<CR>

