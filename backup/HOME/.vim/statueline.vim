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
hi myNormalCommandB ctermbg=236 ctermfg=251
hi myNormalCommandC ctermbg=233 ctermfg=78
hi myInsertReplaceB ctermbg=20 ctermfg=251
hi myInsertReplaceC ctermbg=17 ctermfg=78
hi myVisualB ctermbg=202 ctermfg=233
hi myVisualC ctermbg=52 ctermfg=78
hi myInactive ctermbg=233 ctermfg=245

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

def g:GitBranch(): string
	var dir = fnamemodify(bufname(), ':p:h')
	var branch = system('cd ' .. dir ..  ' && git rev-parse --abbrev-ref HEAD')
	if !v:shell_error
		return '  ' .. substitute(branch, '\n', '', '')
	endif
	return ' - '
enddef

def MyStatusLine()
	var a = mode()
	var statuslineStr = "%%<%s %s %s %%{GitBranch()} %s %%h%%w%%m%%r%%=%%F %s %%y%s %s %%3p%%%%:%%-2v "
	var fe = &fileencoding
	if fe != ''
		fe = ' ' .. fe .. ' '
	endif

	var wins = getwininfo()
	for win in wins
		if win.winid == win_getid()
			if m[a] ==? "INSERT" || m[a] ==? "TERMINAL"
				&l:statusline = printf(statuslineStr, insert.A, m[a], insert.B, insert.C, insert.B, fe, insert.A)
			elseif m[a] ==? "REPLACE" || m[a] ==? "V-REPLACE"
				&l:statusline = printf(statuslineStr, replace.A, m[a], replace.B, replace.C, replace.B, fe, replace.A)
			elseif m[a] ==? "VISUAL" || m[a] ==? "V-LINE" || m[a] ==? "V-BLOCK" || m[a] ==? "SELECT" || m[a] ==? "S-LINE" || m[a] ==? "S-BLOCK"
				&l:statusline = printf(statuslineStr, visual.A, m[a], visual.B, visual.C, visual.B, fe, visual.A)
			elseif m[a] ==? "COMMAND"
				&l:statusline = printf(statuslineStr, command.A, m[a], command.B, command.C, command.B, fe, command.A)
			else
				# Normal & Other modes
				&l:statusline = printf(statuslineStr, normal.A, m[a], normal.B, normal.C, normal.B, fe, normal.A)
			endif
		else
			var inactiveSL = printf("%%<%s %%f %%m%%r%%=%%y ", inactive.A)
			setwinvar(win.winid, '&statusline', inactiveSL)
		endif
	endfor
enddef

augroup MyStatusLineGroup
	autocmd!
	au VimEnter * ++once MyStatusLine()
	au WinEnter,BufEnter,Modechanged * MyStatusLine()
augroup END



