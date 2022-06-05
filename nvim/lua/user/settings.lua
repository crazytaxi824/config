--- https://github.com/LunarVim/Neovim-from-scratch/blob/master/lua/user/options.lua
--- [ 注意事项 ] ------------------------------------------------------------------------------------ {{{
-- `:set` in lua, 系统变量
--      lua            command      global_value       local_value ~
--    vim.o           :set                set                set
--    vim.bo/vim.wo   :setlocal            -                 set
--    vim.go          :setglobal          set                 -

-- NOTE: vim.o & vim.opt 区别:
--    vim.opt.shortmess:append('F') 可以表示 :set shortmess+=F
--    而 vim.o 没办法做到.
--    `:lua print(vim.o.readonly)` = bool
--    `:lua print(vim.opt.readonly)` = table
--    `:lua print(vim.inspect(vim.opt.readonly))` print table

-- vim lua 自定义变量
--    vim.g.foo = let g:foo   -- global variables
--    vim.b.foo = let b:foo   -- buffer variables

-- neovim 中 vimscript 和 lua 互相调用变量.
--  eg1:
--    `:lua vim.g.foo = "omg"`
--    `:echo g:foo`
--  eg2:
--    `:let g:bar="bar" | lua print(vim.g.bar)`

-- NOTE: neovim 7.0 新 api, 也可以直接使用 vim.cmd() 执行 vim command
-- `autocmd` in lua -> `vim.api.nvim_create_autocmd("BufEnter", {pattern, buffer=0, command/callback})`.
-- `command` in lua -> `vim.api.nvim_create_user_command()`, `vim.api.nvim_buf_create_user_command()`
--    vim.cmd('echo "omg"')       -- 单行 cmd
--    vim.cmd([[ autocmd ... ]])  -- 多行 cmd
--    vim.cmd('execute "normal! j"')   -- execute "normal! j"

-- vim lua function - local, 类似 function! s:foo() ...
--    local foo = function(a, b)
--        print("A is:", a)
--        print("B is:", b)
--    end

-- vim lua function - global, 类似 function! Foo() ..., lua 中 global function 可以小写开头.
--    foo = function(a, b)
--        print("A is:", a)
--        print("B is:", b)
--    end

-- call lua global function in neovim.
--    `:lua print("foo")`
--    `:lua foo("a", "b")`
--
-- call vim 自带 function in lua. eg: `:help expand()`
--    `:lua print(vim.fn.expand("%:p"))`

-- lua buildin functions
--    vim.api.nvim_command()  -- 执行 vim command.
--    vim.api.nvim_call_function()  -- call vim script function.
--    vim.api.nvim_exec(), vim.cmd()

-- }}}

--- 以下都是默认设置
--vim.opt.compatible = false
--vim.opt.encoding = 'utf-8'
--vim.opt.fileencoding = 'utf-8'

--vim.g.mapleader = '\\'
vim.opt.mouse = 'a'  -- allow the mouse to be used in neovim, `:help mouse`

--- tabstop / shiftwidth - prettier indent 设置 ---------------------------------------------------- {{{
--- VVI: 以下设置不要随便改动, 需要配合 vscode & prettier & .editorconfig 一起改动.
vim.opt.expandtab = false  -- set noexpandtab 设置: 当1个或者多个 softtabstop 长度等于 tabstop 的时候会被转成 \t;
                           -- 当 softtabstop=4, tabstop=4, 则 <Tab> 键是 \t. backspace 删除 \t;
                           -- 当 softtabstop=2, tabstop=4, 则第一个 <Tab> 是两个空格, 连续两个 <Tab> 会变成 \t;
                           -- 每个 backspace 删除1个 softtabstop, 即2个空格.

vim.opt.tabstop = 4      -- \t 缩进宽度. vscode 中的 editor.tabSize 设置, .editorconfig 中 tab_width 设置.
                         -- 只作为编辑器显示 \t 宽度用.

vim.opt.softtabstop = 4  -- <Tab> / <BackSpace> 键宽度. 默认值不开启, 这时候 <Tab> 键就是 tabstop 的宽度;
                         -- 但是 <BackSpace> 就只能删除 1 个字符.

vim.opt.shiftwidth = 4   -- shift 缩进宽度, <Shift-,> / <Shift-.>
                         -- 在 let g:prettier#config#tab_width='auto' 时影响 prettier indent 的宽度.
                         -- 在 let g:prettier#config#tab_width=2 时不影响 prettier.
                         -- 同时影响 indentLine 画线的宽度.

vim.opt.wrap = false     -- 单行文字是否可以超出屏幕.
                         -- nowrap - 单行可以超出屏幕, 不换行;
                         -- wrap(默认) - 超出屏幕则(软)换行. 即行号不变, 文字在下一行显示.

vim.opt.textwidth = 120  -- 文字自动(硬)换行长度. 即文字写在下一行(增加行号).
                         -- 这里的设置和 golangci-lint lll 长度一样.
                         -- 默认值 78;
                         -- 设置为 0 则不换行, 文字可以超出屏幕.

--vim.opt.formatoptions='tcq'   -- `:help fo-table` 自动(硬)换行 breakline 的 options. 一般情况下只会 break Comments.
                                -- 常用 options: `tcq`(默认), `cq`(go,json...), `croql`(vim,ts,js...)

-- prettier 支持的文件, 默认都是使用 2 个 space 来 indent.
--   单独设置文件 shiftwidth 宽度, 在 let g:prettier#config#tab_width='auto' 时影响 prettier indent 的宽度.
--   同时影响 indentLine 画线的宽度.
vim.cmd [[
  au Filetype json,jsonc,javascript,javascriptreact,typescript,typescriptreact,
    \vue,svelte,html,css,less,scss,graphql,yaml,lua
    \ setlocal expandtab softtabstop=2 shiftwidth=2
]]

-- pandoc / markdown 需要使用到 \t 和 space, 所以这里不设置 expandtab.
vim.cmd [[au Filetype pandoc,markdown setlocal shiftwidth=2]]

-- python 默认是 4 个 space indent. 所以这里不设置 shiftwidth.
vim.cmd [[au Filetype python setlocal expandtab textwidth=79]]

-- }}}

