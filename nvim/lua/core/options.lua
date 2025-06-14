--- vim & neovim 设置
--- [ 注意事项 ] ----------------------------------------------------------------------------------- {{{
--- 三种 `set` 的使用场景:
---    - `:setglobal` 用于设置普遍的情况. `:setlocal` 用于设置特殊情况.
---    - `:setlocal` 如果有 `local to buffer/window` 设置, 则设置到 local 值上, 如果 option 没有 `local to buffer/window` 设置, 则设置在 global 上.
---    - `:set` 相当于 `:setglobal` & `:setlocal` 同时设置.
---
----------------------------------------------------------------------------------------------------
--- 三种 `set` 的设置区别, `:help :setglobal`
---            Command          global value      local value ~
---          :set option=value      set               set
---     :setlocal option=value       -                set
---    :setglobal option=value      set                -
---          :set option?            -               display
---     :setlocal option?            -               display
---    :setglobal option?          display             -
---
----------------------------------------------------------------------------------------------------
--- VVI: Options 的 5 中不同的 scope:
---
---  `local to buffer` 属性的情况: `modifiable`, `shiftwidth` ...
---   设置 `set shiftwidth=4` 后, 在后续在任意一个 window 中打开的所有 buffer shiftwidth 都是 4.
---   但在 `set` 之前打开的 buffer 不受影响.
---
---   | set       | vim                     | 已加载的 buffer | 当前 buffer | 后续打开的 buffer |
---   | --------- | ----------------------- | --------------- | ----------- | ----------------- |
---   | setglobal | vim.go / vim.opt_global |                 |             | ✔                 |
---   | setlocal  | vim.bo / vim.opt_local  |                 | ✔           |                   |
---   | set       | vim.o / vim.opt         |                 | ✔           | ✔                 |
---
---   特殊情况: `readonly` 是 `local to buffer`, 但是 `setglobal` 不起作用, 导致 `set` == `setlocal` 只能作用在当前 buffer.
---
----------------------------------------------------------------------------------------------------
---  `local to window` 属性的情况: `number`, `wrap`, `spell`, `foldmethod` ...
---
---   情况1: `setlocal number` 在同一个 win 中打开不同文件.
---      在 win-1000, bufnr-1 (foo.md) 中 `:setlocal number`, 然后在 win-1000 中 `:edit bar.md`, number option 消失.
---      如果再次在 win-1000 中加载 bufnr-1 `:buffer 1` or `:edit foo.md`, number option 出现.
---      但是如果 wipeout bufnr-1 之后再次打开相同文件 `:edit foo.md`, number option 不存在.
---      NOTE: :setlocal 在 local to window 的 option 中是和 bufnr 绑定的.
--
---   情况2: `set number` 在不同的 win 中打开相同文件.
--       win-1000 `set number` 和 win-1001 `set nonumber` 两个 window.
---      win-1000 `:edit foo.md`; win-2000 `:edit bar.md`, 则 foo.md 绑定了 number 属性, bar.md 绑定了 nonumber 属性.
---      在 win-2000 中 `:edit foo.md` 时, number option 依然存在.
---      在 win-1000 中 `:edit bar.md` 时, number option 依然不存在.
---      NOTE: 在不同的 win 中打开 file, 会导致 bufnr 和 local to window option 绑定.
---
---   VVI: `vim.wo[win_id]` 效果和 `:set` 一样. 只是不用跳转到指定的 win_id 内执行 `:set`
---   如果要达到 `:setlocal` 的效果需要使用:
---     - `vim.opt_local.xxx`
---     - `nvim_set_option_value(OPTION, VALUE, { scope='local', win/buf=win_id/bufnr })`
---
---   | set       | vim                      | 已加载的 buffer | 当前 buffer | 后续打开的 buffer |
---   | --------- | ------------------------ | --------------- | ----------- | ----------------- |
---   | setglobal | vim.go / vim.opt_global  |                 |             | ✔                 |
---   | setlocal  | vim.opt_local            |                 | ✔           |                   |
---   | set       | vim.wo / vim.o / vim.opt |                 | ✔           | ✔                 |
---
----------------------------------------------------------------------------------------------------
---  `global` 属性的情况: `undodir`, `cmdwinheight` ...
---
---   影响的是所有的 buffer/window.
---
----------------------------------------------------------------------------------------------------
---  `global or local to buffer` 的属性: `undolevels` ...
---
---   NOTE: local 的优先级高于 global, 如果既设置了 global 也设置了 local 则使用 local 的值.
---
---   情况1:
---     `set undolevels=2000`, 之前打开的和之后被打开的所有 file 的 undolevels 都是 2000.
---     `setlocal undolevels=5000`, 只有 cursor 所在 buffer 的 undolevels 是 5000,
---      其他的 buffer 和后续打开的 buffer 的 undolevels 不变.
---
---   | set       | vim                     | 已加载的 buffer | 当前 buffer | 后续打开的 buffer |
---   | --------- | ----------------------- | --------------- | ----------- | ----------------- |
---   | setglobal | vim.go / vim.opt_global | ✔               | ✔           | ✔                 |
---   | setlocal  | vim.bo / vim.opt_local  |                 | ✔           |                   |
---   | set       | vim.o / vim.opt         | ✔               | ✔           | ✔                 |
---
----------------------------------------------------------------------------------------------------
---  `global or local to window` 的属性: `scrolloff`, `statusline` ...
---
---   NOTE: 影响的是 window 属性, 和 buffer 无关.
---   NOTE: local 的优先级高于 global, 如果既设置了 global 也设置了 local 则使用 local 的值.
---
---   情况1: 在不同 window 中打开同一个文件.
---     win-1000 `:setlocal scrolloff=4`, win-2000 `:setlocal scrolloff=0`
---     win-1000 中 `:edit foo.md`, scrolloff=4; win-2000 中打开相同文件 `:edit foo.md`, scrolloff=0
---
---   | set       | vim                      | 已打开的 window | 当前 window | 后续打开的 window |
---   | --------- | ------------------------ | --------------- | ----------- | ----------------- |
---   | setglobal | vim.go / vim.opt_global  | ✔               | ✔           | ✔                 |
---   | setlocal  | vim.wo / vim.opt_local   |                 | ✔           |                   |
---   | set       | vim.o / vim.opt          | ✔               | ✔           | ✔                 |
---
---   VVI: - local to window 属性是和 buffer 绑定的. `setlocal` 直接和 buffer 绑定; `set` 使得在该 window 中
---          第一次被打开的 buffer 绑定该属性直到 wipeout.
---        - global or local to window 属性是和 window 绑定的, 和 buffer 无关. 同一个 buffer 在属性不同的
---          window 中打开属性也不同.
---
---   VVI: 在 local to window 和 global or local to window 的 option 中 vim.wo 所代表的含义是不同的:
---        - 在 local to window 中 vim.wo[win_id] 相当于 `:set`, 而不是 `:setlocal`
---        - 在 global or local to window 中 vim.wo[win_id] 相当于 `:setlocal`, 而不是 `:set`
---        - 避免使用 `set` & vim.wo[id] 在 local to window 的属性上, 容易混淆.
---
---  NOTE: 搜索 vim.wo 的设置 `:Rg "vim\.wo(\[.*\]){0,1}\.\w+ ?=[^=]"`
---  NOTE: 搜索 vim.bo 的设置 `:Rg "vim\.bo(\[.*\]){0,1}\.\w+ ?=[^=]"`
----------------------------------------------------------------------------------------------------
--- lua 设置 options 的方法:
---
---    | set       | neovim                 | nvim api                                                                       |
---    | --------- | ---------------------- | ------------------------------------------------------------------------------ |
---    | set       | vim.o.xxx, vim.opt.xxx | nvim_set_option_value(OPTION, VALUE, {})                                       |
---    | setlocal  | vim.opt_local.xxx      | nvim_set_option_value(OPTION, VALUE, { scope='local', win/buf=win_id/bufnr })  |
---    | setglobal | vim.opt_global.xxx     | nvim_set_option_value(OPTION, VALUE, { scope='global', win/buf=win_id/bufnr }) |
---
---    - `vim.go` 相当于 `:setglobal`;
---    - `vim.bo` 相当于 `:setlocal`;
---    - `vim.wo` 在 `local to window` 时相当于 `:set`; 而在 `global or local to window` 时相当于 `:setlocal`.
---
---    其他方法: `vim.fn.setwinvar(winnr, '&foldmethod', 'marker')`, 设置 option 也可以使用这个方法. `:echo &foldmethod` 也可以用于读取
---    option 的值.
---
----------------------------------------------------------------------------------------------------
--- NOTE: vim.o & vim.opt 区别:
---    vim.opt.shortmess:append('F') 可以表示 :set shortmess+=F
---    而 vim.o 没办法做到.
---    `:lua print(vim.o.readonly)` = bool
---    `:lua print(vim.opt.readonly)` = table
---    `:lua vim.print(vim.opt.readonly)` print table
---
--- vim lua 自定义变量
---    vim.g.foo = g:foo   -- global-scoped variables
---    vim.b.foo = b:foo   -- buffer-scoped variables
---    vim.w.foo = w:foo   -- window-scoped variables
---    vim.t.foo = t:foo   -- tabpage-scoped variables
---
---    常用 system variables
---    vim.v.shell_error = v:shell_error
---    vim.v.count1 = v:count1
---
--- neovim 中 vimscript 和 lua 互相调用变量.
---  eg1:
---    `:lua vim.g.foo = "omg"`
---    `:echo g:foo`
---  eg2:
---    `:let g:bar="bar" | lua print(vim.g.bar)`
---
-- -- }}}

