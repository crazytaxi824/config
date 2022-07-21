--- 主要颜色 ---------------------------------------------------------------------------------------- {{{
--- 注意: 自定义 color 放在最后，用来 override 之前插件定义的颜色.
--    ':hi'                查看所有 color scheme
--    'ctermfg, ctermbg'   表示 color terminal (256 色)
--    'termfg, termbg'     表示 16 色 terminal
--    'term, cterm'        表示样式, underline, bold, italic ...
--
--- 常用颜色
--    ctermfg=188/252   白色   -  一般文字颜色
--    ctermfg=85        暗金色 - 函数名, 函数调用
--    ctermfg=213       亮粉色 - return, if, else, break
--    ctermfg=173       暗橙色 - String, ':hi String'
--    ctermfg=220       亮橙色 - 括号匹配颜色
--    ctermfg=170       紫色   - onedark theme (主色调)
--    ctermfg=117/81    淡蓝色 - goField, Special, fmt.Printf("%s \n")
--    ctermfg=75        蓝色   - package, import, func
--    ctermfg=43        淡绿色 - 数据类型, 数字(int, bool)
--    ctermfg=71        绿色   - comment 注释 (:hi Comment)
--
--- NOTE: 只有 ':hi link' 才有 [!] 设置.
--- 如果是 ':hi <group>' 只会覆盖对应的 kv 颜色值.
--- eg: 'hi Foo cterm=bold ctermfg=201 ctermbg=233'
--      'hi Foo ctermfg=190'
--      最终结果为 'hi Foo cterm=bold ctermfg=190 ctermbg=233'
--
--- 颜色设置 cmd
--    ':hi <group> ctermfg...'           Set color
--    ':hi clear <group>'                Reset to default color
--    ':hi default <group> ctermfg...'   Set default color, 如果使用 `:hi clear <group>` 会回到这个颜色.
--
--    ':hi links <group1> <group2>'      将 <group1> 的颜色设置为 <group2> 的颜色.
--                                       如果 <group2> 颜色变化, <group1> 颜色也会随之变化.
--    ':hi! links <group1> <group2>'     相当于 ':hi clear <group>' && ':hi links <group1> <group2>'
--    ':hi default links <group1> <group2>'    将 <group1> default 颜色设置为 <group2> 的颜色.
--    ':hi! default links <group1> <group2>'   相当于 ':hi clear <group>' && ':hi default links <group1> <group2>'
--
--- lua 设置颜色: `:help nvim_set_hl`
--    vim.api.nvim_set_hl()
--
-- -- }}}

--- editor -----------------------------------------------------------------------------------------
vim.cmd('hi Normal ctermbg=NONE ctermfg=188')      -- 透明背景 / 深色背景 - 一般文字颜色 188/252
vim.cmd('hi Visual ctermbg=24')                    -- Visual 模式下 select 到的字符颜色. 类似 vscode 颜色

vim.cmd('hi Comment ctermfg=71')                   -- 注释颜色
vim.cmd('hi Folded ctermbg=235 ctermfg=67')        -- 折叠行颜色
vim.cmd('hi NonText ctermfg=238')                  -- 影响 listchars indentLine 颜色
vim.cmd('hi VertSplit ctermfg=59 ctermbg=None cterm=None')   -- 屏幕分隔线颜色
vim.cmd('hi MatchParen cterm=underline,bold ctermfg=220 ctermbg=None')    -- 括号匹配颜色

vim.cmd('hi LineNr ctermfg=240')                   -- 行号颜色
vim.cmd('hi CursorLine ctermbg=235 cterm=None')    -- 光标所在行颜色
vim.cmd('hi CursorLineNr cterm=bold ctermfg=191')  -- 光标所在行号的颜色
vim.cmd('hi SignColumn ctermbg=None')              -- line_number 左边用来标记错误, 打断点的位置. 术语 gutter
vim.cmd('hi ColorColumn ctermbg=238')              -- textwidth column 颜色
vim.cmd('hi QuickFixLine cterm=bold ctermbg=237 ctermfg=75')  -- Quick Fix 选中行颜色

