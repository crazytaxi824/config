-- 全局 color 设置
-- ctermfg/ctermbg 0-15 xterm 颜色(alacritty, ghostty 中设置的颜色)
-- NOTE ------------------------------------------------------------------------------------------- {{{
-- 注意: 自定义 color 放在最后，用来 override 之前插件定义的颜色.
--   ':hi'                查看所有 color scheme
--   'ctermfg, ctermbg'   表示 color terminal (256 色)
--   'termfg, termbg'     表示 16 色 terminal
--   'term, cterm'        表示样式, underline, bold, italic ...
--
-- NOTE: 只有 ':hi[!] link' 才有 [!] 设置.
-- 如果是 ':hi <group>' 只会覆盖对应的 kv 颜色值.
-- eg: 'hi Foo cterm=bold ctermfg=201 ctermbg=233'
--     'hi Foo ctermfg=191'
--     最终结果为 'hi Foo cterm=bold ctermfg=191 ctermbg=233'
--
-- 颜色设置 cmd
--   ':hi <group> ctermfg...'           Set color
--   ':hi clear <group>'                Reset to default color. 如果没有 default color, 则结果为 {group} xxx cleared
--   ':hi! link <group> NONE'           VVI: 将颜色设为 NONE. 直接忽略 default color, 将颜色设置为 {group} xxx cleared
--   ':hi link <group1> <group2>'       将 <group1> 的颜色设置为 <group2> 的颜色.
--                                      如果 <group2> 颜色变化, <group1> 颜色也会随之变化.
--   ':hi! link <group1> <group2>'      相当于 ':hi clear <group>' && ':hi link <group1> <group2>'
--   ':hi default link <group1> <group2>'    将 <group1> default 颜色设置为 <group2> 的颜色.
--   ':hi! default link <group1> <group2>'   相当于 ':hi clear <group>' && ':hi default link <group1> <group2>'
--
-- NOTE: lua 设置颜色: `:help nvim_set_hl()`, nvim v0.7+
-- vim.api.nvim_set_hl(namespace, hl_group_name, {val})
--   namespace = 0 表示全局设置.
--   {val} 中 nocombine: boolean
--   {val} 中使用 cterm = {bold=true, underline=true, ...} 也可以不使用 cterm.
--
-- eg:
--   vim.api.nvim_set_hl(0, "Foo", {ctermfg=123, ctermbg=234, cterm={bold=true, nocombine=true}})
--   vim.api.nvim_set_hl(0, "Foo", {link="Normal"})
--   vim.api.nvim_set_hl(0, 'Visual', {})  NOTE: clear the highlight group.
--
--   nvim_create_namespace({name}), namespace are used for buffer highlights.
--   nvim_buf_add_highlight(), 有点类似 matchaddpos() 但是不是完全一样.
--
-- }}}

-- VVI: colorscheme 必须在 自定义 highlights 之前设置.
vim.cmd.colorscheme({ args = { 'default' }})

-- highlight api 设置: vim.api.nvim_set_hl(0, '@property', { ctermfg = 81 })
---@type table<string, vim.api.keyset.highlight>
Highlights = {}
-- editor ------------------------------------------------------------------------------------------
-- window background color
Highlights.Normal = { ctermfg=Colors.white.c, fg=Colors.white.g }
-- non-focus window background color
Highlights.NormalNC = { link="Normal" }
-- Visual mode seleced text color
Highlights.Visual = { ctermbg=24, bg='#264F78' }

-- VVI: Pmenu & FloatBorder 背景色需要设置为相同, 影响很多窗口的颜色.
-- Completion Menu & Floating Window 颜色
Highlights.Pmenu = { ctermbg=Colors.g235.c, bg=Colors.g235.g }
-- Completion Menu 选中的 item 的颜色
Highlights.PmenuSel = {
  ctermbg=Colors.g238.c, bg='#04395E',
  bold=true,
}
-- Completion Menu scroll bar 背景色, bg 一般和 Pmenu bg 相同
Highlights.PmenuSbar = { link = "Pmenu" }
-- Completion Menu scroll bar 滚动条颜色, bg 颜色是 scroll bar 的颜色
Highlights.PmenuThumb = { ctermbg=Colors.g240.c, bg=Colors.g240.g }
-- NormalFloat 默认 link to Pmenu
Highlights.NormalFloat = { link="Pmenu" }
-- Floating Window border fg 颜色需要和 Pmenu 的 bg 颜色相同. border = {"▄","▄","▄","█","▀","▀","▀","█"}
Highlights.FloatBorder = { ctermfg=Highlights.Pmenu.ctermbg, fg=Highlights.Pmenu.bg }

