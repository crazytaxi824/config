vim.g.tagbar_autofocus = 1        -- 打开 tagbar 的时候光标自动跳到窗口
vim.g.tagbar_sort = 0             -- tagbar 按照函数顺序排序, 使用 's' 切换 sort 方法.
vim.g.tagbar_autoclose = 1        -- enter 选择后自动关闭 tagbar
vim.g.tagbar_show_tag_count = 1   -- 显示 tag 数量, eg; functions (5)
vim.g.tagbar_autoshowtag = 2      -- 打开 tagbar 时, 不要打开 folded tag, 例如: imports
vim.g.tagbar_position = "vertical botright"        -- tagbar 打开位置.
--vim.g.tagbar_width = max([25, winwidth(0) / 5])  -- tagbar 窗口大小, 默认40

--- VVI: 注意这里不要改, 会影响 TagbarHightligh 显示.
vim.g.tagbar_visibility_symbols = {
  public    = ' +',
  protected = ' #',
  private   = ' -',
}

--- ignore files && filetype
--vim.cmd('autocmd BufNewFile,BufReadPost NvimTree_* let b:tagbar_ignore = 1')  -- ignore
--vim.cmd('autocmd FileType NvimTree let b:tagbar_ignore = 1')

--- 这里是专为 go 设置的 kinds --------------------------------------------------------------------- {{{
--- VVI: `:TagbarGetTypeConfig go` - 将打印下面的 kinds 设置到文件中, 可根据需求修改.
--- `:help tagbar-extend`, {short}:{long}[:{fold}[:{stl}]], 其中 {fold} 和 {stl} 可以省略, 默认值为0.
--- {fold}: 1 - 默认折叠, 0 - 默认打开, 和 `g:tagbar_autoshowtag` 配合使用.
--- {stl} 可以不用设置.
-- let g:tagbar_type_go = {
--     \ 'kinds' : [
--         \ 'p:package:0:0',
--         \ 'i:imports:1:0',
--         \ 'c:constants:0:0',
--         \ 'v:variables:0:0',
--         \ 't:types:0:0',
--         \ 'n:intefaces:0:0',
--         \ 'w:fields:0:0',
--         \ 'e:embedded:0:0',
--         \ 'm:methods:0:0',
--         \ 'r:constructors:0:0',
--         \ 'f:functions:0:0',
--         \ '?:unknown',
--     \ ],
-- \ }
-- -- }}}

--- Tagbar 颜色 ------------------------------------------------------------------------------------
vim.cmd [[ hi! link TagbarKind Keyword ]]  -- tag group name, "imports", "functions", "variables"
vim.cmd [[ hi TagbarNestedKind ctermfg=75 ]]  -- 内部颜色 [fields] [methods]
vim.cmd [[ hi! link TagbarScope Type ]]  -- class, struct Name
vim.cmd [[ hi! link TagbarType Type ]]  -- Keyword "struct", "string",
vim.cmd [[ hi TagbarSignature ctermfg=220 ]]  -- function signature "(...)"

--- keymaps ----------------------------------------------------------------------------------------
vim.keymap.set('n', '<leader>.', ':TagbarToggle<CR>', { noremap = true, silent = true })