vim.cmd('hi IncSearch ctermfg=0 ctermbg=213 cterm=None')  -- / ? 搜索颜色
vim.cmd('hi Search ctermfg=0 ctermbg=191')                -- / ? * # g* g# 搜索颜色
vim.cmd('hi HLSearchWord cterm=None ctermfg=232 ctermbg=232') -- 自定义 highling next search blink 的颜色

vim.cmd('hi ErrorMsg ctermfg=253 ctermbg=203')     -- echoerr 颜色
vim.cmd('hi WarningMsg ctermfg=236 ctermbg=215')   -- echohl 颜色, XXX FIXME BUG 颜色
vim.cmd('hi Todo ctermbg=28 ctermfg=188')          -- TODO, HACK 颜色
vim.cmd('hi SpecialComment ctermbg=63 ctermfg=188')  -- NOTE: DEBUG: FOO: 颜色

vim.cmd('hi PmenuSel cterm=underline,bold ctermfg=None ctermbg=238')  -- Complettion Menu 选中项颜色
vim.cmd('hi Pmenu ctermfg=188 ctermbg=233')  -- VVI: Completion Menu & Floating Window 背景颜色, 或者 bg=236.
vim.cmd('hi FloatBorder ctermfg=233')   -- VVI: Floating Window border 颜色需要和 Pmenu 的背景色相同 (bg=236)
                                        -- border = {"▄","▄","▄","█","▀","▀","▀","█"}

vim.cmd('hi WildMenu cterm=bold ctermfg=235 ctermbg=39')     -- command 模式自动补全

vim.cmd('hi Directory cterm=bold,underline ctermfg=246 ctermbg=234')  -- for bufferline 在 nvim-tree 显示 "File Explorer"

--- 基础颜色 ---------------------------------------------------------------------------------------
vim.cmd('hi Keyword ctermfg=170')           -- 最主要的颜色
vim.cmd('hi Function ctermfg=85')           -- func <Function> {}, 定义 & call func 都使用该颜色
vim.cmd('hi Type ctermfg=43 cterm=italic')  -- type <Type> struct
vim.cmd('hi! link Identifier Type')         -- typescriptTypeReference
vim.cmd('hi Constant ctermfg=188')          -- const <Constant> = 100

vim.cmd('hi Conditional ctermfg=213')      -- if, switch, case ...
vim.cmd('hi! link Repeat Conditional')     -- for range
vim.cmd('hi! link Statement Conditional')  -- 默认 syntax 中 'package' & 'import' 关键字
vim.cmd('hi! link Include Conditional')    -- package, import ...

vim.cmd('hi! link Delimiter Normal')       -- 括号颜色, [] () {}
vim.cmd('hi! link Operator Normal')        -- = != == > < ...

--vim.cmd('hi Structure ctermfg=117')

vim.cmd('hi String ctermfg=173')         -- "abc"
vim.cmd('hi Character ctermfg=173')      -- 'a'
vim.cmd('hi Special ctermfg=75')         --  null (tsxTSConstBuiltin) | undefined (tsxTSVariableBuiltin)
vim.cmd('hi SpecialChar ctermfg=117')    -- \n \t \" ... escape string
vim.cmd('hi Number ctermfg=43')          -- 100, int, uint ...
vim.cmd('hi Boolean ctermfg=75')         -- true / false
vim.cmd('hi PreProc ctermfg=75')         -- tsxTSVariableBuiltin, tsxTSConstBuiltin ...
vim.cmd('hi! link Float Number')         -- 10.02 float64, float32

