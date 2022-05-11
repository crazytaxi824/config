--- indent line 和 set list & set listchars 配合使用.

--- Use a protected call so we don't error out on first use
local status_ok, indent_blankline = pcall(require, "indent_blankline")
if not status_ok then
  return
end

vim.g.indent_blankline_buftype_exclude = { "terminal", "nofile" }
vim.g.indent_blankline_filetype_exclude = {
  "help",
  "startify",
  "dashboard",
  "packer",
  "neogitstatus",
  "NvimTree",
  "Trouble",
}
vim.g.indentLine_enabled = 1
vim.g.indent_blankline_char = "│"
--vim.g.indent_blankline_char = "▏"
--vim.g.indent_blankline_char = "▎"
vim.g.indent_blankline_show_trailing_blankline_indent = false
vim.g.indent_blankline_show_first_indent_level = true
vim.g.indent_blankline_use_treesitter = true
vim.g.indent_blankline_show_current_context = true

--- indent_blankline_context_patterns -------------------------------------------------------------- {{{
--vim.g.indent_blankline_context_patterns = {
--  "class",
--  "return",
--  "function",
--  "method",
--  "^if",
--  "^while",
--  "jsx_element",
--  "^for",
--  "^object",
--  "^table",
--  "block",
--  "arguments",
--  "if_statement",
--  "else_clause",
--  "jsx_element",
--  "jsx_self_closing_element",
--  "try_statement",
--  "catch_clause",
--  "import_statement",
--  "operation_type",
--}
--- }}}

--- HACK: work-around for https://github.com/lukas-reineke/indent-blankline.nvim/issues/59
--- vim.wo.colorcolumn = "99999"

--- set list & set listchars, NOTE: 在 settings.lua 中设置.
--vim.opt.list = true
--vim.opt.listchars:append("space:⋅")
--vim.opt.listchars:append("eol:↴")

indent_blankline.setup({
  --show_end_of_line = true,
  --space_char_blankline = " ",
  show_current_context = false,  -- 默认 true 显示 indentLine 颜色; 不建议开启, 有 bug.
  --show_current_context_start = true,

  --- NOTE: 加载下面定义的颜色设置 --- {{{
  char_highlight_list = {
   "IndentBlanklineIndent1",
   "IndentBlanklineIndent2",
   "IndentBlanklineIndent3",
   "IndentBlanklineIndent4",
   "IndentBlanklineIndent5",
   "IndentBlanklineIndent6",
  },
  --- }}}
})

--- 设置颜色 ---------------------------------------------------------------------------------------
vim.cmd [[highlight IndentBlanklineIndent1 ctermfg=172]]
vim.cmd [[highlight IndentBlanklineIndent2 ctermfg=25]]
vim.cmd [[highlight IndentBlanklineIndent3 ctermfg=29]]
vim.cmd [[highlight IndentBlanklineIndent4 ctermfg=128]]
vim.cmd [[highlight IndentBlanklineIndent5 ctermfg=198]]
vim.cmd [[highlight IndentBlanklineIndent6 ctermfg=105]]



