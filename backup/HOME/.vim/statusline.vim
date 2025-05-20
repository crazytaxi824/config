vim9script

# statusline 底部显示 mode() 和文件信息
hi StatusLine ctermbg=233 ctermfg=233
hi StatusLineNC ctermbg=233 ctermfg=233
hi StatusLineTerm ctermbg=233 ctermfg=233
hi StatusLineTermNC ctermbg=233 ctermfg=233

# 自定义 highlight
hi myInsertMode ctermbg=81  ctermfg=233 cterm=bold
hi myNormalMode ctermbg=220 ctermfg=233 cterm=bold
hi myReplaceMode ctermbg=124 ctermfg=251 cterm=bold
hi myVisualMode ctermbg=208 ctermfg=233 cterm=bold
hi myCommandMode ctermbg=65 ctermfg=233 cterm=bold
hi myNormalCommandB ctermbg=235 ctermfg=251
hi myNormalCommandC ctermbg=233 ctermfg=78
hi myInsertReplaceB ctermbg=20 ctermfg=251
hi myInsertReplaceC ctermbg=17 ctermfg=78
hi myVisualB ctermbg=202 ctermfg=233
hi myVisualC ctermbg=52 ctermfg=78
hi myInactive ctermbg=233 ctermfg=245

# for mix indentation & trailing whitespace warning message
hi myNormalMTC ctermbg=233 ctermfg=208 cterm=bold
hi myInsertMTC ctermbg=17  ctermfg=208 cterm=bold
hi myVisualMTC ctermbg=52  ctermfg=208 cterm=bold
hi myInactiveMTC ctermbg=233 ctermfg=208 cterm=bold

# `:help mode()`
const m = {
	n: "NORMAL", no: "O-PENDING", nov: "O-PENDING", noV: "O-PENDING", "no\<C-V>": "O-PENDING",
	niI: "NORMAL", niR: "NORMAL", niV: "NORMAL", nt: "NORMAL",
	v: "VISUAL", vs: "VISUAL", V: "V-LINE", Vs: "V-LINE", "\<C-v>": "V-BLOCK", "\<C-v>s": "V-BLOCK",
	s: "SELECT", S: "S-LINE", "\<C-s>": "S-BLOCK",
	i: "INSERT", ic: "INSERT", ix: "INSERT",
	R: "REPLACE", Rc: "REPLACE", Rx: "REPLACE", Rv: "V-REPLACE", Rvc: "V-REPLACE", Rvx: "V-REPLACE",
	c: "COMMAND", ct: "COMMAND", cr: "COMMAND",
	cv: "EX", cvr: "EX", ce: "EX",
	r: "REPLACE", rm: "MORE", 'r?': "CONFIRM", '!': "SHELL", t: "TERMINAL"
}

const normal = { A: "%#myNormalMode#", B: "%#myNormalCommandB#", C: "%#myNormalCommandC#" }
const visual = { A: "%#myVisualMode#", B: "%#myVisualB#", C: "%#myVisualC#" }
const insert = { A: "%#myInsertMode#", B: "%#myInsertReplaceB#", C: "%#myInsertReplaceC#" }
const replace = { A: "%#myReplaceMode#", B: "%#myInsertReplaceB#", C: "%#myInsertReplaceC#" }
const command = { A: "%#myCommandMode#", B: "%#myNormalCommandB#", C: "%#myNormalCommandC#" }
const inactive = { A: "%#myInactive#" }
const warn = { insert: "%#myInsertMTC#", normal: "%#myNormalMTC#", visual: "%#myVisualMTC#", inactive: "%#myInactiveMTC#" }

# VVI: 缓存 statusline 触发时的 bufnr, 和 bufnr() 获取到的可能不同.
var curr_bufnr = 0

# check trailing whitespace & mixed indentation
const bufvar_MiTs = 'my_MiTs'
const bufvar_changedtick = 'my_CT'
def g:CheckMiTs(): string
	# 排除类型
	if &buftype != '' || &filetype == 'netrw'
		return ''
	endif

	# line 超过 N 则不检查
	const max_line = 2000
	if line('$') > max_line
		return 'Ln>' .. max_line
	endif

	# bufnr() != curr_bufnr   inactive window
	# mode() !+ 'n'   not normal mode
	# bufvar_changedtick == b:changedtick   buffer not changed
	if bufnr() != curr_bufnr || mode() != 'n' ||  getbufvar(bufnr(), bufvar_changedtick, 0) == b:changedtick
		return getbufvar(bufnr(), bufvar_MiTs, '')
	endif

	# search() 是 C 语言实现, 速度快.
	var ts = search('\s\+$', 'nwc')
	var mi = search('^\(\t\+ \+\| \+\t\+\)', 'nwc')

	var msg = ''
	if ts > 0 && mi > 0
		msg = 'T:' .. ts .. ' M:' .. mi
	elseif ts > 0 && mi <= 0
		msg = 'T:' .. ts
	elseif ts <= 0 && mi > 0
		msg = 'M:' .. mi
	endif

	# cache changedtick
	setbufvar(bufnr(), bufvar_changedtick, b:changedtick)

	if msg != ''
		setbufvar(bufnr(), bufvar_MiTs, msg)
		return msg
	endif

	# delete bufvar value
	setbufvar(bufnr(), bufvar_MiTs, '')
	return ''
