--- 全局 color 设置
--- NOTE ------------------------------------------------------------------------------------------- {{{
--- 注意: 自定义 color 放在最后，用来 override 之前插件定义的颜色.
---   ':hi'                查看所有 color scheme
---   'ctermfg, ctermbg'   表示 color terminal (256 色)
---   'termfg, termbg'     表示 16 色 terminal
---   'term, cterm'        表示样式, underline, bold, italic ...
---
--- NOTE: 只有 ':hi[!] link' 才有 [!] 设置.
--- 如果是 ':hi <group>' 只会覆盖对应的 kv 颜色值.
--- eg: 'hi Foo cterm=bold ctermfg=201 ctermbg=233'
---     'hi Foo ctermfg=191'
---     最终结果为 'hi Foo cterm=bold ctermfg=191 ctermbg=233'
---
--- 颜色设置 cmd
---   ':hi <group> ctermfg...'           Set color
---   ':hi clear <group>'                Reset to default color. 如果没有 default color, 则结果为 {group} xxx cleared
---   ':hi! link <group> NONE'           VVI: 将颜色设为 NONE. 直接忽略 default color, 将颜色设置为 {group} xxx cleared
---   ':hi link <group1> <group2>'       将 <group1> 的颜色设置为 <group2> 的颜色.
---                                      如果 <group2> 颜色变化, <group1> 颜色也会随之变化.
---   ':hi! link <group1> <group2>'      相当于 ':hi clear <group>' && ':hi link <group1> <group2>'
---   ':hi default link <group1> <group2>'    将 <group1> default 颜色设置为 <group2> 的颜色.
---   ':hi! default link <group1> <group2>'   相当于 ':hi clear <group>' && ':hi default link <group1> <group2>'
---
--- NOTE: lua 设置颜色: `:help nvim_set_hl()`, nvim v0.7+
--- vim.api.nvim_set_hl(namespace, hl_group_name, {val})
---   namespace = 0 表示全局设置.
---   {val} 中 nocombine: boolean
---   {val} 中使用 cterm = {bold=true, underline=true, ...}, 也可以不使用 cterm.
---
--- eg:
---   vim.api.nvim_set_hl(0, "Foo", {ctermfg=123, ctermbg=234, cterm={bold=true, nocombine=true}})
---   vim.api.nvim_set_hl(0, "Foo", {link="Normal"})
---   vim.api.nvim_set_hl(0, 'Visual', {})  NOTE: clear the highlight group.
---
---   nvim_create_namespace({name}), namespace are used for buffer highlights.
---   nvim_buf_add_highlight(), 有点类似 matchaddpos() 但是不是完全一样.
---
--- VVI: nvim_set_hl() 没有实现 `hi! default link Foo Bar` 和 `hi clear Foo` 功能.
---
-- -- }}}

Color = {
  --- NOTE: alacritty 颜色对应, 表示 0-15 系统颜色.
  black = 233,  -- black background
  red   = 167,  -- error message
  green  = 42,   -- markdown title
  yellow = 191,  -- Search, lualine: Insert Mode background && tabline: tab seleced background
  blue  = 75,    -- info message
  magenta = 213, -- IncSearch, return, if, else, break, package, import
  cyan  = 81,   -- VVI: one of vim's main color. SpecialChar, Underlined, Label ...
  white = 251,  -- foreground, text

  --- 常用颜色,
  purple        = 170,  -- 170|68, keyword, eg: func, type, struct, var, const ... vscode keyword = 68
  func_gold     = 78,   -- 78|85, func, function_call, method, method_call ... | bufferline, lualine
  string_orange = 173,  -- string
  boolean_blue  = 74,   -- Special, boolean
  comment_green = 65,   -- 65|71, comments
  type_green    = 79,   -- type, 数据类型

  --- message 颜色
  hint_grey = 244,  -- hint message
  orange = 214,  -- warning message

  --- 其他颜色
  dark_orange = 202,  -- trailing_whitespace & mixed_indent, nvim-notify warn message border
  dark_red    = 52,   -- 256 color 中最深的红色, 接近黑色. 通常用于 bg.
  bracket_yellow = 220,  -- 匹配括号 () 颜色.
}

