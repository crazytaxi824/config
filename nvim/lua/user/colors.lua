--- README ----------------------------------------------------------------------------------------- {{{
--- 注意: 自定义 color 放在最后，用来 override 之前插件定义的颜色.
--    ':hi'                查看所有 color scheme
--    'ctermfg, ctermbg'   表示 color terminal (256 色)
--    'termfg, termbg'     表示 16 色 terminal
--    'term, cterm'        表示样式, underline, bold, italic ...
--
--- NOTE: 只有 ':hi[!] link' 才有 [!] 设置.
--- 如果是 ':hi <group>' 只会覆盖对应的 kv 颜色值.
--- eg: 'hi Foo cterm=bold ctermfg=201 ctermbg=233'
--      'hi Foo ctermfg=190'
--      最终结果为 'hi Foo cterm=bold ctermfg=190 ctermbg=233'
--
--- 颜色设置 cmd
--    ':hi <group> ctermfg...'           Set color
--    ':hi clear <group>'                Reset to default color. 如果没有 default color, 则结果为 {group} xxx cleared
--    ':hi! link <group> NONE'           VVI: 将颜色设为 NONE. 直接忽略 default color, 将颜色设置为 {group} xxx cleared
--    ':hi link <group1> <group2>'       将 <group1> 的颜色设置为 <group2> 的颜色.
--                                       如果 <group2> 颜色变化, <group1> 颜色也会随之变化.
--    ':hi! link <group1> <group2>'      相当于 ':hi clear <group>' && ':hi link <group1> <group2>'
--    ':hi default link <group1> <group2>'    将 <group1> default 颜色设置为 <group2> 的颜色.
--    ':hi! default link <group1> <group2>'   相当于 ':hi clear <group>' && ':hi default link <group1> <group2>'
--
--- lua 设置颜色: `:help nvim_set_hl`
--    vim.api.nvim_set_hl()
--
-- -- }}}