--- [XXX] 这两个设置和 filetype on 冲突. 不要手动设置 filetype on.
---       如果必须设置 filetype on, 则下面两个设置必须放在 filetype on 前面.
vim.g.did_load_filetypes = 0  -- 0 - 关闭 vim 内置 filetype 检查; 1(*) - 关闭 vim & lua filetype 检查.
vim.g.do_filetype_lua = 1     -- 读取 runtimepath/filetype.lua 中定义的 filetype mapping.
-- `:help :filetype on`, Detail: The ":filetype on" command will load these files:
--    $VIMRUNTIME/filetype.lua
--    $VIMRUNTIME/filetype.vim
--vim.cmd('filetype on')   -- VVI: 默认开启, 不要手动设置.
--vim.cmd('syntax on')     -- 开启 vim 内置语法高亮. NOTE: 这里我们使用 treesitter, 所以不需要 syntax on.

vim.opt.timeoutlen = 600   -- 组合键延迟时间, 默认1000ms. eg: <leader>w, <C-W><C-O>...
vim.opt.ttimeoutlen = 0    -- <ESC> 延迟时间, 默认 50ms.  <ESC> 的主要作用是切换模式.
                           -- <ESC> 是发送 ^[ 相当于是 <C-[> 组合键.
                           -- ttimeoutlen>0 的情况下, 其他模式转成 normal 模式需要 <ESC><ESC> 两次, 或者等待延迟结束;
                           -- ttimeoutlen=0 的情况下, 其他模式转成 normal 模式只需要 <ESC> 一次.
                           -- ttimeoutlen>0 的情况下, 从 insert 直接转成 visual 需要 <ESC>v, 中间不需要经过 normal 模式;
                           -- ttimeoutlen=0 的情况下, 模式转换时肯定会经过 normal. 因为按下 <ESC> 时马上就会转成 normal 模式.

-- 功能设置, 以下都是默认值
vim.opt.backspace = 'indent,eol,start'  -- 设置 backspace 模式.
vim.opt.history = 10000    -- command 保存的数量，默认(10000)
vim.opt.autoindent = true  -- 继承前一行的缩进方式，适用于多行注释
vim.opt.autowrite = true   -- 可以自动保存 buffer，例如在 buffer 切换的时候.
vim.opt.updatetime = 300   -- faster completion (4000ms default)
vim.opt.wildmenu = true    -- Command 模式下 <Tab> completion. `:help wildmenu` - enhanced mode of command-line completion.
vim.opt.wildmode = "full"  -- Complete the next full match.
vim.opt.wildoptions = ""   -- default "pum,tagfile", pum - popupmenu | tagfile - <C-d> list matches
vim.opt.wildignorecase = true  -- command 自动补全时忽略大小写.
vim.opt.foldenable = true  -- 折叠代码.
vim.opt.hidden = true      -- NOTE: When off a buffer is unloaded when it is abandoned.
                           -- vim-airline & coc.nvim 需要用到.

-- window / scroll 设置
vim.opt.splitbelow = true  -- force all horizontal splits to go below current window
vim.opt.splitright = true  -- force all vertical splits to go to the right of current window
vim.opt.scrolloff = 2      -- 没有到达文件顶部/底部时, 光标留空 n 行. 同时会影响 H / L 键行为.
vim.opt.sidescrolloff = 16 -- 超长行横向留空 n 列.

-- search 设置，命令 `/` `?`
vim.opt.incsearch = true   -- 开始实时搜索
vim.opt.ignorecase = true  -- 大小写不敏感. 大小写敏感使用 `/Foo\C`; 不敏感用 /Foo\c
vim.opt.smartcase = true   -- 如果 search 文字中有大写字母则 case sensitive; 如果没有大写字母则 ignorecase.
vim.opt.hlsearch = true    -- / ? 搜索时显示所有匹配项. 颜色设置 `hi Search` & `hi IncSearch`

-- 样式设置
--vim.opt.showtabline = 2    -- always show tabs

vim.opt.number = true        -- 设置行号
--vim.opt.numberwidth = 4    -- 默认行号占 4 列

vim.opt.cursorline = true    -- 突出显示当前行. 包括: 行号, 背景色, 下划线...
--vim.opt.cursorlineopt = "number"  -- cursorline 只突出行号, 没有背景色, 下划线...
--vim.opt.cursorcolumn = true       -- 突出显示当前列. 包括: 背景色...

vim.opt.signcolumn = 'yes:1'  -- 始终显示 signcolumn. line_number 左边用来标记错误, 打断点的位置. 术语 gutter.
                              -- '1' 表示 signcolumn 宽度. 宽度为 1*2=2 格; 如果设置为 2, 则宽度为 2*2=4 格.
vim.opt.showmatch = true      -- 跳到匹配的括号上, 包括 () {} []
vim.opt.cmdheight = 2         -- 底部状态栏高度, more space.

-- 只在超出 textwidth 的行中显示 ColorColumn. 可以替代 `set colorcolumn`
vim.cmd [[ au BufEnter * call matchadd('ColorColumn', '\%' .. (&textwidth+1) .. 'v', 100) ]]
--vim.opt.colorcolumn = '+1'  -- :set cc=+1  " highlight column after 'textwidth'
                              -- :set cc=+1,+2,+3  " highlight three columns after 'textwidth'

vim.opt.completeopt = { "menu", "menuone", "noselect" }    -- 为代码补全设置, mostly just for cmp

-- `:help backup-table`, 四种设置情况.
-- 禁用 backup 功能.
vim.opt.backup = false
--vim.opt.writebackup = false

-- 允许使用 swp 缓存文件.
vim.opt.swapfile = true

-- undo history 持久化
vim.cmd [[au Filetype * ++once !mkdir -p /tmp/nvim/undo]]  -- VVI: ++once 只在进入 neovim 时执行一次 mkdir
vim.opt.undofile = true
vim.opt.undodir = "/tmp/nvim/undo"
vim.opt.undolevels = 5000

-- status line 设置，vim 最底部状栏
vim.opt.showmode = false  -- 不显示模式, alirline 显示.
vim.opt.showcmd = true    -- 显示键入的快捷键, 不是 command. 默认 `set noshowcmd`
--vim.opt.shortmess:append('c')   -- :set shortmess+=c
--vim.opt.laststatus=0            -- 0-不显示(默认), 1-窗口数量>1时显示, 2-总是显示

-- 换行符, space, tab, cr ... 显示设置. `:help listchars`
--   eol:↴ - 换行
--   lead/trail - 行首(尾)的空格
--   precedes/extends - 不换行(:set nowrap)的情况下, 内容长度超出屏幕的行会有该标记
vim.opt.list = true
vim.opt.listchars = 'tab:│ ,lead: ,trail:·,extends:→,precedes:←,nbsp:⎵'

-- 填充符, `:help fillchars`
--   diff  - vimdiff 中被删除的行的填充字符.
--   fold  - 折叠代码的行的填充字符.
--   vert  - 竖着并排窗口的分隔符. eg: tagbar, nerdtree ...
--   stl   - statusline 中间的填充字符.
--   stlnc - non-current window 的 statusline 中间的填充字符.
--   eob   - 文件最后一行之后, 空白行的行号.
vim.opt.fillchars = 'fold: ,diff: ,vert:│,eob:~'

-- `:h foldtext` 改变折叠代码的样式. 配合 fillchars 使用.
vim.opt.foldtext = 'printf("%s …", getline(v:foldstart))'

-- 让 quickfix window 始终显示在屏幕最下方, 相当于命令 `:botright copen`
-- wincmd 快捷键是 <Ctrl-w>
vim.cmd [[au Filetype qf :wincmd J]]

-- markdown 文件自动执行 SpellCheck 命令
--vim.cmd [[au Filetype pandoc,markdown setlocal spell spelllang=en,cjk]]