-- Command Mode 自动补全 Completion 选中的 item 颜色
Highlights.WildMenu = {
  ctermfg=Colors.black.c, fg=Colors.black.g,
  ctermbg=Colors.blue_info.c,  bg=Colors.blue_info.g,
  bold=true,
}

-- 注释颜色
Highlights.Comment = { ctermfg=65, fg='#6A9955' }
-- 影响 listchars indentLine 颜色
Highlights.NonText = { ctermfg=Colors.g238.c, fg=Colors.g238.g }  -- "eol", "extends", "precedes"
Highlights.SpecialKey = { link = "NonText" }  -- "nbsp", "tab" and "trail"
-- window 之间的分隔线颜色
Highlights.WinSeparator = { ctermfg=Colors.g240.c, fg=Colors.g240.g }
Highlights.VertSplit = { link = 'WinSeparator' }
-- 括号匹配颜色
Highlights.MatchParen = {
  ctermfg=Colors.yellow.c, fg=Colors.yellow.g,
  bold=true, underline=true,
}
-- url, filepath 样式
Highlights.Underlined = { underline=true }

-- 行号颜色
Highlights.LineNr = { ctermfg=Colors.g240.c, fg=Colors.g240.g }
-- 光标所在行颜色
Highlights.CursorLine = { ctermbg=Colors.g236.c, bg=Colors.g236.g }
-- 光标所在行号的颜色
Highlights.CursorLineNr = {
  ctermfg=Colors.yellow.c, fg=Colors.yellow.g,
  bold=true,
}
-- 相当于 hi clear SignColumn, 默认有 bg 颜色.
Highlights.SignColumn = {}
-- textwidth column 颜色
Highlights.ColorColumn = { ctermbg=Colors.g234.c, bg=Colors.g234.g }
-- Quick Fix 选中行颜色
Highlights.QuickFixLine = {
  ctermfg=Colors.blue_boolean.c, fg=Colors.blue_boolean.g,
  bold=true,
}

-- / ? 搜索颜色
Highlights.IncSearch = {
  ctermfg=Colors.black.c,   fg=Colors.black.g,
  ctermbg=Colors.magenta.c, bg=Colors.magenta.g,
  bold=true,
}
Highlights.CurSearch = { link = "IncSearch" }
-- / ? * # g* g# 搜索颜色
Highlights.Search = {
  ctermfg=Colors.black.c,  fg=Colors.black.g,
  ctermbg=Colors.yellow.c, bg=Colors.yellow.g,
}

-- echoerr 颜色
Highlights.ErrorMsg = {
  ctermfg=255, fg='#FFFFFF',
  ctermbg=Colors.red_error.c, bg=Colors.red_error.g,
}
-- echohl WarningMsg | echo "Don't panic!" | echohl None 颜色
Highlights.WarningMsg = {
  -- ctermfg=Colors.black.c,  fg=Colors.black.g,
  ctermfg=Colors.orange_warn.c, fg=Colors.orange_warn.g,
}

-- TODO 颜色
Highlights.Todo = {
  ctermfg=255, fg='#FFFFFF',
  ctermbg=22, bg='#008F00',
}
-- NOTE 颜色
Highlights.SpecialComment = {
  ctermfg=255, fg='#FFFFFF',
  ctermbg=63,  bg='#5F5FFF',
}

-- for bufferline 在 nvim-tree 显示 "File Explorer"
Highlights.Directory = {
  ctermfg=Colors.cyan.c, fg=Colors.cyan.g,
  bold=true,
}

-- code 颜色 ---------------------------------------------------------------------------------------
-- VVI: 最主要的颜色
Highlights.Keyword = { ctermfg=Colors.magenta_keywd.c, fg=Colors.magenta_keywd.g }
Highlights.Statement = { link = "Keyword" }  -- syntax 中 'package' & 'import' 关键字
-- func <Function> {} 定义 & call func 都使用该颜色
Highlights.Function = { ctermfg=Colors.gold_fn.c, fg=Colors.gold_fn.g }
-- type <Type> struct
Highlights.Type = { ctermfg=Colors.green_type.c, fg=Colors.green_type.g }
--Highlights.Structure = { link = "Type" }  -- 默认 link to Type

Highlights.String = { ctermfg=173, fg='#CE9178' }
Highlights.Character = { link = "String" }

Highlights.Number = { ctermfg=151, fg='#B5CEA8' }  -- 100, int, uint ...
Highlights.Float  = { link = "Number" }  -- 10.02 float64, float32

