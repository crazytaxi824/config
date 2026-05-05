vim9script

# CursorLine
hi clear CursorLine
hi CursorLine ctermbg=236 guibg=#303030

# Visual selected
hi clear Visual
hi Visual ctermbg=24 guibg=#264F78

# split window
hi clear VertSplit
hi VertSplit ctermfg=240 guifg=#585858

# 括号 {} [] ()
hi clear MatchParen
hi MatchParen ctermfg=220 guifg=#FFD800 cterm=underline,bold gui=underline,bold

# listchars, indent_line
hi NonText ctermfg=238 guifg=#444444
hi! link SpecialKey NonText

# Search
hi Search ctermfg=233 ctermbg=220 guifg=#121212 guibg=#FFD800
hi IncSearch ctermfg=233 ctermbg=213 guifg=#121212 guibg=#FF87FF cterm=bold gui=bold
hi! link CurSearch IncSearch

# fold
hi clear Folded
hi Folded ctermfg=67 guifg=#5F87AF

# 行号 set number
hi LineNr ctermfg=240 guifg=#585858
hi CursorLine ctermbg=236 guibg=#303030
hi CursorLineNr ctermfg=220 guifg=#FFD800 cterm=bold gui=bold
hi ColorColumn ctermbg=234 guibg=#1C1C1C

# msg
hi ErrorMsg ctermfg=255 ctermbg=167 guifg=#FFFFFF guibg=#F85249
hi WarningMsg ctermfg=208 guifg=#CCA700

# popup menu
hi Pmenu ctermfg=251 ctermbg=235 guifg=#C0C0C0 guibg=#262626
hi PmenuSel ctermfg=74 ctermbg=238 guifg=#569CD6 guibg=#444444 cterm=bold,underline gui=bold,underline
hi PmenuSbar ctermbg=235 guibg=#262626
hi PmenuThumb ctermbg=240 guibg=#585858
hi PmenuMatch ctermfg=213 ctermbg=235 guifg=#FF87FF guibg=#262626
hi PmenuMatchSel ctermfg=213 ctermbg=238 guifg=#FF87FF guibg=#444444 cterm=bold,underline gui=bold,underline

# spell
hi clear SpellBad
hi SpellBad ctermfg=208 guifg=#CCA700 cterm=bold,strikethrough gui=bold,strikethrough
hi! link SpellCap SpellBad
hi! link SpellRare SpellBad
hi! link SpellLocal SpellBad

# Diff mode
hi DiffAdd ctermfg=251 ctermbg=42 guifg=#C0C0C0 guibg=#4C5B2D
hi DiffText ctermfg=233 ctermbg=213 guifg=#121212 guibg=#FF87FF
hi clear DiffChange
hi DiffDelete ctermfg=251 ctermbg=52 guifg=#C0C0C0 guibg=#66201D

# others
hi Todo ctermfg=255 ctermbg=22 guifg=#FFFFFF guibg=#008F00
hi SpecialComment ctermfg=255 ctermbg=63 guifg=#FFFFFF guibg=#5F5FFF
hi Directory ctermfg=81 guifg=#9CDCFE cterm=bold gui=bold

# code
hi Keyword ctermfg=74 guifg=#569CD6
hi Function ctermfg=78 guifg=#DCDCAA
hi Type ctermfg=79 guifg=#4EC9B0
hi! link Identifier Normal
hi Constant ctermfg=75 guifg=#4FC1FF

hi Conditional ctermfg=213 guifg=#FF87FF
hi! link Statement Conditional
hi! link Include Conditional

hi String ctermfg=173 guifg=#CE9178
hi! link Character String

hi Number ctermfg=151 guifg=#B5CEA8
hi! link Float Number

hi Boolean ctermfg=74 guifg=#569CD6
hi! link Special Boolean
hi! link PreProc Boolean

hi Comment ctermfg=65 guifg=#6A9955


