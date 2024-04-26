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
  none = 'NONE',

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
  purple = 170,  -- 170|68, keyword, eg: func, type, struct, var, const ... vscode keyword = 68
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

--- highlight api 设置: vim.api.nvim_set_hl(0, '@property', { ctermfg = 81 })
Highlights = {
  --- editor ---------------------------------------------------------------------------------------
  Normal = {ctermfg = Color.white},  -- window background color
  NormalNC = {link="Normal"},  -- non-focus window background color
  Visual = {ctermbg = 24},  -- Visual mode seleced text color

  --- VVI: Pmenu & FloatBorder 背景色需要设置为相同, 影响很多窗口的颜色.
  Pmenu       = {ctermfg = Color.white, ctermbg = Color.black}, -- Completion Menu & Floating Window 颜色
  PmenuSel    = {ctermbg = 238, bold=true, underline=true}, -- Completion Menu 选中项颜色
  PmenuSbar   = {ctermbg = 236}, -- Completion Menu scroll bar 背景色
  PmenuThumb  = {ctermbg = 240}, -- Completion Menu scroll bar 滚动条颜色
  NormalFloat = {link = "Pmenu"}, -- NormalFloat 默认 link to Pmenu
  FloatBorder = {ctermfg = Color.black}, -- Floating Window border 颜色需要和 Pmenu 的背景色相同
                                         -- border = {"▄","▄","▄","█","▀","▀","▀","█"}

  Comment    = {ctermfg = Color.comment_green}, -- 注释颜色
  NonText    = {ctermfg = 238}, -- 影响 listchars indentLine 颜色
  VertSplit  = {ctermfg = 236}, -- window 之间的分隔线颜色
  MatchParen = {ctermfg = Color.bracket_yellow, bold=true, underline=true}, -- 括号匹配颜色

  LineNr       = {ctermfg = 240}, -- 行号颜色
  CursorLine   = {ctermbg = 236}, -- 光标所在行颜色
  CursorLineNr = {ctermfg = Color.yellow, bold=true}, -- 光标所在行号的颜色
  SignColumn   = {ctermbg = Color.none}, -- line_number 左边用来标记错误, 打断点的位置. 术语 gutter
  ColorColumn  = {ctermbg = 235}, -- textwidth column 颜色
  QuickFixLine = {ctermfg = Color.boolean_blue, bold=true}, -- Quick Fix 选中行颜色

  IncSearch = {ctermfg = Color.black, ctermbg = Color.magenta, bold=true}, -- / ? 搜索颜色
  Search    = {ctermfg = Color.black, ctermbg = Color.yellow}, -- / ? * # g* g# 搜索颜色

  ErrorMsg   = {ctermfg = Color.white, ctermbg = Color.red}, -- echoerr 颜色
  WarningMsg = {ctermfg = Color.black, ctermbg = Color.orange}, -- echohl 颜色

  Todo = {ctermfg = Color.white, ctermbg = 22}, -- TODO 颜色
  SpecialComment = {ctermfg = Color.white, ctermbg = 63}, -- NOTE 颜色

  WildMenu = {ctermfg = Color.black, ctermbg = 39, bold=true}, -- command 模式自动补全
  Directory = {ctermfg = 246, ctermbg = 234, bold=true, underline=true}, -- for bufferline 在 nvim-tree 显示 "File Explorer"

  --- 基础颜色 -------------------------------------------------------------------------------------
  Keyword  = {ctermfg = Color.purple}, -- 最主要的颜色
  Function = {ctermfg = Color.func_gold}, -- func <Function> {}, 定义 & call func 都使用该颜色
  Type     = {ctermfg = Color.type_green, italic=true}, -- type <Type> struct
  Identifier = {link = "Normal"}, -- property & parameter
  Constant   = {ctermfg = Color.blue}, -- 常量颜色. eg: const <Constant> = 100
  --Structure = {link = "Type"},  -- 默认 link to Type

  Conditional = {ctermfg = Color.magenta}, -- if, switch, case ...
  Repeat    = {link = "Conditional"}, -- for range
  Statement = {link = "Conditional"}, -- syntax 中 'package' & 'import' 关键字
  Include   = {link = "Conditional"}, -- treesitter 中 'package', 'import', 'from' ... 关键字

  String    = {ctermfg = Color.string_orange},
  Character = {link = "String"},
  Number = {ctermfg = 151}, -- 100, int, uint ...
  Float  = {link = "Number"}, -- 10.02 float64, float32
  Boolean = {ctermfg = Color.boolean_blue},
  Special = {link = "Boolean"},  -- console.log(`${ ... }`)
  SpecialChar = {ctermfg = Color.cyan}, -- format verbs %v %d ...
  PreProc = {ctermfg = Color.boolean_blue}, -- tsxTSVariableBuiltin, tsxTSConstBuiltin ...

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
  DiagnosticHint  = {ctermfg = Color.hint_grey},
  DiagnosticInfo  = {ctermfg = Color.blue},
  DiagnosticWarn  = {ctermfg = Color.orange},
  DiagnosticError = {ctermfg = Color.red},
  DiagnosticUnnecessary = {link = "DiagnosticHint"},
  DiagnosticDeprecated = {link = "DiagnosticHint"},

  DiagnosticUnderlineHint = {ctermfg = Color.hint_grey, underline=true},
  DiagnosticUnderlineInfo = { underline = true },
  DiagnosticUnderlineWarn = { underline = true },
  DiagnosticUnderlineError = {ctermfg = Color.red, bold=true, underline=true},

  --- LSP 相关颜色 ---------------------------------------------------------------------------------
  --- vim.lsp.buf.document_highlight() 颜色, 类似 Same_ID
  LspReferenceText  = {ctermbg=238},
  LspReferenceRead  = {ctermbg=238},
  LspReferenceWrite = {ctermbg=238},

  --- diff 颜色 ------------------------------------------------------------------------------------
  DiffAdd    = {ctermfg = Color.black, ctermbg = Color.green},
  DiffDelete = {ctermfg = Color.white, ctermbg = Color.dark_red},
  DiffChange = {},  -- 有修改的一整行的文字的颜色
  DiffText   = {ctermfg = Color.black, ctermbg = Color.magenta}, -- changed text

  --- fold 颜色 ------------------------------------------------------------------------------------
  --- diff mode 下, 会自动设置:
  --- `set foldcolumn=2`, 在 foldcolumn 显示在 SignColumn 前面.
  --- `set foldmethod=diff`
  Folded     = {ctermfg = 67},  -- 折叠行文字颜色
  FoldColumn = {ctermfg = Color.green},    -- foldcolumn 中 + - | 的颜色
  CursorLineFold = {link = "FoldColumn"},  -- cursor 所在行 foldcolumn 中 + - | 号颜色

  --- 其他常用颜色 ---------------------------------------------------------------------------------
  Title = {ctermfg = Color.green, bold=true}, -- markdown title
  Conceal = {ctermfg = 246}, -- `set conceallevel?`, markdown list, code block ...
  Label = {ctermfg = Color.cyan}, -- json: key color; markdown: code block language(```go)

  SpellBad = {ctermfg = Color.red, ctermbg = Color.dark_red, bold = true, underline = true},
  SpellCap = {ctermfg = Color.orange, ctermbg = Color.dark_red, bold = true, underline = true},
  SpellLocal = {},  -- clear highlight

  --- NOTE: treesitter 颜色设置 --------------------------------------------------------------------
  --- comment
  ['@comment.error'] = { ctermfg = Color.white, ctermbg = 196 }, -- FIXME, BUG, ERROR
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
  ['@markup.link.label'] = { ctermfg = Color.cyan }, -- markdown, [@markup.link.label](@markup.link.label)
  ['@markup.link.url'] = { ctermfg = Color.cyan },   -- markdown, [@markup.link.label](@markup.link.label)
  ['@markup.raw.markdown_inline'] = { ctermfg = Color.string_orange, ctermbg = 237 },  -- markdown, inline `code`

  --- program language
  ['@string.escape'] = { ctermfg = 180 },  -- \n \t ...
  ['@module'] = { ctermfg = Color.type_green },  -- package <module>

  --['@constant'] = { link = "Constant" },
  ['@variable'] = { link = "Normal" },
  ['@constant.builtin'] = { ctermfg = Color.boolean_blue },  -- typescript 关键字 'null' ...
  ['@variable.builtin'] = { ctermfg = Color.boolean_blue },  -- typescript 关键字 'undefined', 'this', 'console' ...

  ['@property'] = { ctermfg = Color.cyan },
  ['@property.private'] = { ctermfg = 246 },
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

  ['@tag'] = { ctermfg = 68 },  -- html, <@tag></@tag>
  ['@tag.delimiter'] = { ctermfg = 243 },  -- html, <div></div>, <> 括号颜色
  ['@tag.attribute'] = { link = "@property" },  -- html, <... width=..., @tag.attribute=... >
  ['@punctuation.special'] = { link = 'Special' },  -- js, ts, console.log(`${ ... }`)

  --- NOTE: 以下设置是为了配合 lazy load plugins ---------------------------------------------------
  --- 以下颜色为了 lazy load lualine
  --- 无法使用 lualine 的情况下 StatusLine 颜色, eg: tagbar 有自己设置的 ':set statusline?' 颜色不受 lualine 控制.
  StatusLine   = {ctermfg = Color.func_gold, ctermbg = Color.black}, -- active
  StatusLineNC = {ctermfg = 246, ctermbg = Color.black}, -- inactive, NC (not-current windows)

  --- 以下颜色为了 lazy load bufferline
  TabLineFill = {}, -- NOTE: clear TabLineFill
  TabLineSel = {ctermfg = Color.func_gold, ctermbg = Color.black, bold=true},
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