--- NOTE: old setting ------------------------------------------------------------------------------ {{{
--- editor -----------------------------------------------------------------------------------------
-- vim.cmd('hi Normal ctermbg=NONE ctermfg=251')  -- 透明背景 / 深色背景 - 一般文字颜色 251
-- vim.cmd('hi Visual ctermbg=24')                -- Visual 模式下 select 到的字符颜色. 类似 vscode 颜色

--- VVI: Pmenu & FloatBorder 背景色需要设置为相同, 影响很多窗口的颜色.
-- local bg_black = 233
-- vim.cmd('hi PmenuSel cterm=underline,bold ctermfg=None ctermbg=238')  -- Completion Menu 选中项颜色
-- vim.cmd('hi Pmenu ctermfg=251 ctermbg=' .. bg_black)  -- Completion Menu & Floating Window 颜色
-- vim.cmd('hi PmenuSbar ctermbg=236')  -- Completion Menu scroll bar 背景色
-- vim.cmd('hi PmenuThumb ctermbg=240')  -- Completion Menu scroll bar 滚动条颜色
-- vim.cmd('hi! link NormalFloat Pmenu')  -- NormalFloat 默认 link to Pmenu
-- vim.cmd('hi FloatBorder ctermfg=' .. bg_black)   -- Floating Window border 颜色需要和 Pmenu 的背景色相同
--                                                                -- border = {"▄","▄","▄","█","▀","▀","▀","█"}

-- vim.cmd('hi Comment ctermfg=71')             -- 注释颜色
-- vim.cmd('hi Folded ctermbg=235 ctermfg=67')  -- 折叠行颜色
-- vim.cmd('hi NonText ctermfg=238')            -- 影响 listchars indentLine 颜色
-- vim.cmd('hi VertSplit ctermfg=242 ctermbg=None cterm=None')  -- 屏幕分隔线颜色
-- vim.cmd('hi MatchParen cterm=underline,bold ctermfg=220 ctermbg=None')  -- 括号匹配颜色

-- vim.cmd('hi LineNr ctermfg=240')                   -- 行号颜色
-- vim.cmd('hi CursorLine ctermbg=236 cterm=None')    -- 光标所在行颜色
-- vim.cmd('hi CursorLineNr cterm=bold ctermfg=190')  -- 光标所在行号的颜色
-- vim.cmd('hi SignColumn ctermbg=None')              -- line_number 左边用来标记错误, 打断点的位置. 术语 gutter
-- vim.cmd('hi ColorColumn ctermbg=238')              -- textwidth column 颜色
-- vim.cmd('hi QuickFixLine cterm=bold ctermbg=237 ctermfg=75')  -- Quick Fix 选中行颜色

-- vim.cmd('hi IncSearch ctermfg=0 ctermbg=213 cterm=bold')  -- / ? 搜索颜色
-- vim.cmd('hi Search ctermfg=0 ctermbg=190')                -- / ? * # g* g# 搜索颜色

-- vim.cmd('hi ErrorMsg ctermfg=253 ctermbg=167')     -- echoerr 颜色
-- vim.cmd('hi WarningMsg ctermfg=236 ctermbg=214')   -- echohl 颜色, XXX FIXME BUG 颜色
-- vim.cmd('hi Todo cterm=bold ctermfg=251 ctermbg=22')            -- TODO, HACK 颜色
-- vim.cmd('hi SpecialComment cterm=bold ctermfg=251 ctermbg=63')  -- NOTE: DEBUG: FOO: 颜色

-- vim.cmd('hi WildMenu cterm=bold ctermfg=235 ctermbg=39')     -- command 模式自动补全
-- vim.cmd('hi Directory cterm=bold,underline ctermfg=246 ctermbg=234')  -- for bufferline 在 nvim-tree 显示 "File Explorer"

--- 基础颜色 ---------------------------------------------------------------------------------------
-- vim.cmd('hi Keyword ctermfg=170')           -- 最主要的颜色
-- vim.cmd('hi Function ctermfg=85')           -- func <Function> {}, 定义 & call func 都使用该颜色
-- vim.cmd('hi Type ctermfg=79 cterm=italic')  -- type <Type> struct
-- vim.cmd('hi! link Identifier Type')         -- typescriptTypeReference
-- vim.cmd('hi! link Constant Normal')         -- 常量颜色. eg: const <Constant> = 100

-- vim.cmd('hi Conditional ctermfg=213')      -- if, switch, case ...
-- vim.cmd('hi! link Repeat Conditional')     -- for range
-- vim.cmd('hi! link Statement Conditional')  -- 默认 syntax 中 'package' & 'import' 关键字
-- vim.cmd('hi! link Include Conditional')    -- package, import ...

-- vim.cmd('hi! link Delimiter Normal')    -- 符号颜色, [] () {} ; : ...
-- vim.cmd('hi! link Operator Normal')     -- = != == > < ...
-- vim.cmd('hi Structure ctermfg=81')      -- luaTable

-- vim.cmd('hi String ctermfg=173')        -- "abc"
-- vim.cmd('hi Character ctermfg=173')     -- 'a'
-- vim.cmd('hi Special ctermfg=75')        --  null (tsxTSConstBuiltin) | undefined (tsxTSVariableBuiltin)
-- vim.cmd('hi SpecialChar ctermfg=81')    -- \n \t \" ... escape string
-- vim.cmd('hi Number ctermfg=151')        -- 100, int, uint ...
-- vim.cmd('hi Boolean ctermfg=75')        -- true / false
-- vim.cmd('hi PreProc ctermfg=75')        -- tsxTSVariableBuiltin, tsxTSConstBuiltin ...
-- vim.cmd('hi! link Float Number')        -- 10.02 float64, float32

--- diff 颜色 --------------------------------------------------------------------------------------
-- vim.cmd('hi DiffAdd ctermfg=42 ctermbg=NONE')
-- vim.cmd('hi DiffDelete ctermfg=167 ctermbg=NONE')
-- vim.cmd('hi DiffChange cterm=None ctermfg=213 ctermbg=NONE')
-- vim.cmd('hi DiffText cterm=None ctermfg=190 ctermbg=238')

--- diff mode 下
--- `set foldcolumn?`=2 在 foldcolumn 显示在 SignColumn 前面.
--- `set foldmethod?`=diff
-- vim.cmd('hi FoldColumn cterm=bold ctermfg=42 ctermbg=NONE')

--- 其他常用颜色 -----------------------------------------------------------------------------------
-- vim.cmd('hi Title cterm=bold ctermfg=42')      -- markdown Title
-- vim.cmd('hi Conceal ctermfg=246 ctermbg=None') -- markdown 特殊符号颜色
-- vim.cmd('hi Label ctermfg=81')                 -- json key color

--- diagnostics 颜色设置 ---------------------------------------------------------------------------
--- DiagnosticInfo - lua global function name begin with lower-case.
--- DiagnosticHint - lua function not used.

--- diagnostics popup/floating window text color.
-- vim.cmd('hi DiagnosticError ctermfg=167')
-- vim.cmd('hi DiagnosticWarn ctermfg=214')
-- vim.cmd('hi DiagnosticInfo ctermfg=75')
-- vim.cmd('hi DiagnosticHint ctermfg=244')

--- diagnostics sign, 默认和 diagnostics text 颜色一样
-- --vim.cmd('hi DiagnosticSignError ctermfg=167')
-- --vim.cmd('hi DiagnosticSignWarn ctermfg=214')
-- --vim.cmd('hi DiagnosticSignInfo ctermfg=75')
-- --vim.cmd('hi DiagnosticSignHint ctermfg=244')

--- diagnostics error 'source code' color.
-- vim.cmd('hi DiagnosticUnderlineError cterm=bold,underline ctermfg=167')
-- --vim.cmd('hi DiagnosticUnderlineWarn cterm=bold,underline ctermfg=167')
-- --vim.cmd('hi DiagnosticUnderlineInfo ctermfg=75')
-- vim.cmd('hi DiagnosticUnderlineHint ctermfg=244')

--- LSP 相关颜色 ----------------------------------------------------------------------------------
--- vim.lsp.buf.document_highlight() 颜色, 类似 Same_ID
-- vim.cmd('hi LspReferenceText ctermbg=238')
-- vim.cmd('hi LspReferenceRead ctermbg=238')
-- vim.cmd('hi LspReferenceWrite ctermbg=238')

--- NOTE: 以下设置是为了配合 lazy load plugins -----------------------------------------------------
--- 以下颜色为了 lazy load lualine
--- 无法使用 lualine 的情况下 StatusLine 颜色, eg: tagbar 有自己设置的 ':set statusline?' 颜色不受 lualine 控制.
-- vim.cmd('hi StatusLine cterm=NONE ctermfg=85 ctermbg=233')    -- active
-- vim.cmd('hi StatusLineNC cterm=NONE ctermfg=246 ctermbg=233') -- inactive, NC (not-current windows)

--- 以下颜色为了 lazy load bufferline
-- vim.cmd([[hi TabLineFill cterm=NONE ctermfg=NONE ctermbg=NONE]])
-- vim.cmd([[hi TabLineSel cterm=bold ctermfg=85 ctermbg=233]])
-- --vim.cmd([[hi TabLine cterm=NONE ctermfg=234 ctermbg=NONE]])

--- 设置 syntax 颜色是为了让 treesitter lazy render 的时候不至于颜色差距太大.
--- set vim-syntax color to match treesitter color
-- vim.cmd('hi! link typescriptMember TSProperty')
-- vim.cmd('hi! link typescriptInterfaceName TSType')
-- vim.cmd('hi! link typescriptExport TSKeyword')
-- vim.cmd('hi! link typescriptImport Conditional')
-- -- }}}