--- VVI: neovim 特殊设置 --------------------------------------------------------------------------- {{{
--- filetype && syntax
--- `:help filetype-overview` 可以查看 filetype 设置.
--- `:help :filetype`, Detail: The ":filetype on" command will load these files:
---    $VIMRUNTIME/filetype.lua   -- vim 中使用 script 定义 filetype 的文件.
---    $VIMRUNTIME/filetype.vim   -- neovim 中使用 lua 定义 filetype 的文件.
--- `:filetype` 命令打印结果 'filetype detection:ON  plugin:ON  indent:ON'
---
--- VVI: `:help g:did_load_filetypes` 如果存在(不论值是多少), 则
--- 不加载 '$VIMRUNTIME/filetype.vim' & 'runtimepath/filetype.lua', 相当于 `filetype off`.
--vim.g.did_load_filetypes = 0

--- VVI: 设置了 did_load_filetypes 之后不要再设置 `:filetype on/off`, 都会产生冲突.
--vim.cmd('filetype on')  -- 不要手动设置. 使用 vim.g.did_load_filetypes 来代替.

--- Q: Do i need turn off other syntax plugins when using treesitter?
--- A: When you activate treesitter highlighting, syntax gets automatically turned off for that file type
--- while you can keep it for the file types WITHOUT parser.
--- https://github.com/nvim-treesitter/nvim-treesitter/issues/359
--- vim 内置语法高亮, 基于正则表达式的语法高亮.
--vim.cmd('syntax on')    -- 默认开启. `:echo g:syntax_on`, 可以查看 syntax 是否开启.
                          -- nvim-treesitter 插件会强制将 syntax 设置为 `syntax manual`. `:help :syn-manual`
                          -- NOTE: 如果直接设置 `syntax off` 则, vim 不会加载 after/syntax. (但是不影响加载 after/ftplugin)

--- VVI: 不使用 $VIMRUNTIME/ftplugin/xxx.vim 中预设的 keymaps.
--- disable plugin maps 后会导致部分 keymaps 无法使用, 需要手动设置. eg: 'gO'
vim.g.no_plugin_maps = 1

--- VVI: neovim provider 设置. `:checkhealth` 中 "health#provider#check" 可以查看到以下设置是否正确.
--- `:help provider-python`
--- "python3_host_prog" 设置后会提高下面两个文件的加载速度:
---   - /.../nvim/runtime/autoload/provider/python3.vim
---   - /.../nvim/runtime/ftplugin/python.vim
--- "loaded_python3_provider = 0" 设置会禁止加载上面两个文件.
--- NOTE: 这两个设置(二选一)都可以提高 nvim 打开 python 项目速度. Setting this makes startup faster.
vim.g.loaded_python3_provider = 0  -- Disable Python3 |remote-plugin| support
--vim.g.python3_host_prog = "python3" -- To use python3 remote-plugins with Nvim.
                                      -- need to install `python3 -m pip install pynvim`

--- `:help provider-node`, same as above.
vim.g.loaded_node_provider = 0  -- Disable Node |remote-plugin| support
--vim.g.node_host_prog = '' -- To use javascript remote-plugins with Nvim.
                            -- need to install `npm install -g neovim`.

--- `:help provider-ruby`, same as above.
vim.g.loaded_ruby_provider = 0  -- Disable Ruby |remote-plugin| support
--vim.g.ruby_host_prog = '' -- To use Ruby remote-plugins with Nvim.
                            -- need to install `gem install neovim`

--- `:help provider-perl`, same as above.
vim.g.loaded_perl_provider = 0  -- Disable Perl |remote-plugin| support
--vim.g.perl_host_prog = '' -- To use perl remote-plugins with Nvim.
                            -- need to install `cpanm -n Neovim::Ext`.

-- -- }}}