enddef

def FindGitRoot(): string
	var path = expand('%:p:h')
	while path !=# '/' && !isdirectory(path .. '/.git')
		path = fnamemodify(path, ':h')
	endwhile

	if isdirectory(path .. '/.git')
		return path
	endif
	# Not found
	return ''
enddef

# get git branch name or hash
const bufvar_git_time = "my_git_time"
const bufvar_git_branch = "my_git_branch"
def g:GitBranch(): string
	# 排除类型
	if &buftype != '' || &filetype == 'netrw'
		return ''
	endif

	var timenow = localtime()

	# VVI: refresh git status after N seconds
	if timenow - getbufvar(bufnr(), bufvar_git_time, 0) <= 5
		return getbufvar(bufnr(), bufvar_git_branch, '')
	endif

	# reset git_time
	setbufvar(bufnr(), bufvar_git_time, timenow)

	var dir = FindGitRoot()
	if dir == ''
		setbufvar(bufnr(), bufvar_git_branch, '')
		return ''
	endif

	var branch = system('cd ' .. dir .. ' && (git symbolic-ref --short HEAD 2>/dev/null || git rev-parse --short HEAD 2>/dev/null)')
	if branch == ''
		setbufvar(bufnr(), bufvar_git_branch, '')
		return ''
	endif

	branch = ' ' .. trim(branch)
	setbufvar(bufnr(), bufvar_git_branch, branch)
	return branch
enddef

def MyStatusLine()
	curr_bufnr = bufnr('%')

	#var statuslineStr = "%%<%s %s %s%%(  %%{GitBranch()} %%)%s %%h%%w%%m%%r%%=%%F %s%%( %%y %s  %%)%s %%3p%%%%:%%-2v "
	const sectionA = "%s%%( %s %%)"
	const sectionB = "%s%%( %%{GitBranch()} %%)"
	const sectionC = "%s%%( %%{CheckMiTs()}%%)%s"
	const sectionZ = "%%=%%<%%(%%F %%)%%(%%h%%w%%m%%r %%)"
	const sectionY = "%s%%( %%y%s %%)"
	const sectionX = "%s%%( %%3p%%%%:%%-2v %%)"

	var a = mode()
	var fe = &fileencoding
	if fe != ''
		fe = ' ' .. fe
	endif

	var wins = getwininfo()
	for win in wins
		if win.winid == win_getid()
			# 设置当前 window
			if m[a] ==? "INSERT" || m[a] ==? "TERMINAL"
				&l:statusline   = printf(sectionA, insert.A, m[a])
				&l:statusline ..= printf(sectionB, insert.B)
				&l:statusline ..= printf(sectionC, warn.insert, insert.C)
				&l:statusline ..= printf(sectionZ)
				&l:statusline ..= printf(sectionY, insert.B, fe)
				&l:statusline ..= printf(sectionX, insert.A)
			elseif m[a] ==? "REPLACE" || m[a] ==? "V-REPLACE"
				&l:statusline   = printf(sectionA, replace.A, m[a])
				&l:statusline ..= printf(sectionB, replace.B)
				&l:statusline ..= printf(sectionC, warn.insert, replace.C)
				&l:statusline ..= printf(sectionZ)
				&l:statusline ..= printf(sectionY, replace.B, fe)
				&l:statusline ..= printf(sectionX, replace.A)
			elseif m[a] ==? "VISUAL" || m[a] ==? "V-LINE" || m[a] ==? "V-BLOCK" || m[a] ==? "SELECT" || m[a] ==? "S-LINE" || m[a] ==? "S-BLOCK"
				&l:statusline   = printf(sectionA, visual.A, m[a])
				&l:statusline ..= printf(sectionB, visual.B)
				&l:statusline ..= printf(sectionC, warn.visual, visual.C)
				&l:statusline ..= printf(sectionZ)
				&l:statusline ..= printf(sectionY, visual.B, fe)
				&l:statusline ..= printf(sectionX, visual.A)
			elseif m[a] ==? "COMMAND"
				&l:statusline   = printf(sectionA, command.A, m[a])
				&l:statusline ..= printf(sectionB, command.B)
				&l:statusline ..= printf(sectionC, warn.normal, command.C)
				&l:statusline ..= printf(sectionZ)
				&l:statusline ..= printf(sectionY, command.B, fe)
				&l:statusline ..= printf(sectionX, command.A)
			else
				# Normal & Other modes
				&l:statusline   = printf(sectionA, normal.A, m[a])
				&l:statusline ..= printf(sectionB, normal.B)
				&l:statusline ..= printf(sectionC, warn.normal, normal.C)
				&l:statusline ..= printf(sectionZ)
				&l:statusline ..= printf(sectionY, normal.B, fe)
				&l:statusline ..= printf(sectionX, normal.A)
			endif
		else
			# 设置其他 window
			var inactiveSL = printf("%%<%s %%{CheckMiTs()}%s%%=%%f %%(%%m%%r %%)", warn.inactive, inactive.A)
			setwinvar(win.winid, '&statusline', inactiveSL)
		endif
	endfor
enddef

augroup MyStatusLineGroup
	autocmd!
	au VimEnter * ++once MyStatusLine()
	au WinEnter,BufEnter,Modechanged * MyStatusLine()
augroup END



