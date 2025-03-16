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
-- -- }}}

--- VVI: alacritty color based on sRGB
Colors = {
  --- NOTE: alacritty 颜色对应, 表示 0-15 系统颜色.
  white = {c=251, g='#C0C0C0'},   -- foreground, text
  black = {c=233, g='#121212'},   -- black background
  red   = {c=167, g='#F04C4C'},   -- error message
  green = {c=42,  g='#00D787'},   -- markdown title
  yellow = {c=220, g='#FFD800'},  -- Search, lualine: Insert Mode background && tabline: tab seleced background
  blue  = {c=75, g='#4FC1FF'},    -- info message
  magenta = {c=213, g='#FF87FF'}, -- IncSearch, return, if, else, break, package, import
  cyan  = {c=81, g='#9CDCFE'},    -- VVI: one of vim's main color. SpecialChar, Underlined, Label ...
  orange = {c=208, g='#FF8700'},  -- warning message
  hint_grey = {c=244, g='#808080'},  -- hint message
  purple = {c=170, g='#D75FD7'},

  --- 常用颜色,
  blue_boolean  = {c=74, g='#569CD6'},   -- Boolean, Special
  gold_fn     = {c=78, g='#DCDCAA'},   -- 78|85, func, function_call, method, method_call ... | bufferline, lualine
  green_type    = {c=79, g='#4EC9B0'},   -- type, 数据类型

  --- dark color use for background
  red_bg = {c=52, g='#66201D'},  --- #4E201E, #72201D

  --- grayscale 颜色
  g234 = {c=234, g='#1C1C1C'},
  g235 = {c=235, g='#262626'},
  g236 = {c=236, g='#303030'},
  g237 = {c=237, g='#3A3A3A'},
  g238 = {c=238, g='#444444'},
  g239 = {c=239, g='#4E4E4E'},
  g240 = {c=240, g='#585858'},
  g241 = {c=241, g='#626262'},
  g242 = {c=242, g='#6C6C6C'},
  g243 = {c=243, g='#767676'},
  g244 = {c=244, g='#808080'},
  g245 = {c=245, g='#8A8A8A'},
  g246 = {c=246, g='#949494'},
}