-- true / false
Highlights.Boolean = { ctermfg=Colors.blue_boolean.c, fg=Colors.blue_boolean.g }
-- 常量颜色. eg: const <Constant> = "foo"
Highlights.Constant= { link = "Boolean" }
-- variable, property, parameter
Highlights.Identifier = { ctermfg=Colors.cyan.c, fg=Colors.cyan.g }

Highlights.Special = { ctermfg=Colors.blue_special.c, fg=Colors.blue_special.g }  -- console.log(`${ ... }`)
Highlights.SpecialChar = { ctermfg=180, fg='#D7BA7D' }  -- format verbs %v %d \n \t...
Highlights.PreProc = { link = "Keyword" }  -- package, import

Highlights.Delimiter = { link = "Normal" }  -- 符号颜色, [] () {} ; : ...
Highlights.Operator  = { link = "Normal" }  -- = != == > < ...

-- diagnostics 颜色设置 ----------------------------------------------------------------------------
-- NOTE:
-- DiagnosticXXX 主要设置.
-- DiagnosticFloatingXXX - floating window 中显示 error message 的颜色.
-- DiagnosticSignXXX     - SignColumn 中显示的颜色.
-- DiagnosticVirtualText - virtual_text 显示的颜色.
-- DiagnosticUnderlineXXX - code 中显示错误的位置.
-- 以上 highlight 默认 link to DiagnosticXXX.
Highlights.DiagnosticOk    = { ctermfg=Colors.green_ok.c, fg=Colors.green_ok.g }
Highlights.DiagnosticHint  = { ctermfg=Colors.grey_hint.c, fg=Colors.grey_hint.g }
Highlights.DiagnosticInfo  = { ctermfg=Colors.blue_info.c, fg=Colors.blue_info.g }
Highlights.DiagnosticWarn  = { ctermfg=Colors.orange_warn.c, fg=Colors.orange_warn.g }
Highlights.DiagnosticError = { ctermfg=Colors.red_error.c, fg=Colors.red_error.g }

-- NOTE: `:help undercurl` sp(guisp) color 改变 undercurl, underline, underdashed ... 颜色.
Highlights.DiagnosticUnderlineOk = {
  -- ctermfg=Colors.green.c, fg=Colors.green.g,
  sp=Colors.green_ok.g, underline=true,
}
Highlights.DiagnosticUnderlineHint = {
  -- ctermfg=Colors.hint_grey.c, fg=Colors.hint_grey.g,
  sp=Colors.grey_hint.g, undercurl=true,
}
Highlights.DiagnosticUnderlineInfo = {
  -- ctermfg=Colors.blue.c, fg=Colors.blue.g,
  sp=Colors.blue_info.g, undercurl=true,
}
Highlights.DiagnosticUnderlineWarn = {
  -- ctermfg=Colors.orange.c, fg=Colors.orange.g,
  sp=Colors.orange_warn.g, undercurl=true,
}
Highlights.DiagnosticUnderlineError = {
  ctermfg=Colors.red_error.c, fg=Colors.red_error.g,
  sp=Colors.red_error.g, undercurl=true, bold=true,
}

Highlights.DiagnosticUnnecessary = { link = "DiagnosticUnderlineHint" }
Highlights.DiagnosticDeprecated = { link = "DiagnosticUnderlineHint" }

-- LSP 相关颜色 ------------------------------------------------------------------------------------
-- vim.lsp.buf.document_highlight() 颜色, 类似 Same_ID
Highlights.LspReferenceText  = { ctermbg=Colors.g238.c, bg=Colors.g238.g }
Highlights.LspReferenceRead  = { link = 'LspReferenceText' }
Highlights.LspReferenceWrite = { link = 'LspReferenceText' }

-- diff 颜色 ---------------------------------------------------------------------------------------
Highlights.DiffAdd = {
  ctermfg=Colors.white.c, fg=Colors.white.g,
  ctermbg=Colors.green_ok.c, bg='#4C5B2D',
}
Highlights.DiffDelete = {
  ctermfg=Colors.white.c,
  ctermbg=52, bg=Colors.red_bg.g,
}
Highlights.DiffChange = {}  -- 有修改的一整行的文字的颜色, 设置 clear.
-- changed text
Highlights.DiffText = {
  ctermfg=Colors.black.c, fg=Colors.black.g,
  ctermbg=Colors.magenta.c, bg=Colors.magenta.g,
}