--- NOTE: nvim_set_hl(namespace, hl_group_name, {val}), nvim v0.7+
--- namespace = 0 表示全局设置.
--- {val} 中 nocombine: boolean
--- {val} 中使用 cterm = {bold=true, underline=true, ...}, 也可以不使用 cterm.
---
--- eg:
--- vim.api.nvim_set_hl(0, "Foo", {ctermfg=123, ctermbg=234, cterm={bold=true, nocombine=true}})
--- vim.api.nvim_set_hl(0, "Foo", {link="Normal"})
--- vim.api.nvim_set_hl(0, 'Visual', {})  NOTE: clear the highlight group.
---
--- nvim_create_namespace({name})  namespace are used for buffer highlights.
--- nvim_buf_add_highlight(),  有点类似 matchaddpos() 但是不安全一样.
--- 
--- VVI: nvim_set_hl() 没有实现 `hi! default link Foo Bar` 和 `hi clear Foo` 功能.

Color = {  -- {{{
  none = 'NONE',

  white     = 251,  -- foreground, text
  black       = 233,  -- black background

  keyword_purple = 170,  -- keyword, eg: func, type, struct, var, const ...
  func_gold      = 85,   -- func, function_call, method, method_call ... | bufferline, lualine
  string_orange  = 212,  -- string
  special_cyan   = 81,   -- SpecialChar, fmt.Printf("%s \n")
  boolean_blue   = 75,   -- Special, boolean
  comment_green  = 71,   -- comments
  type_green     = 79,   -- type, 数据类型
  title_green    = 42,   -- markdown title
  conditional_magenta = 213,  -- IncSearch, return, if, else, break, package, import
  statusline_yellow   = 190,  -- Search, lualine: Insert Mode background && tabline: tab seleced background

  --- message 颜色
  hint_grey   = 244,  -- hint message
  info_blue   = 75,   -- info message
  warn_orange = 214,  -- warning message
  error_red   = 167,  -- error message

  --- 其他颜色
  dark_orange    = 202,  -- trailing_whitespace & mixed_indent, nvim-notify warn message border
  dark_red       = 52,   -- 256 color 中最深的红色, 接近黑色. 通常用于 bg.
  bracket_yellow = 220,  -- 匹配括号 () 颜色.
}
-- -- }}}