--- tabstop / shiftwidth - prettier indent 设置 ---------------------------------------------------- {{{
--- VVI: `:help editorconfig`, nvim-0.9 中默认读取 editorconfig 文件来设置以下属性.
--- 如果有 .editorconfig 文件则优先使用 editorconfig 的设置;
--- 如果没有 ,editorconfig 文件则使用以下 tabstop, softtabstop, shiftwidth ... 设置.
--vim.g.editorconfig = false  -- false: 禁止使用 editorconfig, 默认值为 true.

--- VVI: 以下设置不要随便改动, 需要配合 vscode & prettier & .editorconfig 一起改动.
--- 最简单的办法是将 tabstop = softtabstop = shiftwidth 设置为同一个值.
local tab_width = 4

vim.opt.expandtab = false  -- 类似 editorconfig 中 indent_style 设置 <Tab> 键使用 "tab" or "space";
                      -- true : `set expandtab` 所有的 \t 都会被转成 space;
                      -- false: `set noexpandtab` 当1个或者多个 softtabstop 长度等于 tabstop 的时候会被转成 \t;
                      --   当 softtabstop=4, tabstop=4, 则 <Tab> 键是 \t. backspace 删除 \t;
                      --   当 softtabstop=2, tabstop=4, 则第一个 <Tab> 是两个空格, 连续两个 <Tab> 会变成 \t;
                      --   每个 <Backspace> 删除1个 softtabstop, 即2个空格.

vim.opt.smarttab = true  -- 默认开启.
                      -- true: 在每行开头的地方 <Tab> 使用 shiftwidth 宽度, 在其他地方 <Tab> 使用 tabstop / softtabstop 宽度.
                      -- false: 在任何地方 <Tab> 都使用 tabstop/softtabstop 宽度, shiftwidth 只在 >> 时使用.

vim.opt.tabstop = tab_width -- '\t' 字符显示宽度, 同时也是 softtabstop 中凑成一个 '\t' 所需的 space 数量.
                      -- vscode 中的 editor.tabSize 设置, .editorconfig 中 tab_width 设置.
                      -- eg: tabstop=8, softtabstop=4, 则按下 <Tab> 键时, 如果能凑够 8 个 space 则变成一个 '\t' 字符.

vim.opt.softtabstop = -1 -- <Tab> & <BackSpace> 按键的缩进宽度, 同时也受到 'smarttab' 影响.
                      -- =0, 不使用 softtabstop.
                      -- <0, eg:-1, 和 shiftwidth 保持一致.
                      -- >0, eg:6, 在 insert <Tab> 的情况下取代 tabstop 的作用.
                      -- nosmarttab, tabstop=4, softtabstop=6, noexpandtab 情况下按下 <Tab> 时, 插入1个 \t 和2个空格.
                      -- nosmarttab, tabstop=4, softtabstop=0, noexpandtab 情况下按下 <Tab> 时, 插入1个 \t.
                      -- nosmarttab, tabstop=4, softtabstop=6, expandtab 情况下按下 <Tab> 时, 插入6个空格.
                      -- nosmarttab, tabstop=4, softtabstop=0, expandtab 情况下按下 <Tab> 时, 插入4个空格.
                      -- nosmarttab, tabstop=4, softtabstop=-1, shiftwidth=2 情况下按下 <Tab> 时, 插入2个空格.

vim.opt.shiftwidth = tab_width -- <Shift-right/left> 按键的缩进宽度, 同时也受到 'smarttab' 影响.
                      -- 在 let g:prettier#config#tab_width='auto' 时影响 prettier indent 的宽度.
                      -- 在 let g:prettier#config#tab_width=2 时不影响 prettier.
                      -- 同时影响 indentLine 画线的宽度.

vim.opt.textwidth = 120  -- 文字自动(硬)换行长度. 即文字写在下一行(增加行号).
                      -- 这里的设置和 golangci-lint lll 长度一样.
                      -- 默认值为 0 即不换行, 文字可以超出屏幕.

vim.opt.wrap = false  -- wrap(默认) - 超出屏幕则(软)换行. 即行号不变, 文字在下一行显示.
                      -- nowrap - 单行可以超出屏幕, 不换行;

--vim.opt.formatoptions='tcqj'  -- `:help fo-table` 自动(硬)换行 breakline 的 options.
                                -- 不同 filetype formatoptions 不相同.
                                -- `tcqj`(default), `cqj`(go,json...), `jcroql`(vim,ts,js...)
                                -- t: wrap text using 'textwidth'.
                                -- c: wrap comments using 'textwidth'.
                                -- j: join lines.

--- prettier 支持的文件, 默认都是使用 2 个 space 来 indent.
--- 同时 shiftwidth 会影响 indent line 画线的宽度.
vim.api.nvim_create_autocmd('FileType', {
  pattern = {'json','jsonc','javascript','javascriptreact','typescript','typescriptreact',
    'vue','svelte','html','css','less','scss','graphql','yaml','lua'},
  callback = function(params)
    local tab_w = 2
    vim.bo[params.buf].expandtab = true
    vim.bo[params.buf].tabstop = tab_w
    vim.bo[params.buf].shiftwidth = tab_w
  end,
  desc = "set expandtab, tabstop, shiftwidth for js,ts,html ...",
})

--- python 默认是 4 个 space indent. 所以这里不设置 shiftwidth.
vim.api.nvim_create_autocmd('FileType', {
  pattern = {'python'},
  callback = function(params)
    vim.bo[params.buf].expandtab = true
    vim.bo[params.buf].textwidth = 79
  end,
  desc = "set expandtab, tabstop, shiftwidth for python",
})

--- `:help ft-markdown-plugin`.
--- markdown 中 'expandtab' will be set by default. 如果需要使用到 \t 则使用设置:
vim.g.markdown_recommended_style = 0
vim.g.markdown_folding = 1

-- -- }}}