-- fold 颜色 ---------------------------------------------------------------------------------------
-- diff mode 下, 会自动设置:
-- `set foldcolumn=2`, 在 foldcolumn 显示在 SignColumn 前面.
-- `set foldmethod=diff`
Highlights.Folded = { ctermfg=67, fg='#5F87AF' } -- 折叠行文字颜色
Highlights.FoldColumn = { ctermfg=Colors.green_ok.c, fg=Colors.green_ok.g } -- foldcolumn 中 + - | 的颜色
Highlights.CursorLineFold = { link = "FoldColumn" }  -- cursor 所在行 foldcolumn 中 + - | 号颜色

-- 其他常用颜色 ------------------------------------------------------------------------------------
-- markdown title
Highlights.Title = {
  ctermfg=Colors.green_ok.c, fg=Colors.green_ok.g,
  bold=true,
}
-- json: key color; markdown: code block language(```go)
Highlights.Label = { ctermfg=Colors.cyan.c, fg=Colors.cyan.g }
-- `set conceallevel?`, markdown list, code block ...
Highlights.Conceal = { ctermfg=Colors.g246.c, fg=Colors.g246.g }

Highlights.SpellBad = {
  ctermfg=Colors.red_error.c, fg=Colors.red_error.g,
  ctermbg=52, bg='#890000',
  bold=true, strikethrough=true,
}
Highlights.SpellCap = {
  ctermfg=Colors.orange_warn.c, fg=Colors.orange_warn.g,
  ctermbg=52, bg='#890000',
  bold=true, strikethrough=true,
}
Highlights.SpellLocal = {}  -- clear highlight

-- treesitter 颜色设置 -----------------------------------------------------------------------------
-- NOTE: treesitter highlight 命名规则: @[type].[name].[filetype]
-- comment
Highlights['@comment.error'] = { link = 'ErrorMsg' }  -- FIXME, BUG, ERROR
Highlights['@comment.warning'] = { ctermfg=Highlights.WarningMsg.ctermfg, fg=Highlights.WarningMsg.fg, reverse = true }  -- HACK, WARN, WARNING, FIX
Highlights['@comment.note'] = { link = "SpecialComment" } -- NOTE, DOCS, TEST, INFO, XXX
Highlights['@comment.todo'] = { link = "Todo" }           -- TODO

-- VVI(omg): xxx
-- Highlights['@punctuation.delimiter.comment'] = { link = "@constant" }  -- :
-- Highlights['@punctuation.bracket.comment'] = { link = "@constant" }  -- ()

-- url: http://www.abc.com
Highlights['@string.special.url'] = { link = "Underlined" }  -- url

-- markdown | markdown_inline
-- # titles
Highlights["@markup.heading.1.markdown"] = { fg=Colors.green_ok.g, bold=true, underline=true }
Highlights["@markup.heading.2.markdown"] = { fg=Colors.yellow.g, bold=true, underline=true }
Highlights["@markup.heading.3.markdown"] = { fg=Colors.orange_warn.g, bold=true }
Highlights["@markup.heading.4.markdown"] = { fg=Colors.blue_info.g, bold=true }
Highlights["@markup.heading.5.markdown"] = { fg=Colors.magenta.g, bold=true }
Highlights["@markup.heading.6.markdown"] = { fg=Colors.purple.g, bold=true }

Highlights['@markup.strong'] = { bold = true } -- markdown, **bold**
Highlights['@markup.italic'] = { italic = true }  -- markdown, *italic*, _italic_
Highlights['@markup.underline'] = { underline = true }  -- markdown, <u>underline</u>
Highlights['@markup.strikethrough'] = { strikethrough = true }  -- markdown, ~~strike~~

-- markdown link: [@markup.link.label](@markup.link.url)
Highlights['@markup.link.markdown_inline'] = {}  -- markdown link ![xxx](xxx) 中的括号和感叹号颜色
Highlights['@markup.link.label'] = { underline = true, sp = Colors.g242.g } -- markdown, [@markup.link.label](@markup.link.url)
Highlights['@markup.link.url'] = { fg=Colors.cyan.g, underline = true } -- markdown, [@markup.link.label](@markup.link.url)
-- markdown, inline `code`
Highlights['@markup.raw.markdown_inline'] = {
  ctermfg=173, fg='#CE9178',  -- 和 String 颜色一样
  ctermbg=Colors.g236.c, bg=Colors.g236.g,
}

-- program language
Highlights['@type.builtin'] = { link = "@type" }
Highlights['@function.builtin'] = { link = "@function" }  -- copy() delete() make()

Highlights['@variable'] = { link = "Identifier" }
Highlights['@variable.builtin'] = { link = "@variable" }
Highlights['@constant.builtin'] = { link = "@constant" }  -- null | undefined

-- Highlights['@property'] = { link = "Identifier" }
Highlights['@property.private'] = { ctermfg=Colors.g246.c, fg=Colors.g246.g }  -- struct{ a:1 }
Highlights['@field'] = { link = "@property" }
Highlights['@parameter'] = { link = "@property" }

Highlights['@tag.javascript'] = { link = "@type.javascript" }  -- jsx/tsx custom tags, <BrowserRouter> <ThemeProvider> <Link> <Button> ...
-- Highlights['@tag.builtin.javascript']  -- <div> <button> <body> <p> <nav> ...
Highlights['@tag.delimiter'] = { ctermfg=Colors.g244.c, fg=Colors.g244.g }  -- html <tag> <> 括号颜色
Highlights['@tag.attribute'] = { link = "@property" }  -- html, <... width=..., @tag.attribute=... >

-- Highlights['@string.escape'] = { link="SpecialChar" }  -- printf "\n" "\t" ...

-- LSP semantic tokens -----------------------------------------------------------------------------
-- NOTE: `:help vim.hl.priorities`
Highlights['@lsp.type.comment'] = {}  -- clear highlight in order to use treesitter highlight.
Highlights['@lsp.mod.readonly'] = { link = "Constant" }  -- readonly = constant
Highlights['@lsp.mod.format'] = { link = "Boolean" }  -- fmt "%s" "%v" "%d" ...

-- NOTE: 以下设置是为了配合 lazy load plugins ------------------------------------------------------
-- 以下颜色为了 lazy load lualine
-- 无法使用 lualine 的情况下 StatusLine 颜色, eg: tagbar 有自己设置的 ':set statusline?' 颜色不受 lualine 控制.
-- active
Highlights.StatusLine = {
  ctermfg=Colors.gold_fn.c, fg=Colors.gold_fn.g,
  ctermbg=Colors.black.c, bg=Colors.black.g,
}
-- inactive, NC (not-current windows)
Highlights.StatusLineNC = {
  ctermfg=Colors.g246.c, fg=Colors.g246.g,
  ctermbg=Colors.black.c, bg=Colors.black.g,
}

-- 以下颜色为了 lazy load bufferline
Highlights.TabLineFill = {} -- NOTE: clear highlight
Highlights.TabLineSel = {
  ctermfg=Colors.gold_fn.c, fg=Colors.gold_fn.g,
  ctermbg=Colors.black.c, bg=Colors.black.g,
  bold=true,
}
--Highlights.TabLine = {ctermfg = 234}

-- clear WinBar
Highlights.WinBar = {}
Highlights.WinBarNC = {}

-- 设置 syntax 颜色是为了让 treesitter lazy render 的时候不至于颜色差距太大.
-- set vim-syntax color to match treesitter color
Highlights.typescriptInterfaceName = { link = 'Type' }
Highlights.typescriptMember = { link = '@property' }
Highlights.typescriptExport = { link = 'Keyword' }
Highlights.typescriptImport = { link = 'Conditional' }

-- nvim_set_hl()
for hl_group, hl_val in pairs(Highlights) do
  vim.api.nvim_set_hl(0, hl_group, hl_val)
end

-- debug -------------------------------------------------------------------------------------------

-- 返回使用 color name 的 Highlight Groups
---@param color_name string  name of color: "blue"|"red"|"magenta"...
__Debug.ColorGetHighlights = function(color_name)
  local match_names = {}
  for name, _ in pairs(Colors) do
    if name:match(color_name) then
      table.insert(match_names, name)
    end
  end

  if vim.tbl_isempty(match_names) then
    return
  end

  for _, c_name in ipairs(match_names) do
    local color = Colors[c_name]

    for hl_name, hl_val in pairs(Highlights) do
      if hl_val.ctermfg == color.c or hl_val.fg == color.g or hl_val.foreground == color.g then
        vim.notify(string.format("%s : { fg = %s }", hl_name, c_name), vim.log.levels.INFO)
      elseif hl_val.ctermbg == color.c or hl_val.bg == color.g or hl_val.background == color.g then
        vim.notify(string.format("%s : { bg = %s }", hl_name, c_name), vim.log.levels.INFO)
      end
    end
  end
end


vim.api.nvim_create_user_command("DebugColorGetHighlights", function(params)
  -- params.args: string
  -- params.fargs: string[]
  __Debug.ColorGetHighlights(params.args)
end,
{
  nargs = 1,
  bang = true,
  bar = true,
  desc = 'get highlight groups that using color_name',
  complete = function()
    return vim.tbl_keys(Colors)
  end,
})



