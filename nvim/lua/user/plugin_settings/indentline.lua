--- NOTE: indent line 和 set list & set listchars 配合使用.

--- Use a protected call so we don't error out on first use
local status_ok, indent_blankline = pcall(require, "indent_blankline")
if not status_ok then
  return
end

--- set list & set listchars, NOTE: 在 settings.lua 中设置.
--vim.opt.list = true
--vim.opt.listchars:append("space:⋅")
--vim.opt.listchars:append("eol:↴")

indent_blankline.setup({
  enabled = true,
  use_treesitter = true,  -- NOTE: use treesitter when possible. 默认 false.
  --use_treesitter_scope = true,  -- VVI: 不要设置, 会导致 indentline 显示不如预期.

  indent_level = 10,  -- VVI: maximum indent level to display. 默认 10.
  max_indent_increase = 1,  -- 多行 trailing comments 不会出现 indentline, eg: settings.lua 中的 comments.

  bufname_exclude = {'README.md'},
  buftype_exclude = { "nofile", "quickfix", "help", "terminal", "prompt" },
  filetype_exclude = {
    "qf",  -- quickfix & location list
    "help",
    "packer",
    "NvimTree",
    "tagbar",
    "startify",
    "dashboard",
    "neogitstatus",
    "Trouble",
    "python",  -- python 不适合 indent line.
  },

  char = "│",  -- 默认 "▏" and "▎"

  show_trailing_blankline_indent = false,  -- VVI: ) } 后的空白行不再显示 indent line.
  show_first_indent_level = true,  -- 显示第一列的 indent line.
  --space_char_blankline = ' ',  -- indent line 之间的空白显示, 默认为空字符 ' '.
  --show_end_of_line = true,  -- 同时需要设置 vim.opt.listchars:append("eol:↴")

  --- BUG: indent line 颜色显示不正确.
  --- 以下设置需要安装 nvim-treesitter, 同时在每次 autocmd CursorMoved 时计算, 会影响速度.
  --show_current_context = true,  -- 显示 indentLine 颜色.
  --show_current_context_start = true,  -- 在 indentLine 起始行添加下划线.
  --show_current_context_start_on_current_line = true,  -- even when the cursor is on the same line.

  --- NOTE: 加载下面定义的颜色设置, too colorful --- {{{
  --char_highlight_list = {
  -- "IndentBlanklineIndent1",
  -- "IndentBlanklineIndent2",
  -- "IndentBlanklineIndent3",
  -- "IndentBlanklineIndent4",
  -- "IndentBlanklineIndent5",
  -- "IndentBlanklineIndent6",
  --},
  -- -- }}}
})

--- 设置颜色 ---------------------------------------------------------------------------------------
vim.cmd [[hi IndentBlanklineIndent1 ctermfg=172]]
vim.cmd [[hi IndentBlanklineIndent2 ctermfg=25]]
vim.cmd [[hi IndentBlanklineIndent3 ctermfg=29]]
vim.cmd [[hi IndentBlanklineIndent4 ctermfg=128]]
vim.cmd [[hi IndentBlanklineIndent5 ctermfg=198]]
vim.cmd [[hi IndentBlanklineIndent6 ctermfg=105]]