-- vim.api.nvim_set_hl(0, '@property', { ctermfg = 81 })
local highlights = {
  --- editor ---------------------------------------------------------------------------------------
  Normal = {ctermfg = Color.white},
  Visual = {ctermbg = 24},

  --- VVI: Pmenu & FloatBorder 背景色需要设置为相同, 影响很多窗口的颜色.
  Pmenu       = {ctermfg = Color.white, ctermbg = Color.black}, -- Completion Menu & Floating Window 颜色
  PmenuSel    = {ctermbg = 238, cterm = {'bold', 'underline'}}, -- Completion Menu 选中项颜色
  PmenuSbar   = {ctermbg = 236}, -- Completion Menu scroll bar 背景色
  PmenuThumb  = {ctermbg = 240}, -- Completion Menu scroll bar 滚动条颜色
  NormalFloat = {link = "Pmenu"}, -- NormalFloat 默认 link to Pmenu
  FloatBorder = {ctermfg = Color.black}, -- Floating Window border 颜色需要和 Pmenu 的背景色相同
                                            -- border = {"▄","▄","▄","█","▀","▀","▀","█"}

  Comment    = {ctermfg = Color.comment_green}, -- 注释颜色
  Folded     = {ctermfg = 67, ctermbg = 235}, -- 折叠行颜色
  NonText    = {ctermfg = 238}, -- 影响 listchars indentLine 颜色
  VertSplit  = {ctermfg = 242}, -- window 之间的分隔线颜色
  MatchParen = {ctermfg = 220, cterm = {'bold', 'underline'}}, -- 括号匹配颜色

  LineNr       = {ctermfg = 240}, -- 行号颜色
  CursorLine   = {ctermbg = 236}, -- 光标所在行颜色
  CursorLineNr = {ctermfg = Color.statusline_yellow, cterm = {'bold'}}, -- 光标所在行号的颜色
  SignColumn   = {ctermbg = Color.none}, -- line_number 左边用来标记错误, 打断点的位置. 术语 gutter
  ColorColumn  = {ctermbg = 238}, -- textwidth column 颜色
  QuickFixLine = {ctermfg = Color.boolean_blue, cterm = {'bold'}}, -- Quick Fix 选中行颜色

  IncSearch = {ctermfg = Color.black, ctermbg = Color.conditional_magenta, cterm = {'bold'}}, -- / ? 搜索颜色
  Search    = {ctermfg = Color.black, ctermbg = Color.statusline_yellow}, -- / ? * # g* g# 搜索颜色

  ErrorMsg   = {ctermfg = Color.white, ctermbg = Color.error_red}, -- echoerr 颜色
  WarningMsg = {ctermfg = Color.black, ctermbg = Color.warn_orange}, -- echohl 颜色, XXX FIXME BUG 颜色

  Todo = {ctermfg = Color.white, ctermbg = 22, cterm = {'bold'}}, -- TODO, HACK 颜色
  SpecialComment = {ctermfg = Color.white, ctermbg = 63, cterm = {'bold'}}, -- NOTE: DEBUG: FOO: 颜色

  WildMenu = {ctermfg = Color.black, ctermbg = 39, cterm = {'bold'}}, -- command 模式自动补全
  Directory = {ctermfg = 246, ctermbg = 234, cterm = {'bold', 'underline'}}, -- for bufferline 在 nvim-tree 显示 "File Explorer"

  --- 基础颜色 -------------------------------------------------------------------------------------
  Keyword  = {ctermfg = Color.keyword_purple}, -- 最主要的颜色
  Function = {ctermfg = Color.func_gold}, -- func <Function> {}, 定义 & call func 都使用该颜色
  Type     = {ctermfg = Color.type_green, cterm = {'italic'}}, -- type <Type> struct
  Identifier = {link = "Type"}, -- typescriptTypeReference
  Constant   = {link = "Normal"}, -- 常量颜色. eg: const <Constant> = 100
  --Structure  = {ctermfg = color.special_cyan}, -- luaTable

  Conditional = {ctermfg = Color.conditional_magenta}, -- if, switch, case ...
  Repeat    = {link = "Conditional"}, -- for range
  Statement = {link = "Conditional"}, -- syntax 中 'package' & 'import' 关键字
  Include   = {link = "Conditional"}, -- treesitter 中 'package' & 'import' 关键字

  String    = {ctermfg = 173},
  Character = {link = "String"},
  Number = {ctermfg = 151}, -- 100, int, uint ...
  Float  = {link = "Number"}, -- 10.02 float64, float32
  Boolean = {ctermfg = Color.boolean_blue},
  Special = {link = "Boolean"}, --  null (tsxTSConstBuiltin) | undefined (tsxTSVariableBuiltin)
  SpecialChar = {ctermfg = Color.special_cyan}, -- \n \t \" ... escape string
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
  DiagnosticInfo  = {ctermfg = Color.info_blue},
  DiagnosticWarn  = {ctermfg = Color.warn_orange},
  DiagnosticError = {ctermfg = Color.error_red},

  DiagnosticUnderlineError = {ctermfg = Color.error_red, cterm = {'bold', 'underline'}}, -- 加入 bold

  --- LSP 相关颜色 ---------------------------------------------------------------------------------
  --- vim.lsp.buf.document_highlight() 颜色, 类似 Same_ID
  LspReferenceText  = {ctermbg=238},
  LspReferenceRead  = {ctermbg=238},
  LspReferenceWrite = {ctermbg=238},

  --- diff 颜色 ------------------------------------------------------------------------------------
  DiffAdd    = {ctermfg = Color.black, ctermbg = Color.title_green},
  DiffDelete = {ctermfg = Color.white, ctermbg = Color.error_red},
  DiffChange = {ctermfg = Color.conditional_magenta},
  DiffText   = {ctermfg = Color.black, ctermbg = Color.conditional_magenta}, -- changed text

  --- diff mode 下
  --- `set foldcolumn?`=2 在 foldcolumn 显示在 SignColumn 前面.
  --- `set foldmethod?`=diff
  FoldColumn = {ctermfg = Color.title_green},

  --- 其他常用颜色 ---------------------------------------------------------------------------------
  Title = {ctermfg = Color.title_green, cterm = {'bold'}}, -- markdown title
  Conceal = {ctermfg = 246}, -- `set conceallevel?`, markdown list, code block ...
  Label = {ctermfg = Color.special_cyan}, -- json key color

  --- NOTE: 以下设置是为了配合 lazy load plugins ---------------------------------------------------
  --- 以下颜色为了 lazy load lualine
  --- 无法使用 lualine 的情况下 StatusLine 颜色, eg: tagbar 有自己设置的 ':set statusline?' 颜色不受 lualine 控制.
  StatusLine   = {ctermfg = Color.func_gold, ctermbg = Color.black}, -- active
  StatusLineNC = {ctermfg = 246, ctermbg = Color.black}, -- inactive, NC (not-current windows)

  --- 以下颜色为了 lazy load bufferline
  TabLineFill = {}, -- NOTE: clear TabLineFill
  TabLineSel = {ctermfg = Color.func_gold, ctermbg = Color.black, cterm = {'bold'}},
  --TabLine = {ctermfg = 234},

  --- 设置 syntax 颜色是为了让 treesitter lazy render 的时候不至于颜色差距太大.
  --- set vim-syntax color to match treesitter color
  typescriptMember = {link = '@property'},
  typescriptInterfaceName = {link = 'Type'},
  typescriptExport = {link = 'Keyword'},
  typescriptImport = {link = 'Conditional'},
}