Colors = {
  --- NOTE: alacritty 颜色对应, 表示 0-15 系统颜色.
  black = {c=233, g='#121212'},  -- black background
  red   = {c=167, g='#f04c4c'},  -- error message
  green = {c=42,  g='#00d787'},   -- markdown title
  yellow = {c=191, g='#d7ff5f'},  -- Search, lualine: Insert Mode background && tabline: tab seleced background
  blue  = {c=75, g='#75beff'},    -- info message
  magenta = {c=213, g='#ff87ff'}, -- IncSearch, return, if, else, break, package, import
  cyan  = {c=81, g='#9cdcfe'},   -- VVI: one of vim's main color. SpecialChar, Underlined, Label ...
  white = {c=251, g='#c6c6c6'},  -- foreground, text

  --- 常用颜色,
  purple        = {c=170, g='#d75fd7'},  -- 170|68, keyword, eg: func, type, struct, var, const ... vscode keyword = 68
  func_gold     = {c=78, g='#dcdcaa'},   -- 78|85, func, function_call, method, method_call ... | bufferline, lualine
  string_orange = {c=173, g='#ce9178'},  -- string
  boolean_blue  = {c=74, g='#569cd6'},   -- Special, boolean
  comment_green = {c=65, g='#6a9956'},   -- 65|71, comments
  type_green    = {c=79, g='#00b691'},   -- type, 数据类型

  --- message 颜色
  hint_grey = {c=244, g='#808080'},  -- hint message
  orange = {c=214, g='#ff6f00'},  -- warning message

  --- 其他颜色
  dark_orange = {c=202, g='#ff6f00'},  -- trailing_whitespace & mixed_indent, nvim-notify warn message border
  dark_red    = {c=52, g='#890000'},   -- 256 color 中最深的红色, 接近黑色. 通常用于 bg.
  bracket_yellow = {c=220, g='#ffd800'},  -- 匹配括号 () 颜色.
}

Color_gui = {
  black = '#121212',
  red   = '#f04c4c',   -- error message
  green  = '#00d787',  -- markdown title
  yellow = '#d7ff5f',  -- Search, lualine: Insert Mode background && tabline: tab seleced background
  blue  = '#75beff',   -- info message
  magenta = '#ff87ff', -- IncSearch, return, if, else, break, package, import
  cyan  = '#9cdcfe',   -- VVI: one of vim's main color. SpecialChar, Underlined, Label ...
  white = '#c6c6c6',   -- foreground, text

  --- 常用颜色,
  purple        = '#d75fd7', -- 170|68, keyword, eg: func, type, struct, var, const ... vscode keyword = 68
  func_gold     = '#dcdcaa', -- 78|85, func, function_call, method, method_call ... | bufferline, lualine
  string_orange = '#ce9178', -- string
  boolean_blue  = '#569cd6', -- Special, boolean
  comment_green = '#6a9956', -- 65|71, comments
  type_green    = '#00b691', -- type, 数据类型

  --- message 颜色
  hint_grey = '#808080',  -- hint message
  orange = '#ff6f00',  -- warning message

  --- 其他颜色
  --- TODO: merge orange and dark_orange
  dark_orange = '#ff6f00',  -- trailing_whitespace & mixed_indent, nvim-notify warn message border
  dark_red    = '#890000',  -- 256 color 中最深的红色, 接近黑色. 通常用于 bg.
  bracket_yellow = '#ffd800',  -- 匹配括号 () 颜色.
}

