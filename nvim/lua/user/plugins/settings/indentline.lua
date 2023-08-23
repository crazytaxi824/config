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

--- `:help indent-blankline`
--- 设置参考 LunarVim: https://github.com/LunarVim/LunarVim/blob/master/lua/lvim/core/indentlines.lua
indent_blankline.setup({
  enabled = true,

  indent_level = 9,  -- VVI: maximum indent level to display. 默认 10.
  max_indent_increase = 1,  -- 多行 trailing comments 不会出现 indentline.
                            -- eg: settings.lua 中的 comments.

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
    --"python",  -- python 不适合 indent line.
  },

  char = "│",  -- "│", "┃" and "▏", "▎",
  context_char = '│',  -- 如果 "show_current_context = false" 则本设置无效.

  show_first_indent_level = true,  -- 显示第一列的 indent line.
  show_trailing_blankline_indent = false,  -- VVI: ) } 后的空白行不再显示 indent line.
  --space_char_blankline = ' ',  -- indent line 之间的空白显示, 默认为空字符 ' '.
  --show_end_of_line = true,  -- 同时需要设置 vim.opt.listchars:append("eol:↴")

  --- NOTE: 以下设置需要安装 nvim-treesitter. 在 "CursorMoved" 时计算, 会影响速度.
  --- NOTE: 当 cursor 在注释上的时候不会显示 indentLine 颜色.
  use_treesitter = true,  -- NOTE: use treesitter when possible. 默认 false.
  --use_treesitter_scope = true,  -- VVI: 不要设置, 会导致 indentline 显示不如预期.
  show_current_context = true,  -- NOTE: 显示当前同一个 context 内的 indentLine 颜色.
  --show_current_context_start = true,  -- 在 indentLine 起始行添加 Underline.
  --show_current_context_start_on_current_line = true,  -- even when the cursor is on the same line.

  --- NOTE: 加载下面定义的颜色设置, too colorful ------------------------------- {{{
  ---char_highlight_list = {
  --- "IndentBlanklineIndent1",
  --- "IndentBlanklineIndent2",
  --- "IndentBlanklineIndent3",
  --- "IndentBlanklineIndent4",
  --- "IndentBlanklineIndent5",
  --- "IndentBlanklineIndent6",
  ---},
  -- -- }}}
})

--- 设置颜色 `:help indent-blankline-highlights` ---------------------------------------------------
--vim.api.nvim_set_hl(0, 'IndentBlanklineChar', {link = 'NonText'})  -- indentLine 默认 link to 'NonText'.
vim.api.nvim_set_hl(0, 'IndentBlanklineContextChar', {ctermfg=242})  -- show_current_context color

--- char_highlight_list 颜色
vim.api.nvim_set_hl(0, 'IndentBlanklineIndent1', {ctermfg=172})
vim.api.nvim_set_hl(0, 'IndentBlanklineIndent2', {ctermfg=25})
vim.api.nvim_set_hl(0, 'IndentBlanklineIndent3', {ctermfg=29})
vim.api.nvim_set_hl(0, 'IndentBlanklineIndent4', {ctermfg=128})
vim.api.nvim_set_hl(0, 'IndentBlanklineIndent5', {ctermfg=198})
vim.api.nvim_set_hl(0, 'IndentBlanklineIndent6', {ctermfg=105})