--- 以下都是默认设置
--vim.opt.compatible = false
--vim.opt.encoding = 'utf-8'
--vim.opt.fileencoding = 'utf-8'

--vim.g.mapleader = '\\'  -- 设置 <leader>, 默认值是 \
vim.opt.mouse = 'a'  -- allow the mouse to be used in neovim, `:help mouse`

--- VVI: 使用 term gui
vim.opt.termguicolors = true

--- 快捷键延迟时间设置 -----------------------------------------------------------------------------
vim.opt.timeout = true    -- 组合键延迟开启.
vim.opt.timeoutlen = 600  -- 组合键延迟时间, 默认1000ms. eg: <leader>w, <C-W><C-O>...

vim.opt.ttimeout = false  -- <ESC> (\x1b) 组合键是否开启.
vim.opt.ttimeoutlen = 50  -- <ESC> 延迟时间, 默认 50ms.  <ESC> 的主要作用是切换模式.
                          -- <ESC> 是发送 ^[ 相当于是 <C-[> 组合键.
                          -- ttimeoutlen>0 的情况下, 其他模式转成 normal 模式需要 <ESC><ESC> 两次, 或者等待延迟结束;
                          -- ttimeoutlen=0 的情况下, 其他模式转成 normal 模式只需要 <ESC> 一次.
                          -- ttimeoutlen>0 的情况下, 从 insert 直接转成 visual 需要 <ESC>v, 中间不需要经过 normal 模式;
                          -- ttimeoutlen=0 的情况下, 模式转换时肯定会经过 normal. 因为按下 <ESC> 时马上就会转成 normal 模式.

--- 功能设置 ---------------------------------------------------------------------------------------
vim.opt.backspace = {'indent', 'eol', 'start'}  -- 设置 backspace 模式.
vim.opt.history = 10000    -- command 保存的数量，默认(10000)
vim.opt.autoindent = true  -- 继承前一行的缩进方式，适用于多行注释
vim.opt.autowrite = true   -- 可以自动保存 buffer，例如在 buffer 切换的时候.
vim.opt.updatetime = 600   -- faster completion (4000ms default)
vim.opt.hidden = true      -- VVI: 很多插件需要用到 hidden buffer. When 'false' a buffer is unloaded when it is abandoned.

vim.opt.wildoptions = "fuzzy" -- fuzzy search
-- vim.opt.wildmenu = true    -- Command 模式下 <Tab> completion. `:help wildmenu` - enhanced mode of command-line completion.
-- vim.opt.wildmode = "full"  -- Complete the next full match.

--- Donot add end of line char (\n) when save file.
vim.opt.endofline = false
vim.opt.fixendofline = false

--- markdown 文件自动执行 SpellCheck 命令
--vim.cmd [[au Filetype pandoc,markdown setlocal spell spelllang=en,cjk]]

--- window  设置 -----------------------------------------------------------------------------------
vim.opt.splitbelow = true  -- force all horizontal splits to go below current window
vim.opt.splitright = true  -- force all vertical splits to go to the right of current window

--- scroll / listchars 设置 ------------------------------------------------------------------------
vim.opt.scrolloff = 4  -- 在光标到达文件顶部/底部之前, 始终在光标上下留空 n 行. 同时会影响 H / L 键行为.
vim.opt.sidescrolloff = 6  -- 和上面类似, 横向留空 n 列. NOTE: 配合 listchars 设置一起使用.

--- popup widnow 不要设置 scrolloff & sidescrolloff.
--- `:help win_gettype()`, 'popup' window setlocal scrolloff=0 | sidescrolloff=0
vim.api.nvim_create_autocmd('WinEnter', {
  pattern = {"*"},
  callback = function(params)
    local win_id = vim.api.nvim_get_current_win()
    if vim.fn.win_gettype(win_id) == 'popup' then
      --- 'scrolloff' & 'sidescrolloff' 都是 `global or local to window`,
      local scope={ scope='local', win=win_id }
      vim.api.nvim_set_option_value('scrolloff', 0, scope)
      vim.api.nvim_set_option_value('sidescrolloff', 0, scope)
    end
  end,
  desc = "setlocal scrolloff when enter floating window",
})

--- 换行符, space, tab, cr ... 显示设置. `:help listchars` ----------------------------------------- {{{
---   eol:󱞣 - 󰌑 󱞥 󱞣 换行
---   space - 所有空格
---   lead/trail - 行首(尾)的空格, Overrides 'space' & 'multispace' settings.
---   precedes/extends - 不换行(:set nowrap)的情况下, 内容长度超出屏幕的行会有该标记
---   nbsp - non-breakable space (0xA0, byte(160)), normal space (0x20, byte(32))
-- -- }}}
vim.opt.list = true
vim.opt.listchars = { tab='│ ', trail='·', extends='→', precedes='←', nbsp='␣' }

--- 填充符, `:help fillchars` ---------------------------------------------------------------------- {{{
---   diff  - vimdiff 中被删除的行的填充字符.
---   fold  - 折叠代码的行的填充字符.
---   vert  - 竖着并排窗口的分隔符. eg: tagbar, nerdtree ...
---   stl   - statusline 中间的填充字符.
---   stlnc - non-current window 的 statusline 中间的填充字符.
---   eob   - 文件最后一行之后, 空白行的行号.
-- -- }}}
vim.opt.fillchars = { fold=' ', diff=' ', vert='│', eob='~', lastline='@' }

vim.api.nvim_create_user_command('ToggleChars', function()
  local lcs = vim.opt_local.listchars:get()
  if not lcs['lead'] then
    vim.opt.listchars:append('tab:│->')  -- :append() 可以单独设置内部元素
    vim.opt.listchars:append('lead:·')
    vim.opt.listchars:append('eol:󱞣')
    vim.notify("'listchars' & 'fillchars': Enabled")
  else
    vim.opt.listchars:append('tab:│ ')  -- :append() 可以单独设置内部元素
    vim.opt.listchars:remove('lead')
    vim.opt.listchars:remove('eol')
    vim.notify("'listchars' & 'fillchars': Disabled")
  end
end, {bang=true, bar=true})

--- fold 设置 -------------------------------------------------------------------------------------- {{{
--- VVI: 不要设置 foldmethod=syntax, 会严重拖慢文件切换速度. eg: jump to definition.
---
--- foldmethod     treesitter experimental function. 默认 manual.
---
--- foldnestmax=1  只 fold 最外层(第一层). 默认 20, 最大值也是 20, 设置超过该值不生效.
---                对 foldmethod=marker 不生效. 打开文件时自动按照 marker {{{xxx}}} 折叠.
---                NOTE: 'setlocal foldnestmax' 需要放在 'setlocal foldlevel' 之前设置, 否则不生效.
---
--- foldlevel=n    从 level > n 的层开始折叠. 最外层 foldlevel=0, 越内部 foldlevel 越高.
---                999 表示从 1000 层开始 fold, 即不进行 fold.
---
--- `:help foldtext` 改变折叠代码的样式. NOTE: 配合 fillchars 使用.
--- vim.opt.foldtext = 'printf("%s  %s -- lvl %d", getline(v:foldstart), getline(v:foldend), v:foldlevel)'
---
--- vim `:h pattern-overview` 中使用双引号和单引号是不一样的. 单引号 '\(\)\+' 在双引号中需要写成 "\\(\\)\\+"
--- \@<= 用法: \(an\_s\+\)\@<=file, 返回 "file" after "an" and white space or an
--- vim.opt.foldtext = "printf('%s  %s', getline(v:foldstart), matchstr(getline(v:foldend), '\\(.*\\)\\@<=[})]\\+'))"
-- -- }}}
vim.opt.foldenable = true  -- 折叠代码.
-- vim.opt.foldcolumn = "1"   -- 类似 signcolumn
vim.opt.foldlevel = 99  -- `:help fold-foldlevel`, 在可 fold 的情况下 fold 第几层
vim.opt.foldnestmax = 3 -- 最多折叠3层.

--- NOTE: `:help v:lua-call`, eg: `v:lua.require'mypack'.func(arg1, arg2)`
vim.opt.foldtext = "v:lua.require('core.fold.foldtext').foldtext()"

--- 放在最上面, 因为如果 stdpath('config') 路径下有 json ... 等文件, 可以通过下面的 autocmd 覆盖这里的设置.
--- 这里不能使用 'BufEnter' 否则每次切换窗口或者文件的时候都会重新设置.
vim.api.nvim_create_autocmd("BufReadPre", {
  --- "~/.config/nvim/*" 中的所有 file 都使用 marker {{{xxx}}} 折叠.
  pattern = {vim.fn.stdpath('config') .. "/*"},
  callback = function(params)
    local win_id = vim.api.nvim_get_current_win()
    local scope={ scope='local', win=win_id }
    vim.api.nvim_set_option_value('foldmethod', 'marker', scope)
    vim.api.nvim_set_option_value('foldlevel', 0, scope)
  end,
  desc = "setlocal foldmethod = 'marker'",
})

vim.cmd([[au Filetype vim,zsh,yaml setlocal foldmethod=marker foldlevel=0]])

--- `:help *ft-markdown-plugin`, 设置 markdown folding
vim.g.markdown_folding = 1
vim.cmd([[au Filetype markdown setlocal foldlevel=999]])

--- search 设置，命令 `/` `?` ----------------------------------------------------------------------
vim.opt.incsearch = true   -- 开始实时搜索
vim.opt.ignorecase = true  -- 大小写不敏感. 大小写敏感使用 `/Foo\C`; 不敏感用 /Foo\c
vim.opt.smartcase = true   -- 如果 search 文字中有大写字母则 case sensitive; 如果没有大写字母则 ignorecase.
vim.opt.hlsearch = true    -- / ? 搜索时显示所有匹配项. 颜色设置 `hi Search` & `hi IncSearch`

--- 样式设置 ---------------------------------------------------------------------------------------
vim.opt.showtabline = 2   -- always show tabline 屏幕最顶部显示 buffer name 的行.

vim.opt.laststatus = 2    -- last window always show statusline, 屏幕底部状栏.
vim.opt.showmode = false  -- statusline 不显示 mode() 模式信息. airline/lualine 插件显示.

--vim.opt.shortmess:append('c')   -- :set shortmess+=c
vim.opt.showcmd = true  -- 屏幕右下角显示键入的快捷键, 不是 command.
vim.opt.cmdheight = 2   -- 底部 command area (below statusline) 高度, {n} 行.

--- NOTE: number & relativenumber 可以同时开启.
vim.opt.number = true  -- 显示行号
vim.opt.relativenumber = true  -- 显示相对行号
--vim.opt.numberwidth = 4  -- 默认行号占 4 列

vim.opt.cursorline = true    -- 显示当前行. hi CursorLine, CursorLineNr
vim.opt.cursorlineopt = { "number", "screenline" }  -- screenline 和 line 的区别在于 `set wrap` 情况下 cursorline 显示.
--vim.opt.cursorcolumn = true       -- 突出显示当前列. 包括: 背景色...

vim.opt.colorcolumn = '+1'  -- highlight column after 'textwidth'

--- NOTE: 只在 focus 的 window 中显示 cursorline. --- {{{
-- vim.api.nvim_create_autocmd("BufEnter", {
--   pattern = {"*"},
--   callback = function(params)
--     --- 延迟执行避免 bug.
--     vim.schedule(function()
--       local win_id = vim.api.nvim_get_current_win()  -- get current window id
--
--       --- WinEnter 时如果自己是 popup window 则不显示 cursorline, eg: nvim-notify 是 popup window.
--       --- 'unknown' 表示 window 不存在.
--       local win_type = vim.fn.win_gettype(win_id)
--       if win_type ~= 'popup' and win_type ~= 'unknown' then
--         --- NOTE: 这里不能用 ':setlocal cursorline' 否则会作用在当前 buffer 上, 这里需要作用在整个 window 上.
--         --- 'cursorline' 是 `local to window`, 这里使用 vim.wo.cursorline 相当于 `:set cursorline`,
--         --vim.wo[curr_win_id].cursorline = true  -- OK
--         vim.api.nvim_set_option_value('cursorline', true, {win=win_id})
--       end
--
--       --- 删除别的 window 中的 cursorline.
--       --- diff 模式的 window 除外.
--       for _, win_id in ipairs(vim.api.nvim_tabpage_list_wins(0)) do
--         if win_id ~= win_id and not vim.wo[win_id].diff then
--           --- NOTE: 这里不能用 ':setlocal cursorline' 否则会作用在当前 buffer 上, 这里需要作用在整个 window 上.
--           --- 'cursorline' 是 `local to window`, 这里使用 vim.wo.cursorline 相当于 `:set cursorline`,
--           --vim.wo[curr_win_id].cursorline = false  -- OK
--           vim.api.nvim_set_option_value('cursorline', false, {win=win_id})
--         end
--       end
--     end)
--   end,
--   desc = "`set cursorline` when enter window, `set nocursorline` to other windows",
-- })
-- -- }}}

vim.opt.signcolumn = 'yes:1'  -- 'auto:1-3', 最少预留 1 个 sign 的宽度, 最多显示 3 个 sign 的宽度.
                              -- 'yes:1' 表示永远显示 1 个 sign 的宽度.
                              -- '1' 表示同一行可同时显示最多 1 个 sign. 宽度为 1*2=2 格, 根据 priority 显示;
                              -- 如果值为 '3', 则可以在同一行显示最多 3 个 sign. signcolumn 宽度为 3*2=6 ...

vim.opt.showmatch = true      -- 跳到匹配的括号上, 包括 () {} []

vim.opt.completeopt = { "menuone", "noselect" } -- 代码补全, nvim-cmp 设置.
vim.opt.pumheight = 16  -- Maximum number of items to show in the popup menu. 默认 0
--vim.opt.pumwidth = 15   -- Minimum width for the popup menu (ins-completion-menu). 默认 15

--- backup swapfile undofile ----------------------------------------------------------------------- {{{
--- `:help backup-table`, 四种设置情况.
--- 禁用 backup 功能.
vim.opt.backup = false
vim.opt.writebackup = false

--- 允许使用 swp 缓存文件.
vim.opt.swapfile = true

--- undo history 持久化
vim.opt.undofile = true
vim.opt.undodir = '/tmp/nvim/undo'  -- undodir 是全局设置, 无法单独给某个文件设置.
--vim.opt.undolevels = 1000  -- 默认 1000. NOTE: undolevels 太大可能影响 opening buffer 速度.

--- 这里使用 VimEnter 是因为只需要执行一次命令.
vim.api.nvim_create_autocmd("VimEnter", {
  pattern = {"*"},
  once = true,  -- "++once" 只在进入 neovim 时执行一次 autocmd
  callback = function(params)
    --- 延迟执行
    vim.schedule(function()
      --- undodir 不存在的情况下, `mkdir -p` 创建该文件夹.
      if not vim.uv.fs_stat(vim.go.undodir) then
        --- :wait() sync run
        local result = vim.system({'mkdir', '-p', vim.go.undodir}, { text = true }):wait()
        if result.code ~= 0 then
          error(result.stderr ~= '' and result.stderr or result.code)
        end
      end
    end)
  end,
  desc = "mkdir -p undodir",
})
-- -- }}}

--- NOTE: 'quickfix' & 'location-list' 的 filetype 都是 'qf'.
--- :wincmd 快捷键是 <Ctrl-w>
--vim.cmd [[au Filetype qf :wincmd J]]  --- 打开 qf window 时, 始终显示在屏幕最下方.
--vim.cmd [[au Filetype qf :setlocal nobuflisted]]  --- nobuflisted for quickfix && location-list
vim.api.nvim_create_autocmd("FileType", {
  pattern = {"qf"},
  callback = function(params)
    --- setlocal nobuflisted
    vim.bo[params.buf].buflisted = false

    --- close window
    vim.keymap.set('n', 'q', '<cmd>q<CR>', {buffer=params.buf, desc="close window"})
  end,
  desc = "<q> close quickfix window",
})

--- `:help command-line-window`, 包括 q: q/ q? 打开的窗口.
vim.api.nvim_create_autocmd("CmdwinEnter", {
  pattern = {"*"},  -- 包括: ":" "/" "?"
  callback = function(params)
    --- setlocal nobuflisted
    vim.bo[params.buf].buflisted = false

    --- close window
    vim.keymap.set('n', 'q', '<cmd>q<CR>', { buffer=params.buf, desc="close window" })
  end,
  desc = "<q> close command-line window",
})

--- spell check Command
vim.opt.spelllang = { "en_us", "cjk" }
vim.api.nvim_create_user_command('ToggleSpellCheck', function()
  local win_id = vim.api.nvim_get_current_win()
  local scope={ scope='local', win=win_id }
  if vim.wo[win_id].spell then
    vim.api.nvim_set_option_value('spell', false, scope)
    vim.notify("Spell Check: Disabled")
  else
    vim.api.nvim_set_option_value('spell', true, scope)
    vim.notify("Spell Check: Enabled")
  end
end, {bang=true, bar=true})

--- 如果删除最后一个 buflisted window, 则在删除之前创建一个新的 window.
vim.api.nvim_create_autocmd("QuitPre", {
  callback = function(params)
    local win_id = vim.api.nvim_get_current_win()
    if vim.api.nvim_win_get_buf(win_id) ~= params.buf then
      return
    end

    --- skip unsaved file
    if vim.bo[params.buf].modified then
      return
    end

    --- skip netrw/NvirTree filetype
    if vim.bo[params.buf].filetype == "NvimTree" or vim.bo[params.buf].filetype == "netrw" then
      return
    end

    local normal_win_count = 0
    local buflisted_win_count = 0
    for _, wid in ipairs(vim.api.nvim_list_wins()) do
      if vim.fn.win_gettype(wid) == '' then
        normal_win_count = normal_win_count + 1
      end
      if vim.fn.buflisted(vim.api.nvim_win_get_buf(wid)) == 1 then
        buflisted_win_count = buflisted_win_count + 1
      end
    end

    --- last normal window
    if vim.fn.win_gettype(win_id) == '' and normal_win_count <= 1 then
      vim.notify("Cannot quit the last normal window. use `:qa`", vim.log.levels.WARN)
      vim.cmd.vsplit()  -- 使用 vsplit 防止 window 高度改变
      return
    end

    --- last buflisted window
    if vim.fn.buflisted(params.buf) == 1 and buflisted_win_count <= 1 then
      vim.notify("Cannot quit the last buflisted window.", vim.log.levels.WARN)
      vim.cmd.vsplit()  -- 使用 vsplit 防止 window 高度改变
      return
    end
  end,
  desc = "Do not quit last (buflisted) window",
})

--- help widnow 放到最右侧
-- vim.api.nvim_create_autocmd("FileType", {
--   pattern = {"help"},
--   callback = function(params)
--     --- 设置 bdelete 时 unload 之后, 再次打开 help 时会触发 FileType.
--     vim.bo[params.buf].bufhidden = 'unload'
--     --- move help window to the right side.
--     vim.cmd('wincmd L')
--   end,
--   desc = "help window vertically splitright",
-- })