--- nvim_set_hl()
for hl_group, hl_val in pairs(highlights) do
  local vals = {}
  for key, value in pairs(hl_val) do
    if key == 'cterm' then
      --- {bold=true, underline=true, italic=true, ...}
      for _, k in ipairs(value) do
        vals[k] = true
      end
    else
      --- {ctermfg=, ctermbg=, link=, ...}
      vals[key] = value
    end
  end

  vim.api.nvim_set_hl(0, hl_group, vals)
end

--- diff mode 模式下 CursorLine 样式 --- {{{
-- vim.cmd([[
--   if &diff
--     hi CursorLine cterm=underline
--   endif
-- ]])
-- -- }}}
if vim.wo.diff then
  vim.api.nvim_set_hl(0, 'CursorLine', {cterm = {underline = true}})
end

--- treesitter 颜色 --------------------------------------------------------------------------------
--- treesitter global 颜色设置
--- NOTE: nvim 0.8+ highlight 的重大变化: 弃用 TSxxx 命名方式, 使用 @xxx 方式.
--- filetype based highlight 方式从 goTSProperty 改为 @property.go.
--- `hi @property ...` 为全局设置 highlight;
--- `hi @property.go ...` 单独为 filetype=go 的文件设置 highlight.
--- https://github.com/nvim-treesitter/nvim-treesitter/pull/3656
if vim.fn.has('nvim-0.8') == 1 then
  vim.api.nvim_set_hl(0, '@field', { link = "Normal" })
  vim.api.nvim_set_hl(0, '@property', { ctermfg = 81 })
  vim.api.nvim_set_hl(0, '@parameter', { link = "Normal" })

  --vim.api.nvim_set_hl(0, '@function', { link = "Function" })
  --vim.api.nvim_set_hl(0, '@function.call', { link = "Function" })
  vim.api.nvim_set_hl(0, '@function.builtin', { link = "Function" })
  --vim.api.nvim_set_hl(0, '@method', { link = "Function" })
  --vim.api.nvim_set_hl(0, '@method.call', { link = "Function" })

  vim.api.nvim_set_hl(0, '@keyword.return', { link = "Conditional" })
  vim.api.nvim_set_hl(0, '@namespace', { link = "Normal" })

  --- html, tag <div></div>
  vim.api.nvim_set_hl(0, '@tag', { ctermfg = 68 })  -- <div></div>, html 内置标签文字颜色 div
  vim.api.nvim_set_hl(0, '@tag.delimiter', { ctermfg = 243 })  -- <div></div>, <> 括号颜色
  vim.api.nvim_set_hl(0, '@tag.attribute', { link = "@property" })  -- <... width=..., height=... >
  vim.api.nvim_set_hl(0, '@text.uri', { link = "String" })

  --- typescript
  vim.api.nvim_set_hl(0, '@constructor', { link = "Normal" })  -- import <TSConstructor> from 'react'
  vim.api.nvim_set_hl(0, '@keyword.operator', { link = "Keyword" })  -- typescript 关键字 new

  --- golang, NOTE: 单独为 go 设置 Property 颜色.
  vim.api.nvim_set_hl(0, '@property.go', { link = "Normal" })

  --- markdown, NOTE: 单独为 markdown 设置颜色.
  vim.api.nvim_set_hl(0, '@text.literal.markdown_inline', { ctermfg = 173, ctermbg = 237 })  -- `code`
  vim.api.nvim_set_hl(0, '@punctuation.special.markdown', { link = "Conceal" })  -- `- * #`
  vim.api.nvim_set_hl(0, '@punctuation.delimiter.markdown', { link = "Conceal" })  -- `- * #`
