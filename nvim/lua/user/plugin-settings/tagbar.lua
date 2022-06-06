vim.g.tagbar_autofocus = 1        -- 打开 tagbar 的时候光标自动跳到窗口
vim.g.tagbar_sort = 0             -- tagbar 按照函数顺序排序, 使用 's' 切换 sort 方法.
vim.g.tagbar_autoclose = 1        -- enter 选择后自动关闭 tagbar
vim.g.tagbar_show_tag_count = 1   -- 显示 tag 数量, eg; functions (5)
vim.g.tagbar_autoshowtag = 2      -- 打开 tagbar 时, 不要打开 folded tag, 例如: imports
vim.g.tagbar_position = "vertical botright"         -- tagbar 打开位置.
--vim.g.tagbar_width = max([25, winwidth(0) / 5])  -- tagbar 窗口大小, 默认40

--- VVI: 注意这里不要改, 会影响 TagbarHightligh 显示.
vim.g.tagbar_visibility_symbols = {
  public    = ' +',
  protected = ' #',
  private   = ' -',
}

--- `:TagbarGetTypeConfig go` - print tagbar configuration for 'lang' at cursor
--- `:help tagbar-extend`, {short}:{long}[:{fold}[:{stl}]], 其中 {fold} 和 {stl} 可以省略, 默认值为0.
--- fold: 1 - 默认折叠, 0 - 默认打开. 和 `g:tagbar_autoshowtag` 配合使用.
--- 这里是专为 go 设置的. VVI: `$ ctags --list-kinds=go` 查看 kinds. {short} 对应名字不能错.
vim.g.tagbar_type_go = {
  kinds = {
    'p:package:1',
    'i:imports:1',
    'c:constants',
    'v:variables',
    't:types',
    's:structs',
    'n:intefaces',
    'w:fields',
    'e:embedded',
    'm:methods',
    'r:constructors',
    'f:functions',
    'u:unknown',
  },
}

--- Tagbar 颜色 ---
vim.cmd [[ hi link TagbarKind Keyword ]]  -- tag group name, "imports", "functions"
vim.cmd [[ hi link TagbarNestedKind Identifier ]]  -- 内部颜色 [fields]
vim.cmd [[ hi link TagbarScope Function ]]  -- class, struct name
vim.cmd [[ hi link TagbarType Type ]]
vim.cmd [[ hi link TagbarSignature Identifier ]]

