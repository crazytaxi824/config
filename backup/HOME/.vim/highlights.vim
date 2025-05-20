""" this is not a vim9script

""" NOTE: 必须先加载 colorscheme, 否则以下 highlight 设置可能无效.

""" CursorLine
hi clear CursorLine
hi CursorLine ctermbg=236

""" Visual selected
hi clear Visual
hi Visual ctermbg=24

""" split window
hi clear VertSplit
hi VertSplit ctermfg=236

""" 括号 {} [] ()
hi clear MatchParen
hi MatchParen cterm=underline,bold ctermfg=220

""" listchars
hi NonText ctermfg=238
hi! link SpecialKey NonText

""" Search
hi Search ctermfg=233 ctermbg=220
hi IncSearch cterm=bold ctermfg=233 ctermbg=213
hi! link CurSearch IncSearch

""" fold
hi clear Folded
hi Folded ctermfg=67

""" 行号 set number
hi LineNr ctermfg=240
hi CursorLine ctermbg=236
hi CursorLineNr ctermfg=220 cterm=bold

""" msg
hi ErrorMsg ctermfg=255 ctermbg=167
hi WarningMsg ctermfg=208

""" menu
hi Pmenu ctermfg=251 ctermbg=235
hi PmenuSel ctermfg=74 ctermbg=238 cterm=bold,underline
hi PmenuSbar ctermbg=233
hi PmenuThumb ctermbg=240

""" Diff mode
hi DiffAdd ctermfg=251 ctermbg=22
hi DiffText ctermfg=213 ctermbg=233 cterm=reverse
hi clear DiffChange
hi DiffDelete ctermfg=251 ctermbg=52

"""
hi Todo ctermfg=22 ctermbg=255 cterm=reverse
hi SpecialComment ctermfg=63 ctermbg=255 cterm=reverse
hi Directory cterm=bold ctermfg=81

""" code
hi Keyword ctermfg=74
hi Function ctermfg=78
hi Type ctermfg=79
hi! link Identifier Normal
hi Constant ctermfg=75

hi Conditional ctermfg=213
hi! link Statement Conditional
hi! link Include Conditional

hi String ctermfg=173
hi! link Character String

hi Number ctermfg=151
hi! link Float Number

hi Boolean ctermfg=74
hi! link Special Boolean
hi! link PreProc Boolean

hi Comment ctermfg=65