--- highlight api 设置: vim.api.nvim_set_hl(0, '@property', { ctermfg = 81 })
Highlights = {
  --- editor ---------------------------------------------------------------------------------------
  --- window background color
  Normal = {ctermfg=Colors.white.c, fg=Colors.white.g},
  --- non-focus window background color
  NormalNC = {link="Normal"},
  --- Visual mode seleced text color
  Visual = {ctermbg=24, bg='#264F78'},

  --- VVI: Pmenu & FloatBorder 背景色需要设置为相同, 影响很多窗口的颜色.
  --- Completion Menu & Floating Window 颜色
  Pmenu = {
    ctermfg=Colors.white.c, fg=Colors.white.g,
    ctermbg=Colors.g235.c, bg=Colors.g235.g,
  },
  --- Completion Menu 选中项颜色
  PmenuSel = {
    ctermbg=Colors.g238.c, bg='#03395E',
    bold=true, underline=true,
  },
  --- Completion Menu scroll bar 背景色
  PmenuSbar = {ctermbg=Colors.black.c, bg=Colors.black.g},
  --- Completion Menu scroll bar 滚动条颜色
  PmenuThumb = {ctermbg=Colors.g240.c, bg=Colors.g240.g},
  --- NormalFloat 默认 link to Pmenu
  NormalFloat = {link="Pmenu"},
  --- Floating Window border 颜色需要和 Pmenu 的背景色相同. border = {"▄","▄","▄","█","▀","▀","▀","█"}
  FloatBorder = {ctermfg=Colors.g235.c, fg=Colors.g235.g},

  --- 注释颜色
  Comment = {ctermfg=65, fg='#6A9955'},
  --- 影响 listchars indentLine 颜色
  NonText = {ctermfg=Colors.g238.c, fg=Colors.g238.g},
  --- window 之间的分隔线颜色
  WinSeparator = {ctermfg=Colors.g236.c, fg=Colors.g236.g},
  VertSplit = {link = 'WinSeparator'},
  --- 括号匹配颜色
  MatchParen = {
    ctermfg=Colors.yellow.c, fg=Colors.yellow.g,
    bold=true, underline=true,
  },
  --- url, filepath 样式
  Underlined = {underline=true},

  --- 行号颜色
  LineNr = {ctermfg=Colors.g240.c, fg=Colors.g240.g},
  --- 光标所在行颜色
  CursorLine = {ctermbg=Colors.g236.c, bg=Colors.g236.g},
  --- 光标所在行号的颜色
  CursorLineNr = {
    ctermfg=Colors.yellow.c, fg=Colors.yellow.g,
    bold=true,
  },
  --- 相当于 hi clear SignColumn, 默认有 bg 颜色.
  SignColumn = {},
  --- textwidth column 颜色
  ColorColumn = {ctermbg=Colors.g234.c, bg=Colors.g234.g},
  --- Quick Fix 选中行颜色
  QuickFixLine = {
    ctermfg=Colors.blue_boolean.c, fg=Colors.blue_boolean.g,
    bold=true,
  },

  --- / ? 搜索颜色
  IncSearch = {
    ctermfg=Colors.black.c,   fg=Colors.black.g,
    ctermbg=Colors.magenta.c, bg=Colors.magenta.g,
    bold=true,
  },
  CurSearch = { link = "IncSearch" },
  --- / ? * # g* g# 搜索颜色
  Search = {
    ctermfg=Colors.black.c,  fg=Colors.black.g,
    ctermbg=Colors.yellow.c, bg=Colors.yellow.g,
  },

  --- echoerr 颜色
  ErrorMsg = {
    ctermfg=255, fg='#FFFFFF',
    ctermbg=Colors.red.c, bg=Colors.red.g,
  },
  --- echohl WarningMsg | echo "Don't panic!" | echohl None 颜色
  WarningMsg = {
    ctermfg=Colors.black.c,  fg=Colors.black.g,
    ctermbg=Colors.orange.c, bg=Colors.orange.g,
  },

  --- TODO 颜色
  Todo = {
    ctermfg=255, fg='#FFFFFF',
    ctermbg=22, bg='#008F00',
  },
  --- NOTE 颜色
  SpecialComment = {
    ctermfg=255, fg='#FFFFFF',
    ctermbg=63,  bg='#5F5FFF',
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
    bold=true,
  },

  --- 基础颜色 -------------------------------------------------------------------------------------
  --- VVI: 最主要的颜色
  Keyword = {ctermfg=Colors.blue_boolean.c, fg=Colors.blue_boolean.g},
  --- func <Function> {}, 定义 & call func 都使用该颜色
  Function = {ctermfg=Colors.gold_fn.c, fg=Colors.gold_fn.g},
  --- type <Type> struct
  Type = {ctermfg=Colors.green_type.c, fg=Colors.green_type.g},
  --- property & parameter
  Identifier = {link = "Normal"},
  --- 常量颜色. eg: const <Constant> = "foo"
  Constant= {ctermfg=Colors.blue.c, fg=Colors.blue.g},
  --Structure = {link = "Type"},  -- 默认 link to Type

  --- if, switch, case ...
  Conditional = {ctermfg=Colors.magenta.c, fg=Colors.magenta.g},
  Repeat    = {link = "Conditional"}, -- for range
  Statement = {link = "Conditional"}, -- syntax 中 'package' & 'import' 关键字
  Include   = {link = "Conditional"}, -- treesitter 中 'package', 'import', 'from' ... 关键字

  String = {ctermfg=173, fg='#CE9178'},
  Character = {link = "String"},

  Number = {ctermfg=151, fg='#B5CEA8'}, -- 100, int, uint ...
  Float  = {link = "Number"}, -- 10.02 float64, float32

  --- true / false
  Boolean = {ctermfg=Colors.blue_boolean.c, fg=Colors.blue_boolean.g},
  Special = {link = "Boolean"},  -- console.log(`${ ... }`)
  --SpecialChar = { link = "Special" },  -- format verbs %v %d ...
  PreProc = { link = "Boolean" },  -- checkhealth

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
  DiagnosticOk    = {ctermfg=Colors.green.c, fg=Colors.green.g},
  DiagnosticHint  = {ctermfg=Colors.hint_grey.c, fg=Colors.hint_grey.g},
  DiagnosticInfo  = {ctermfg=Colors.blue.c, fg=Colors.blue.g},
  DiagnosticWarn  = {ctermfg=Colors.orange.c, fg=Colors.orange.g},
  DiagnosticError = {ctermfg=Colors.red.c, fg=Colors.red.g},

  --- NOTE: `:help undercurl` sp(guisp) color 改变 undercurl, underline, underdashed ... 颜色.
  DiagnosticUnderlineOk = {
    ctermfg=Colors.green.c, fg=Colors.green.g,
    sp=Colors.green.g, underline=true,
  },
  DiagnosticUnderlineHint = {
    ctermfg=Colors.hint_grey.c, fg=Colors.hint_grey.g,
    sp=Colors.hint_grey.g, undercurl=true,
  },
  DiagnosticUnderlineInfo = {
    ctermfg=Colors.blue.c, fg=Colors.blue.g,
    sp=Colors.blue.g, undercurl=true,
  },
  DiagnosticUnderlineWarn = {
    ctermfg=Colors.orange.c, fg=Colors.orange.g,
    sp=Colors.orange.g, undercurl=true,
  },
  DiagnosticUnderlineError = {
    ctermfg=Colors.red.c, fg=Colors.red.g,
    sp=Colors.red.g, undercurl=true, bold=true,
  },

  DiagnosticUnnecessary = {link = "DiagnosticUnderlineHint"},
  DiagnosticDeprecated = {link = "DiagnosticUnderlineHint"},

  --- LSP 相关颜色 ---------------------------------------------------------------------------------
  --- vim.lsp.buf.document_highlight() 颜色, 类似 Same_ID
  LspReferenceText  = {ctermbg=Colors.g238.c, bg=Colors.g238.g},
  LspReferenceRead  = {link = 'LspReferenceText'},
  LspReferenceWrite = {link = 'LspReferenceText'},

  --- diff 颜色 ------------------------------------------------------------------------------------
  DiffAdd = {
    ctermfg=Colors.white.c, fg=Colors.white.g,
    ctermbg=Colors.green.c, bg='#4C5B2D',
  },
  DiffDelete = {
    ctermfg=Colors.white.c,
    ctermbg=52, bg=Colors.red_bg.g,
  },
  DiffChange = {},  -- 有修改的一整行的文字的颜色, 设置 clear.
  --- changed text
  DiffText = {
    ctermfg=Colors.black.c, fg=Colors.black.g,
    ctermbg=Colors.magenta.c, bg=Colors.magenta.g,
  },

  --- fold 颜色 ------------------------------------------------------------------------------------
  --- diff mode 下, 会自动设置:
  --- `set foldcolumn=2`, 在 foldcolumn 显示在 SignColumn 前面.
  --- `set foldmethod=diff`
  Folded = {ctermfg=67, fg='#5F87AF'}, -- 折叠行文字颜色
  FoldColumn = {ctermfg=Colors.green.c, fg=Colors.green.g}, -- foldcolumn 中 + - | 的颜色
  CursorLineFold = {link = "FoldColumn"},  -- cursor 所在行 foldcolumn 中 + - | 号颜色

  --- 其他常用颜色 ---------------------------------------------------------------------------------
  --- markdown title
  Title = {
    ctermfg=Colors.green.c, fg=Colors.green.g,
    bold=true,
  },
  --- `set conceallevel?`, markdown list, code block ...
  Conceal = {ctermfg=Colors.g246.c, fg=Colors.g246.g},
  --- json: key color; markdown: code block language(```go)
  Label = {ctermfg=Colors.cyan.c, fg=Colors.cyan.g},

  SpellBad = {
    ctermfg=Colors.red.c, fg=Colors.red.g,
    ctermbg=52, bg='#890000',
    bold=true, underline=true,
  },
  SpellCap = {
    ctermfg=Colors.orange.c, fg=Colors.orange.g,
    ctermbg=52, bg='#890000',
    bold=true, underline=true,
  },
  SpellLocal = {},  -- clear highlight

  --- treesitter 颜色设置 --------------------------------------------------------------------------
  --- comment
  ['@comment.error'] = {link = 'ErrorMsg'},  -- FIXME, BUG, ERROR
  ['@comment.warning'] = { link = "WarningMsg" },  -- HACK, WARN, WARNING, VVI, FIX
  ['@comment.note'] = { link = "SpecialComment" }, -- XXX, NOTE, DOCS, TEST, INFO
  ['@comment.todo'] = { link = "Todo" },           -- TODO
  ['@punctuation.delimiter.comment'] = { link = "Comment" },

  --- url: http://www.abc.com
  ['@string.special.url'] = { link = "Underlined" },  -- url

  --- markdown / markdown_inline
  ['@markup.heading'] = { link = "Title" }, -- markdown, # title
  ['@markup.strong'] = { bold = true }, -- markdown, **bold**
  ['@markup.italic'] = { italic = true },  -- markdown, *italic*, _italic_
  ['@markup.underline'] = { underline = true },  -- markdown, <u>underline</u>
  ['@markup.strikethrough'] = { strikethrough = true },  -- markdown, ~~strike~~
  ['@markup.link.label'] = { link = "Label" }, -- markdown, [@markup.link.label](@markup.link.url)
  ['@markup.link.url'] = { link = "Label" },   -- markdown, [@markup.link.label](@markup.link.url)
  --- markdown, inline `code`
  ['@markup.raw.markdown_inline'] = {
    ctermfg=173, fg='#CE9178',
    ctermbg=Colors.g236.c, bg=Colors.g236.g,
  },

  --- program language
  ['@type'] = { link = "Type" },
  ['@type.builtin'] = { link = "@type" },

  ['@keyword.conditional'] = { link = "Conditional" },
  ['@keyword.repeat'] = { link = "Conditional" },
  ['@keyword.return'] = { link = "Conditional" },
  ['@keyword.exception'] = { link = "Conditional" },  -- try catch throw
  ['@keyword.coroutine'] = { link = "Conditional" },  -- await
  ['@keyword.import'] = { link = "Conditional" },  -- import export

  ['@constant'] = { link = "Constant" },
  ['@constant.builtin'] = { link = "Boolean" },  -- null | undefined
  ['@variable'] = { link = "Label" },
  ['@variable.builtin'] = { link = "@variable" },

  ['@property'] = { link = "Label" },
  ['@property.private'] = { ctermfg=Colors.g246.c, fg=Colors.g246.g },  -- struct{ a:1 }
  ['@variable.member'] = { link = "@property" },
  ['@field'] = { link = "@property" },
  ['@parameter'] = { link = "@property" },

  --- \n \t ...
  ['@string.escape'] = {ctermfg=180, fg='#D7BA7D'},
  --- 'printf' is a language.
  ['@character.printf'] = { link = "Special" },

  --['@function'] = { link = "Function" },
  --['@function.call'] = { link = "Function" },
  --['@function.method'] = { link = "Function" },
  --['@function.method.call'] = { link = "Function" },
  ['@function.builtin'] = { link = "Function" },

  ['@tag'] = { link = "Type" },  -- jsx/tsx, <BrowserRouter> <ThemeProvider> <Link> <Button> ...
  ['@tag.builtin'] = { link = "Boolean" },  -- html, <div> <h1> <p> <li> ...
  ['@tag.delimiter'] = { ctermfg=Colors.g244.c, fg=Colors.g244.g },  -- html <tag> <> 括号颜色
  ['@tag.attribute'] = { link = "@property" },  -- html, <... width=..., @tag.attribute=... >
  ['@punctuation.special'] = { link = 'Special' },  -- js, ts, console.log(`${ ... }`)

  --- js / ts constructor. new Foo() 作为一个 type
  -- ['@constructor'] = { link = "Type" },

  --- custom highlight
  ['@import.underline'] = { link = "Underlined" },

  --- semantic tokens ------------------------------------------------------------------------------
  --- NOTE: clear highlight in order to use treesitter highlight
  ['@lsp.type.comment'] = {},
  ['@lsp.type.variable'] = {},
  -- ['@lsp.type.keyword'] = {},
  -- ['@lsp.type.namespace'] = {},
  -- ['@lsp.type.property'] = {},

  -- readonly = constant
  ['@lsp.mod.readonly'] = { link = "Constant" },
  ['@lsp.typemod.variable.readonly'] = { link = "Constant" },

  ['@lsp.typemod.function'] = { link = "Function" },

  --- NOTE: 以下设置是为了配合 lazy load plugins ---------------------------------------------------
  --- 以下颜色为了 lazy load lualine
  --- 无法使用 lualine 的情况下 StatusLine 颜色, eg: tagbar 有自己设置的 ':set statusline?' 颜色不受 lualine 控制.
  --- active
  StatusLine = {
    ctermfg=Colors.gold_fn.c, fg=Colors.gold_fn.g,
    ctermbg=Colors.black.c, bg=Colors.black.g,
  },
  --- inactive, NC (not-current windows)
  StatusLineNC = {
    ctermfg=Colors.g246.c, fg=Colors.g246.g,
    ctermbg=Colors.black.c, bg=Colors.black.g,
  },

  --- 以下颜色为了 lazy load bufferline
  TabLineFill = {}, -- NOTE: clear highlight
  TabLineSel = {
    ctermfg=Colors.gold_fn.c, fg=Colors.gold_fn.g,
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