--- diff 颜色 --------------------------------------------------------------------------------------
vim.cmd('hi DiffAdd ctermfg=188 ctermbg=22')
vim.cmd('hi DiffDelete ctermfg=188 ctermbg=52')
vim.cmd('hi DiffChange cterm=None ctermfg=188')
vim.cmd('hi DiffText cterm=None ctermfg=188 ctermbg=160')

-- diff mode 模式下 CursorLine 样式
vim.cmd [[
  if &diff
    hi CursorLine cterm=underline
  endif
]]

--- 其他常用颜色 -----------------------------------------------------------------------------------
vim.cmd('hi Title cterm=bold ctermfg=114')      -- markdown Title
vim.cmd('hi Conceal ctermfg=117 ctermbg=None')  -- markdown 特殊符号颜色
vim.cmd('hi Label ctermfg=117')                 -- json key color

--- diagnostics 颜色设置 ---------------------------------------------------------------------------
--- DiagnosticInfo - lua global function name begin with lower-case.
--- DiagnosticHint - lua function not used.

--- diagnostics popup/floating window text color.
vim.cmd('hi DiagnosticError ctermfg=167')
vim.cmd('hi DiagnosticWarn ctermfg=215')
vim.cmd('hi DiagnosticInfo ctermfg=75')
vim.cmd('hi DiagnosticHint ctermfg=246')

--- diagnostics sign, 默认和 diagnostics text 颜色一样
--vim.cmd('hi DiagnosticSignError ctermfg=167')
--vim.cmd('hi DiagnosticSignWarn ctermfg=215')
--vim.cmd('hi DiagnosticSignInfo ctermfg=75')
vim.cmd('hi DiagnosticSignHint ctermfg=244')

--- diagnostics error 'source code' color.
vim.cmd('hi DiagnosticUnderlineError cterm=bold,underline ctermfg=167')
--vim.cmd('hi DiagnosticUnderlineWarn cterm=bold,underline ctermfg=167')
--vim.cmd('hi DiagnosticUnderlineInfo ctermfg=75')
vim.cmd('hi DiagnosticUnderlineHint ctermfg=244')

--- LSP 相关颜色 ----------------------------------------------------------------------------------
--- vim.lsp.buf.document_highlight() 颜色, 类似 Same_ID ---
vim.cmd('hi LspReferenceText ctermbg=238')
vim.cmd('hi LspReferenceRead ctermbg=238')
vim.cmd('hi LspReferenceWrite ctermbg=238')

--- treesitter 颜色 --------------------------------------------------------------------------------
--- treesitter global 颜色设置
vim.cmd('hi! link TSField Normal')               -- golang struct field
vim.cmd('hi! link TSParameter Normal')           -- 入参出参
vim.cmd('hi! link TSKeywordReturn Conditional')  -- return
vim.cmd('hi! link TSNamespace Normal')           -- package <Namespace>
vim.cmd('hi! link TSFuncBuiltin Function')       -- new() make() copy() ...
vim.cmd('hi! link TSFunction Function')
vim.cmd('hi! link TSMethod Function')

--- markdown
vim.cmd('hi markdown_inlineTSStrong ctermbg=238')  -- `code`
vim.cmd('hi markdownTSPunctSpecial ctermfg=246')   -- `- * #`

--- for typescript, html
vim.cmd('hi! link TSConstructor Normal')  -- import <TSConstructor> from 'react'
vim.cmd('hi TSProperty ctermfg=117')      -- like TSField in golang

--- set vim-syntax color to match treesitter color
vim.cmd('hi! link typescriptMember TSProperty')
vim.cmd('hi! link typescriptInterfaceName TSType')
vim.cmd('hi! link typescriptExport TSKeyword')

--- <div></div>
vim.cmd('hi TSTag ctermfg=74')             -- <div></div>, html 内置标签文字颜色 div
vim.cmd('hi TSTagDelimiter ctermfg=243')   -- <div></div>, <> 括号颜色
vim.cmd('hi! link TSTagAttribute TSProperty')  -- <... width=..., height=... >