--- highlight api 设置: vim.api.nvim_set_hl(0, '@property', { ctermfg = 81 })
Highlights = {
  --- editor ---------------------------------------------------------------------------------------
  --- window background color
  Normal = {ctermfg=Colors.white.c, fg=Colors.white.g},
  --- non-focus window background color
  NormalNC = {link="Normal"},
  --- Visual mode seleced text color
  Visual = {ctermbg=24, bg='#264f78'},

  --- VVI: Pmenu & FloatBorder 背景色需要设置为相同, 影响很多窗口的颜色.
  --- Completion Menu & Floating Window 颜色
  Pmenu = {
    ctermfg=Colors.white.c, fg=Colors.white.g,
    ctermbg=Colors.black.c, bg=Colors.black.g,
  },
  --- Completion Menu 选中项颜色
  PmenuSel = {
    ctermbg=238, bg='#03395e',
    bold=true, underline=true,
  },
  --- Completion Menu scroll bar 背景色
  PmenuSbar = {ctermbg=Colors.black.c, bg=Colors.black.g},
  --- Completion Menu scroll bar 滚动条颜色
  PmenuThumb = {ctermbg=240, bg='#585858'},
  --- NormalFloat 默认 link to Pmenu
  NormalFloat = {link="Pmenu"},
  --- Floating Window border 颜色需要和 Pmenu 的背景色相同. border = {"▄","▄","▄","█","▀","▀","▀","█"}
  FloatBorder = {ctermfg=Colors.black.c, fg=Colors.black.g},

  --- 注释颜色
  Comment = {ctermfg=Colors.comment_green.c, fg=Colors.comment_green.g},
  --- 影响 listchars indentLine 颜色
  NonText = {ctermfg=238, fg='#444444'},
  --- window 之间的分隔线颜色
  VertSplit = {ctermfg=236, fg='#303030'},
  --- 括号匹配颜色
  MatchParen = {
    ctermfg=Color.bracket_yellow, fg=Color_gui.bracket_yellow,
    bold=true, underline=true,
  },
  --- url, filepath 样式
  Underlined = {underline=true},

  --- 行号颜色
  LineNr = {ctermfg=240, fg='#585858'},
  --- 光标所在行颜色
  CursorLine = {ctermbg=236, bg='#303030'},
  --- 光标所在行号的颜色
  CursorLineNr = {
    ctermfg=Colors.yellow.c, fg=Colors.yellow.g,
    bold=true,
  },
  --- 相当于 hi clear SignColumn, 默认有 bg 颜色.
  SignColumn = {},
  --- textwidth column 颜色
  ColorColumn = {ctermbg=235, bg='#252525'},
  --- Quick Fix 选中行颜色
  QuickFixLine = {
    ctermfg=Colors.boolean_blue.c, fg=Colors.boolean_blue.g,
    bold=true,
  },

  --- / ? 搜索颜色
  IncSearch = {
    ctermfg=Colors.black.c,   fg=Colors.black.g,
    ctermbg=Colors.magenta.c, bg=Colors.magenta.g,
    bold=true,
  },
  --- / ? * # g* g# 搜索颜色
  Search = {
    ctermfg=Colors.black.c,  fg=Colors.black.g,
    ctermbg=Colors.yellow.c, bg=Colors.yellow.g,
  },

  --- echoerr 颜色
  ErrorMsg = {
    ctermfg=255, fg='#ffffff',
    ctermbg=Colors.red.c, bg=Colors.red.g,
  },
  --- echohl WarningMsg | echo "Don't panic!" | echohl None 颜色
  WarningMsg = {
    ctermfg=Colors.black.c,  fg=Colors.black.g,
    ctermbg=Color.orange, bg=Color_gui.orange,
  },

  --- TODO 颜色
  Todo = {
    ctermfg=255, fg='#ffffff',
    ctermbg=22, bg='#008F00',
  },
  --- NOTE 颜色
  SpecialComment = {
    ctermfg=255, fg='#ffffff',
    ctermbg=63,  bg='#5f5fff',
  },

  --- command 模式自动补全
  WildMenu = {
    ctermfg=Colors.black.c, fg=Colors.black.g,
    ctermbg=Colors.blue.c,  bg=Colors.blue.g,
    bold=true,
  },
  --- for bufferline 在 nvim-tree 显示 "File Explorer"
  Directory = {
    ctermfg=Colors.cyan.c, fg=Colors.cyan.g,
    ctermbg=235, bg='#252525',
    bold=true, underline=true,
  },

  --- 基础颜色 -------------------------------------------------------------------------------------
  --- VVI: 最主要的颜色
  Keyword = {ctermfg=Colors.purple.c, fg=Colors.purple.g},
  --- func <Function> {}, 定义 & call func 都使用该颜色
  Function = {ctermfg=Colors.func_gold.c, fg=Colors.func_gold.g},
  --- type <Type> struct
  Type = {
    ctermfg=Colors.type_green.c, fg=Colors.type_green.g,
    italic=true,
  },
  --- property & parameter
  Identifier = {link = "Normal"},
  --- 常量颜色. eg: const <Constant> = 100
  Constant= {ctermfg=Colors.blue.c, fg=Colors.blue.g},
  --Structure = {link = "Type"},  -- 默认 link to Type

  --- if, switch, case ...
  Conditional = {ctermfg=Colors.magenta.c, fg=Colors.magenta.g},
  Repeat    = {link = "Conditional"}, -- for range
  Statement = {link = "Conditional"}, -- syntax 中 'package' & 'import' 关键字
  Include   = {link = "Conditional"}, -- treesitter 中 'package', 'import', 'from' ... 关键字

  String = {ctermfg=Colors.string_orange.c, fg=Colors.string_orange.g},
  Character = {link = "String"},

  Number = {ctermfg=151, fg='#b5cea8'}, -- 100, int, uint ...
  Float  = {link = "Number"}, -- 10.02 float64, float32

  --- true / false
  Boolean = {ctermfg = Colors.boolean_blue.c, fg = Colors.boolean_blue.g},
  Special = {link = "Boolean"},  -- console.log(`${ ... }`)

  --- format verbs %v %d ...
  SpecialChar = {ctermfg=Colors.cyan.c, fg=Colors.cyan.g},
  --- tsxTSVariableBuiltin, tsxTSConstBuiltin ...
  PreProc = {ctermfg=Colors.boolean_blue.c, fg=Colors.boolean_blue.g},

  Delimiter = {link = "Normal"},  -- 符号颜色, [] () {} ; : ...
  Operator  = {link = "Normal"},  -- = != == > < ...

  --- diagnostics 颜色设置 -------------------------------------------------------------------------
  --- NOTE:
  --- DiagnosticXXX 主要设置.
  --- DiagnosticFloatingXXX - floating window 中显示 error message 的颜色.
  --- DiagnosticSignXXX     - SignColumn 中显示的颜色.
  --- DiagnosticVirtualText - virtual_text 显示的颜色.
  --- DiagnosticUnderlineXXX - code 中显示错误的位置.
  --- 以上 highlight 默认 link to DiagnosticXXX.
  DiagnosticHint  = {ctermfg=Color.hint_grey, fg=Color_gui.hint_grey},
  DiagnosticInfo  = {ctermfg=Colors.blue.c, fg=Colors.blue.g},
  DiagnosticWarn  = {ctermfg=Color.orange, fg=Color_gui.orange},
  DiagnosticError = {ctermfg=Colors.red.c, fg=Colors.red.g},

  --- NOTE: `:help undercurl` sp(guisp) color 改变 undercurl, underline, underdashed ... 颜色.
  DiagnosticUnderlineHint = {
    ctermfg=Color.hint_grey, fg=Color_gui.hint_grey,
    sp=Color_gui.hint_grey, undercurl=true,
  },
  DiagnosticUnderlineInfo = {
    ctermfg=Colors.blue.c, fg=Colors.blue.g,
    sp=Colors.blue.g, undercurl=true,
  },
  DiagnosticUnderlineWarn = {
    ctermfg=Color.orange, fg=Color_gui.orange,
    sp=Color_gui.orange, undercurl=true,
  },
  DiagnosticUnderlineError = {
    ctermfg=Colors.red.c, fg=Colors.red.g,
    sp=Colors.red.g, undercurl=true, bold=true,
  },

  DiagnosticUnnecessary = {link = "DiagnosticUnderlineHint"},
  DiagnosticDeprecated = {link = "DiagnosticUnderlineHint"},

  --- LSP 相关颜色 ---------------------------------------------------------------------------------
  --- vim.lsp.buf.document_highlight() 颜色, 类似 Same_ID
  LspReferenceText  = {ctermbg=238, bg='#444444'},
  LspReferenceRead  = {link = 'LspReferenceText'},
  LspReferenceWrite = {link = 'LspReferenceText'},

  --- diff 颜色 ------------------------------------------------------------------------------------
  DiffAdd = {
    ctermfg=Colors.black.c,
    ctermbg=Colors.green.c, bg='#4c5b2d',
  },
  DiffDelete = {
    ctermfg=Colors.white.c,
    ctermbg=Color.dark_red, bg='#4e201e'
  },
  DiffChange = {},  -- 有修改的一整行的文字的颜色
  --- changed text
  DiffText = {
    ctermfg=Colors.black.c, fg=Colors.black.g,
    ctermbg=Colors.magenta.c, bg=Colors.magenta.g,
  },

  --- fold 颜色 ------------------------------------------------------------------------------------
  --- diff mode 下, 会自动设置:
  --- `set foldcolumn=2`, 在 foldcolumn 显示在 SignColumn 前面.
  --- `set foldmethod=diff`
  Folded = {ctermfg=67, fg='#5f87af'}, -- 折叠行文字颜色
  FoldColumn = {ctermfg=Colors.green.c, fg=Colors.green.g}, -- foldcolumn 中 + - | 的颜色
  CursorLineFold = {link = "FoldColumn"},  -- cursor 所在行 foldcolumn 中 + - | 号颜色

  --- 其他常用颜色 ---------------------------------------------------------------------------------
  --- markdown title
  Title = {
    ctermfg=Colors.green.c, fg=Colors.green.g,
    bold=true,
  },
  --- `set conceallevel?`, markdown list, code block ...
  Conceal = {ctermfg=246, fg='#949494'},
  --- json: key color; markdown: code block language(```go)
  Label = {ctermfg=Colors.cyan.c, fg=Colors.cyan.g},

  SpellBad = {
    ctermfg=Colors.red.c, fg=Colors.red.g,
    ctermbg=Color.dark_red, bg=Color_gui.dark_red,
    bold=true, underline=true,
  },
  SpellCap = {
    ctermfg=Color.orange, fg=Color_gui.orange,
    ctermbg=Color.dark_red, bg=Color_gui.dark_red,
    bold=true, underline=true,
  },
  SpellLocal = {},  -- clear highlight

  --- NOTE: treesitter 颜色设置 --------------------------------------------------------------------
  --- comment
  ['@comment.error'] = {link = 'ErrorMsg'},  -- FIXME, BUG, ERROR
  ['@comment.warning'] = { link = "WarningMsg" },  -- HACK, WARN, WARNING, VVI, FIX
  ['@comment.note'] = { link = "SpecialComment" }, -- XXX, NOTE, DOCS, TEST, INFO
  ['@comment.todo'] = { link = "Todo" },           -- TODO
  ['@punctuation.delimiter.comment'] = { link = "Comment" },
  ['@string.special.url.comment'] = { link = "Underlined" }, -- VVI: 这里的 comment 设置是 utils/keymaps function 中需要用到的, 不要删除.

  --- url
  ['@string.special.url'] = { link = "Underlined" },  -- url
  ['@string.special.url.html'] = { link = "String" },  -- html, <href="@text.uri">
  ['@string.special.url.jsx']  = { link = "String" },  -- html, <href="@text.uri">
  ['@string.special.url.tsx']  = { link = "String" },  -- html, <href="@text.uri">

  --- markdown / markdown_inline
  ['@markup.heading'] = { link = "Title" }, -- markdown, # title
  ['@markup.strong'] = { bold = true }, -- markdown, **bold**
  ['@markup.italic'] = { italic = true },  -- markdown, *italic*, _italic_
  ['@markup.underline'] = { underline = true },  -- markdown, <u>underline</u>
  ['@markup.strikethrough'] = { strikethrough = true },  -- markdown, ~~strike~~
  ['@markup.link.label'] = { ctermfg=Colors.cyan.c, fg=Colors.cyan.g }, -- markdown, [@markup.link.label](@markup.link.url)
  ['@markup.link.url'] = { ctermfg=Colors.cyan.c, fg=Colors.cyan.g },   -- markdown, [@markup.link.label](@markup.link.url)
  --- markdown, inline `code`
  ['@markup.raw.markdown_inline'] = {
    ctermfg=Colors.string_orange.c, fg=Colors.string_orange.g,
    ctermbg = 236, bg='#303030',
  },

  --- program language
  ['@string.escape'] = {ctermfg=180, fg='#ceb279'},  -- \n \t ...
  ['@module'] = { ctermfg=Colors.type_green.c, fg=Colors.type_green.g },  -- package <module>

  --['@constant'] = { link = "Constant" },
  ['@variable'] = { link = "Normal" },
  ['@constant.builtin'] = { ctermfg=Colors.boolean_blue.c, fg=Colors.boolean_blue.g },  -- typescript 关键字 'null' ...
  ['@variable.builtin'] = { ctermfg=Colors.boolean_blue.c, fg=Colors.boolean_blue.g },  -- typescript 关键字 'undefined', 'this', 'console' ...

  ['@property'] = { ctermfg = Colors.cyan.c, fg=Colors.cyan.g },
  ['@property.private'] = { ctermfg=246, fg='#949494' },  -- struct{ a:1 }
  ['@variable.member'] = { link = "@property" },
  ['@field'] = { link = "@property" },
  ['@parameter'] = { link = "@property" },

  --['@function'] = { link = "Function" },
  --['@function.call'] = { link = "Function" },
  --['@method'] = { link = "Function" },
  --['@method.call'] = { link = "Function" },
  ['@function.builtin'] = { link = "Function" },
  ['@function.type'] = { link = "Type" },

  ['@keyword.return'] = { link = "Conditional" }, -- [return] nil
  ['@namespace'] = { link = "Normal" },  -- package [@namespace]

  ['@tag'] = { ctermfg=68, fg='#5396cc' },  -- html, <@tag></@tag>
  ['@tag.delimiter'] = { ctermfg=244, fg='#808080' },  -- html, <div></div>, <> 括号颜色
  ['@tag.attribute'] = { link = "@property" },  -- html, <... width=..., @tag.attribute=... >
  ['@punctuation.special'] = { link = 'Special' },  -- js, ts, console.log(`${ ... }`)

  --- NOTE: 以下设置是为了配合 lazy load plugins ---------------------------------------------------
  --- 以下颜色为了 lazy load lualine
  --- 无法使用 lualine 的情况下 StatusLine 颜色, eg: tagbar 有自己设置的 ':set statusline?' 颜色不受 lualine 控制.
  --- active
  StatusLine = {
    ctermfg=Colors.func_gold.c, fg=Colors.func_gold.g,
    ctermbg=Colors.black.c, bg=Colors.black.g,
  },
  --- inactive, NC (not-current windows)
  StatusLineNC = {
    ctermfg=246, fg='#949494',
    ctermbg=Colors.black.c, bg=Colors.black.g,
  },

  --- 以下颜色为了 lazy load bufferline
  TabLineFill = {}, -- NOTE: clear TabLineFill
  TabLineSel = {
    ctermfg=Colors.func_gold.c, fg=Colors.func_gold.g,
    ctermbg=Colors.black.c, bg=Colors.black.g,
    bold=true,
  },
  --TabLine = {ctermfg = 234},

  --- 设置 syntax 颜色是为了让 treesitter lazy render 的时候不至于颜色差距太大.
  --- set vim-syntax color to match treesitter color
  typescriptMember = {link = '@property'},
  typescriptInterfaceName = {link = 'Type'},
  typescriptExport = {link = 'Keyword'},
  typescriptImport = {link = 'Conditional'},
}

--- nvim_set_hl()
for hl_group, hl_val in pairs(Highlights) do
  vim.api.nvim_set_hl(0, hl_group, hl_val)
end