else
  vim.cmd('hi! link TSField Normal')      -- golang struct field, when define
  vim.cmd('hi TSProperty ctermfg=81')     -- like TSField, eg: Foo.<Property>, 主要为 js, ts... 用.
  vim.cmd('hi! link TSParameter Normal')  -- 入参出参

  vim.cmd('hi! link TSFunction Function')
  vim.cmd('hi! link TSFuncBuiltin Function')  -- new() make() copy() ...
  vim.cmd('hi! link TSMethod Function')

  vim.cmd('hi! link TSKeywordReturn Conditional')  -- return
  vim.cmd('hi! link TSNamespace Normal')           -- package <Namespace>

  --- html, tag <div></div>
  vim.cmd('hi TSTag ctermfg=68')             -- <div></div>, html 内置标签文字颜色 div
  vim.cmd('hi TSTagDelimiter ctermfg=243')   -- <div></div>, <> 括号颜色
  vim.cmd('hi! link TSTagAttribute TSProperty')  -- <... width=..., height=... >
  vim.cmd('hi! link TSURI String')  -- <src="TSURI">

  --- typescript
  vim.cmd('hi! link TSConstructor Normal')  -- import <TSConstructor> from 'react'
  vim.cmd('hi! link TSKeywordOperator Keyword')  -- 关键字 new

  --- golang, NOTE: 单独为 go 设置 Property 颜色.
  vim.cmd('hi! link goTSProperty Normal')  -- 设置 golang 的 Foo.Name 颜色为 Normal

  --- markdown, NOTE: 单独为 markdown 设置颜色.
  vim.cmd('hi markdown_inlineTSLiteral ctermbg=238')  -- `code`
  vim.cmd('hi markdownTSPunctSpecial ctermfg=246')    -- `- * #`
end