## NOTE: 使用以下函数加载速度会变慢.
## NOTE: 必须先加载 colorscheme, 否则以下 highlight 设置可能无效.
#var colors = {
#	white:   { c: '251', g: '#C0C0C0' },
#	black:   { c: '233', g: '#121212' },
#	red:     { c: '167', g: '#F85249' },
#	yellow:  { c: '220', g: '#FFD800' },
#	orange:  { c: '208', g: '#CCA700' },
#	magenta: { c: '213', g: '#FF87FF' },
#	cyan:    { c: '81',  g: '#9CDCFE' },
#	gold:    { c: '78',  g: '#DCDCAA' },
#
#	blue:         { c: '75', g: '#4FC1FF' },
#	blue_boolean: { c: '74', g: '#569CD6' },
#	blue_special: { c: '63', g: '#5F5FFF' },
#
#	green_type:    { c: '79',  g: '#4EC9B0' },
#	green_comment: { c: '65',  g: '#6A9955' },
#
#	g234: { c: '234', g: '#1C1C1C' },
#	g235: { c: '235', g: '#262626' },
#	g236: { c: '236', g: '#303030' },
#	g237: { c: '237', g: '#3A3A3A' },
#	g238: { c: '238', g: '#444444' },
#	g239: { c: '239', g: '#4E4E4E' },
#	g240: { c: '240', g: '#585858' },
#	g241: { c: '241', g: '#626262' },
#	g242: { c: '242', g: '#6C6C6C' },
#	g243: { c: '243', g: '#767676' },
#	g244: { c: '244', g: '#808080' },
#	g245: { c: '245', g: '#8A8A8A' },
#	g246: { c: '246', g: '#949494' },
#}
#
## 同时设置 cterm & gui highlights
#def GenHighlights(name: string, opts: dict<any>, clear: bool = false): list<dict<any>>
#	var fg: dict<string> = opts->get('fg', {})
#	var bg: dict<string> = opts->get('bg', {})
#	var term: list<string> = opts->get('term', [])
#
#	var hls: list<dict<any>> = []
#	var hl: dict<any> = { name: name }
#	if !empty(fg)
#		hl.ctermfg = fg.c
#		hl.guifg = fg.g
#	endif
#
#	if !empty(bg)
#		hl.ctermbg = bg.c
#		hl.guibg = bg.g
#	endif
#
#	if !empty(term)
#		hl.cterm = {}
#		hl.gui = {}
#		for t in term
#			hl.cterm[t] = true
#			hl.gui[t] = true
#		endfor
#	endif
#
#	if clear
#		hls->add({ name: name, cleared: true })
#	endif
#	hls->add(hl)
#
#	return hls
#enddef
#
## 设置 link highlight
#def LinkHighlight(name: string, link: string): dict<any>
#	return { name: name, linksto: link, cleared: true }
#enddef
#
## 设置 highlights
#var highlights: list<dict<any>> = []
#highlights->extend(GenHighlights('CursorLine', { bg: colors.g236 }, true))
#highlights->extend(GenHighlights('Visual', { bg: { c: '24', g: '#264F78' }}, true))
#highlights->extend(GenHighlights('VertSplit', { fg: colors.g240 }, true))
#highlights->extend(GenHighlights('MatchParen', { fg: colors.yellow, term: ['underline', 'bold']}, true))
#highlights->extend(GenHighlights('NonText', { fg: colors.g238 }))
#highlights->add(LinkHighlight('SpecialKey', 'NonText'))
#highlights->extend(GenHighlights('Search', { fg: colors.black, bg: colors.yellow }))
#highlights->extend(GenHighlights('IncSearch', { fg: colors.black, bg: colors.magenta, term: ['bold']}))
#highlights->add(LinkHighlight('CurSearch', 'IncSearch'))
#
#highlights->extend(GenHighlights('Folded', { fg: { c: '67', g: '#5F87AF' }}, true))
#highlights->extend(GenHighlights('Comment', { fg: colors.green_comment }))
#
#highlights->extend(GenHighlights('LineNr', { fg: colors.g240 }))
#highlights->extend(GenHighlights('CursorLineNr', { fg: colors.yellow, term: ['bold']}))
#highlights->extend(GenHighlights('CursorLine', { bg: colors.g236 }))
#highlights->extend(GenHighlights('ColorColumn', { bg: colors.g234 }))
#
#highlights->extend(GenHighlights('ErrorMsg', { fg: { c: '255', g: '#FFFFFF' }, bg: colors.red }))
#highlights->extend(GenHighlights('WarningMsg', { fg: colors.orange }))
#
#highlights->extend(GenHighlights('Pmenu', { fg: colors.white, bg: colors.g235 }))
#highlights->extend(GenHighlights('PmenuSel', { fg: colors.blue_boolean, bg: colors.g238, term: ['underline', 'bold']}))
#highlights->extend(GenHighlights('PmenuSbar', { bg: colors.g235 }))
#highlights->extend(GenHighlights('PmenuThumb', { bg: colors.g240 }))
#highlights->extend(GenHighlights('PmenuMatch', { fg: colors.magenta, bg: colors.g235 }))
#highlights->extend(GenHighlights('PmenuMatchSel', { fg: colors.magenta, bg: colors.g238, term: ['underline', 'bold']}))
#
#highlights->extend(GenHighlights('SpellBad', { fg: colors.orange, term: ['strikethrough', 'bold', 'italic'] }, true))
#highlights->add(LinkHighlight('SpellCap', 'SpellBad'))
#highlights->add(LinkHighlight('SpellRare', 'SpellBad'))
#highlights->add(LinkHighlight('SpellLocal', 'SpellBad'))
#
#highlights->extend(GenHighlights('DiffAdd', { fg: colors.white, bg: { c: '42', g: '#4C5B2D' }}))
#highlights->extend(GenHighlights('DiffDelete', { fg: colors.white, bg: { c: '52', g: '#66201D' }}))
#highlights->extend(GenHighlights('DiffText', { fg: colors.black, bg: colors.magenta }))
#highlights->add(LinkHighlight('DiffChange', 'NONE'))
#
#highlights->extend(GenHighlights('Todo', { fg: { c: '255', g: '#FFFFFF' }, bg: { c: '22', g: '#008F00' } }))
#highlights->extend(GenHighlights('SpecialComment', { fg: { c: '255', g: '#FFFFFF' }, bg: colors.blue_special }))
#highlights->extend(GenHighlights('Directory', { fg: colors.cyan, term: ["bold"] }))
#
#highlights->extend(GenHighlights('Keyword', { fg: colors.blue_boolean }))
#highlights->extend(GenHighlights('Function', { fg: colors.gold }))
#highlights->extend(GenHighlights('Type', { fg: colors.green_type }))
#highlights->extend(GenHighlights('Constant', { fg: colors.blue }))
#highlights->add(LinkHighlight('Identifier', 'Normal'))
#
#highlights->extend(GenHighlights('Conditional', { fg: colors.magenta }))
#highlights->add(LinkHighlight('Statement', 'Conditional'))
#highlights->add(LinkHighlight('Include', 'Conditional'))
#
#highlights->extend(GenHighlights('String', { fg: { c: '173', g: '#CE9178' }}))
#highlights->add(LinkHighlight('Character', 'String'))
#
#highlights->extend(GenHighlights('Number', { fg: { c: '151', g: '#B5CEA8' }}))
#highlights->add(LinkHighlight('Float', 'Number'))
#
#highlights->extend(GenHighlights('Boolean', { fg: colors.blue_boolean }))
#highlights->add(LinkHighlight('Special', 'Boolean'))
#highlights->add(LinkHighlight('PreProc', 'Boolean'))
#
## 调用 vim9 函数
#hlset(highlights)



