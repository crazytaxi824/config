--- https://github.com/LunarVim/Neovim-from-scratch/blob/master/lua/user/options.lua
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
--- Options 的 5 中不同的 scope:
---
---  `local to buffer` 属性的情况: `modifiable`, `shiftwidth` ...
---
---    影响的是 buffer 属性. `vim.bo` 效果和 `:setlocal` 一样.
---
---    | set       | vim                     | 已加载的 hidden buffer | 当前 buffer | 后续打开的 buffer |
---    | --------- | ----------------------- | ---------------------- | ----------- | ----------------- |
---    | setglobal | vim.go / vim.opt_global |                        |             | ✔                 |
---    | setlocal  | vim.bo / vim.opt_local  |                        | ✔           |                   |
---    | set       | vim.o / vim.opt         |                        | ✔           | ✔                 |
---    特殊情况: `readonly` 是 `local to buffer`, 但是 `setglobal` 不起作用, 导致 `set` == `setlocal` 只能作用在当前 buffer.
---
---  NOTE: 搜索 vim.bo 的设置 `:Rg "vim\.bo(\[.*\]){0,1}\.\w+ ?=[^=]"`
---
----------------------------------------------------------------------------------------------------
---  `local to window` 属性的情况: `number`, `wrap`, `spell`, `foldmethod` ...
---
---    VVI: 这里影响的还是 buffer 属性.
---         `vim.wo` 效果和 `:set` 一样, 如果要达到 `:setlocal` 的效果需要使用:
---            - `vim.opt_local.xxx`
---            - `nvim_set_option_value(OPTION, VALUE, { scope='local', win/buf=win_id/bufnr })`
---
---    | set       | vim                      | 已加载的 hidden buffer | 当前 buffer | 后续打开的 buffer |
---    | --------- | ------------------------ | ---------------------- | ----------- | ----------------- |
---    | setglobal | vim.go / vim.opt_global  |                        |             | ✔                 |
---    | setlocal  | vim.opt_local            |                        | ✔           |                   |
---    | set       | vim.wo / vim.o / vim.opt |                        | ✔           | ✔                 |
---
---  NOTE: 搜索 vim.wo 的设置 `:Rg "vim\.wo(\[.*\]){0,1}\.\w+ ?=[^=]"`
--- 
----------------------------------------------------------------------------------------------------
---  `global` 属性的情况: `undodir`, `cmdwinheight` ...
---
---    影响的是所有的 buffer/window.
---
----------------------------------------------------------------------------------------------------
---  `global or local to buffer` 的属性: `undolevels` ...
---
---    影响的是 buffer 属性.
---
---    | set       | vim                     | 已加载的 hidden buffer | 当前 buffer | 后续打开的 buffer |
---    | --------- | ----------------------- | ---------------------- | ----------- | ----------------- |
---    | setglobal | vim.go / vim.opt_global | ✔                      | ✔           | ✔                 |
---    | setlocal  | vim.bo / vim.opt_local  |                        | ✔           |                   |
---    | set       | vim.o / vim.opt         | ✔                      | ✔           | ✔                 |
---
----------------------------------------------------------------------------------------------------
---  `global or local to window` 的属性: `scrolloff`, `statusline` ...
---
---    NOTE: 影响的是 window 属性, 和 buffer 无关.
---
---    | set       | vim                     | 已打开的 window | 当前 window | 后续打开的 window |
---    | --------- | ----------------------- | --------------- | ----------- | ----------------- |
---    | setglobal | vim.go / vim.opt_global | ✔               | ✔           | ✔                 |
---    | setlocal  | vim.wo / vim.opt_local  |                 | ✔           |                   |
---    | set       | vim.o / vim.opt         | ✔               | ✔           | ✔                 |
---
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
---    `:lua print(vim.inspect(vim.opt.readonly))` print table
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
--- filetype && syntax 设置
--- VVI: `help g:did_load_filetypes` 如果存在(不论值是多少),
--- 则不加载 '$VIMRUNTIME/filetype.vim' & 'runtimepath/filetype.lua', 相当于 `filetype off`.
--vim.g.did_load_filetypes = 0

--- VVI: `:help g:do_legacy_filetype` 使用 vim filetype 而不使用 neovim filetype.
--vim.g.do_legacy_filetype = 1

--- `:help filetype-overview` 可以查看 filetype 设置.
--- `:help :filetype`, Detail: The ":filetype on" command will load these files:
---    $VIMRUNTIME/filetype.lua
---    $VIMRUNTIME/filetype.vim
--- `:filetype` 命令打印结果 'filetype detection:ON  plugin:ON  indent:ON'
--- VVI: 因此设置了 did_load_filetypes 之后不要再设置 `:filetype on/off`, 都会产生冲突.
--vim.cmd('filetype on')  -- 不要手动设置. 使用 vim.g.did_load_filetypes 来代替.

--- NOTE: https://github.com/nvim-treesitter/nvim-treesitter/issues/359
--- When you activate treesitter highlighting, syntax gets automatically turned off for that file type
--- while you can keep it for the file types WITHOUT parser.
--- vim 内置语法高亮, 基于正则表达式的语法高亮.
--vim.cmd('syntax on')    -- 默认开启. `:echo g:syntax_on`, 可以查看 syntax 是否开启.
                          -- nvim-treesitter 插件会强制将 syntax 设置为 `syntax manual`. `:help :syn-manual`
                          -- NOTE: 如果直接设置 `syntax off` 则, vim 不会加载 after/syntax. (但是不影响加载 after/ftplugin)

--- VVI: 不使用 $VIMRUNTIME/ftplugin/xxx.vim 中预设的 keymap.
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

vim.opt.wrap = false     -- 单行文字是否可以超出屏幕. local to window, 所以如果想要区别设置只能使用 BufEnter.
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

-- -- }}}

--- 以下都是默认设置
--vim.opt.compatible = false
--vim.opt.encoding = 'utf-8'
--vim.opt.fileencoding = 'utf-8'

--vim.g.mapleader = '\\'
vim.opt.mouse = 'a'  -- allow the mouse to be used in neovim, `:help mouse`

--- 快捷键延迟时间设置 -----------------------------------------------------------------------------
vim.opt.timeout = true    -- 组合键延迟开启.
vim.opt.timeoutlen = 600  -- 组合键延迟时间, 默认1000ms. eg: <leader>w, <C-W><C-O>...

vim.opt.ttimeout = false  -- <ESC> (\x1b) 组合键是否开启.
--vim.opt.ttimeoutlen = 0   -- <ESC> 延迟时间, 默认 50ms.  <ESC> 的主要作用是切换模式.
                          -- <ESC> 是发送 ^[ 相当于是 <C-[> 组合键.
                          -- ttimeoutlen>0 的情况下, 其他模式转成 normal 模式需要 <ESC><ESC> 两次, 或者等待延迟结束;
                          -- ttimeoutlen=0 的情况下, 其他模式转成 normal 模式只需要 <ESC> 一次.
                          -- ttimeoutlen>0 的情况下, 从 insert 直接转成 visual 需要 <ESC>v, 中间不需要经过 normal 模式;
                          -- ttimeoutlen=0 的情况下, 模式转换时肯定会经过 normal. 因为按下 <ESC> 时马上就会转成 normal 模式.

--- 功能设置 ---------------------------------------------------------------------------------------
vim.opt.backspace = 'indent,eol,start'  -- 设置 backspace 模式.
vim.opt.history = 10000    -- command 保存的数量，默认(10000)
vim.opt.autoindent = true  -- 继承前一行的缩进方式，适用于多行注释
vim.opt.autowrite = true   -- 可以自动保存 buffer，例如在 buffer 切换的时候.
vim.opt.updatetime = 600   -- faster completion (4000ms default)
vim.opt.wildmenu = true    -- Command 模式下 <Tab> completion. `:help wildmenu` - enhanced mode of command-line completion.
vim.opt.wildmode = "full"  -- Complete the next full match.
vim.opt.wildoptions = ""   -- default "pum,tagfile", pum - popupmenu | tagfile - <C-d> list matches
vim.opt.wildignorecase = true  -- command 自动补全时忽略大小写.
vim.opt.hidden = true      -- VVI: 很多插件需要用到 hidden buffer. When 'false' a buffer is unloaded when it is abandoned.

--- markdown 文件自动执行 SpellCheck 命令
--vim.cmd [[au Filetype pandoc,markdown setlocal spell spelllang=en,cjk]]

--- window  设置 -----------------------------------------------------------------------------------
vim.opt.splitbelow = true  -- force all horizontal splits to go below current window
vim.opt.splitright = true  -- force all vertical splits to go to the right of current window

--- scroll / listchars 设置 ------------------------------------------------------------------------
vim.opt.scrolloff = 4  -- 在光标到达文件顶部/底部之前, 始终在光标上下留空 n 行. 同时会影响 H / L 键行为.
vim.opt.sidescrolloff = 16  -- 和上面类似, 横向留空 n 列. NOTE: 配合 listchars 设置一起使用.

--- `:help win_gettype()`, 'popup' window setlocal scrolloff=0 | sidescrolloff=0
vim.api.nvim_create_autocmd('WinEnter', {
  pattern = {"*"},
  callback = function(params)
    local win_id = vim.api.nvim_get_current_win()  -- get current window id
    if vim.fn.win_gettype(win_id) == 'popup' then
      --- 'scrolloff' & 'sidescrolloff' 都是 `global or local to window`,
      --- 这里使用 'vim.wo' 相当于 ':setlocal'
      vim.wo[win_id].scrolloff = 0
      vim.wo[win_id].sidescrolloff = 0
    end
  end,
  desc = "setlocal scrolloff when enter floating window",
})

--- 换行符, space, tab, cr ... 显示设置. `:help listchars` ----------------------------------------- {{{
---   eol:↴ - 换行
---   lead/trail - 行首(尾)的空格
---   precedes/extends - 不换行(:set nowrap)的情况下, 内容长度超出屏幕的行会有该标记
-- -- }}}
vim.opt.list = true
vim.opt.listchars = 'tab:│ ,lead: ,trail:·,extends:→,precedes:←,nbsp:⎵'

--- 填充符, `:help fillchars` ---------------------------------------------------------------------- {{{
---   diff  - vimdiff 中被删除的行的填充字符.
---   fold  - 折叠代码的行的填充字符.
---   vert  - 竖着并排窗口的分隔符. eg: tagbar, nerdtree ...
---   stl   - statusline 中间的填充字符.
---   stlnc - non-current window 的 statusline 中间的填充字符.
---   eob   - 文件最后一行之后, 空白行的行号.
-- -- }}}
vim.opt.fillchars = 'fold: ,diff: ,vert:│,eob:~'

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
--- vim.opt.foldtext = 'printf("%s … %s -- lvl %d", getline(v:foldstart), getline(v:foldend), v:foldlevel)'
---
--- vim `:h pattern-overview` 中使用双引号和单引号是不一样的. 单引号 '\(\)\+' 在双引号中需要写成 "\\(\\)\\+"
--- \@<= 用法: \(an\_s\+\)\@<=file, 返回 "file" after "an" and white space or an
--- vim.opt.foldtext = "printf('%s … %s', getline(v:foldstart), matchstr(getline(v:foldend), '\\(.*\\)\\@<=[})]\\+'))"
-- -- }}}
vim.opt.foldenable = true  -- 折叠代码.
vim.opt.foldnestmax = 3    -- 最多折叠3层. NOTE: 'setlocal foldnestmax' 需要放在 'foldlevel' 之前设置, 否则不生效.

vim.opt.foldtext = "v:lua.__Folded_line_text()"  -- VVI: 运行 lua Global function. `v:lua.xxx()` 只能运行 global function.
function __Folded_line_text()
  --- VVI: replace '\t' with 'N-spaces'. 否则 \t 会被认为是一个 char, 导致 line 开头的内容部分被隐藏.
  --- N-spaces 根据 buffer 的 tabstop 决定.
  local fs = string.gsub(vim.fn.getline(vim.v.foldstart), '\t', string.rep(' ', vim.bo.tabstop))
  local fe = string.gsub(vim.fn.getline(vim.v.foldend), '^%s+', '')

  --- 这里主要是使用 setlocal foldmethod=expr foldexpr=nvim_treesitter#foldexpr() 功能.
  if vim.wo.foldmethod == 'expr' then
    return fs .. ' … ' .. fe
  end
  return fs .. ' ' .. fe
end

--- 放在最上面, 因为如果 stdpath('config') 路径下有 json ... 等文件, 可以通过下面的 autocmd 覆盖这里的设置.
--- 这里不能使用 'BufEnter' 否则每次切换窗口或者文件的时候都会重新设置.
vim.api.nvim_create_autocmd("FileType", {
  pattern = {"*"},
  callback = function(params)
    --- "~/.config/nvim/*" 中的所有 file 都使用 marker {{{xxx}}} 折叠.
    if string.match(vim.fn.fnamemodify(params.file, ":p"), '^'..vim.fn.stdpath('config')) then
      vim.opt_local.foldmethod = "marker"
      vim.opt_local.foldlevel = 0
    end
  end,
  desc = "setlocal foldmethod = 'marker'",
})

vim.cmd([[au Filetype vim,zsh,yaml setlocal foldmethod=marker foldlevel=0]])

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
vim.opt.cursorlineopt = "number,screenline"  -- screenline 和 line 的区别在于 `set wrap` 情况下 cursorline 显示.
--vim.opt.cursorcolumn = true       -- 突出显示当前列. 包括: 背景色...

--- NOTE: 进入 window 是显示 cursorline; 离开 window 时取消显示 cursorline
vim.api.nvim_create_autocmd("WinEnter", {
  pattern = {"*"},
  callback = function(params)
    local curr_win_id = vim.api.nvim_get_current_win()  -- get current window id

    --- 除 popup window 外, 显示 cursorline, eg: nvim-notify 是 popup window
    if vim.fn.win_gettype(curr_win_id) ~= 'popup' then
      --- 'cursorline' 是 `local to window`, 这里使用 vim.wo.cursorline 相当于 `:set cursorline`,
      --- 不能用 ':setlocal cursorline' 否则会作用在当前 buffer 上, 这里需要作用在整个 window 上.
      vim.wo[curr_win_id].cursorline = true
    end

    --- 删除别的 window 中的 cursorline
    for _, win_id in ipairs(vim.api.nvim_tabpage_list_wins(0)) do
      if win_id ~= curr_win_id then
        vim.wo[win_id].cursorline = false
      end
    end
  end,
  desc = "`set cursorline` when enter window, `set nocursorline` to other windows",
})

vim.opt.signcolumn = 'yes:1'  -- 'auto:1-3', 最少预留 1 个 sign 的宽度, 最多显示 3 个 sign 的宽度.
                              -- 'yes:1' 表示永远显示 1 个 sign 的宽度.
                              -- '1' 表示同一行可同时显示最多 1 个 sign. 宽度为 1*2=2 格, 根据 priority 显示;
                              -- 如果值为 '3', 则可以在同一行显示最多 3 个 sign. signcolumn 宽度为 3*2=6 ...

vim.opt.showmatch = true      -- 跳到匹配的括号上, 包括 () {} []

vim.opt.completeopt = { "menu", "menuone", "noselect" } -- 代码补全, nvim-cmp 设置.
                                                        -- https://github.com/hrsh7th/nvim-cmp#setup
--vim.opt.pumheight = 16  -- Maximum number of items to show in the popup menu. 默认 0
--vim.opt.pumwidth = 15   -- Minimum width for the popup menu (ins-completion-menu). 默认 15

--- 只在超出 textwidth 的行中显示 ColorColumn. 可以替代 `set colorcolumn`
--vim.opt.colorcolumn = '+1'  -- :set cc=+1  " highlight column after 'textwidth'
                              -- :set cc=+1,+2,+3  " highlight three columns after 'textwidth'
--vim.cmd [[ au FileType * call matchadd('ColorColumn', '\%' .. (&textwidth+1) .. 'v', 100) ]]
vim.api.nvim_create_autocmd("FileType", {
  pattern = {"*"},
  callback = function(params)
    --- `:help 'buftype'`, exclude buftype: nofile, terminal, quickfix, prompt, help ...
    if vim.bo[params.buf].buftype ~= '' then
      return
    end

    --- 如果 buffer 没有设置 textwidth, 即:textwidth=0, 则不 highlight virtual column.
    --- `:help pattern`, `\%23v` highlight virtual column 23.
    if vim.bo[params.buf].textwidth > 0 then
      vim.fn.matchadd('ColorColumn', '\\%' .. vim.bo[params.buf].textwidth+1 .. 'v', 100)
    end
  end,
  desc = "using matchadd() set colorcolumn",
})

--- backup swapfile undofile -----------------------------------------------------------------------
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
--vim.cmd([[au Filetype * ++once :silent !mkdir -p ]] .. vim.go.undodir)

--- autocmd ----------------------------------------------------------------------------------------
--- 这里使用 VimEnter 是因为只需要执行一次命令.
vim.api.nvim_create_autocmd("VimEnter", {
  pattern = {"*"},
  once = true,  -- "++once" 只在进入 neovim 时执行一次 autocmd
  callback = function(params)
    --- 延迟执行
    vim.schedule(function()
      --- undodir 不存在的情况下, `mkdir -p` 创建该文件夹.
      if vim.fn.isdirectory(vim.go.undodir) == 0 then
        --vim.cmd([[silent !mkdir -p ]] .. vim.go.undodir)
        local result = vim.fn.system('mkdir -p '.. vim.go.undodir)
        if vim.v.shell_error ~= 0 then
          Notify(result, "ERROR")
          return
        end
      end
    end)
  end,
  desc = "mkdir -p undodir",
})

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
    vim.keymap.set('n', 'q', '<cmd>q<CR>', {noremap=true, buffer=params.buf, desc="close window"})
    --vim.keymap.set('n', '<ESC>', '<cmd>q<CR>', {noremap=true, buffer=params.buf, desc="close window"})
  end,
  desc = "<q> close quickfix window",
})

--- `:help command-line-window`, 包括 q: q/ q? 打开的窗口.
--vim.cmd([[autocmd CmdwinEnter * nnoremap <buffer> q <cmd>q<CR>]])
vim.api.nvim_create_autocmd("CmdwinEnter", {
  pattern = {"*"},  -- 包括: ":" "/" "?"
  callback = function(params)
    --- setlocal nobuflisted
    vim.bo[params.buf].buflisted = false

    --- close window
    vim.keymap.set('n', 'q', '<cmd>q<CR>', {noremap=true, buffer=params.buf, desc="close window"})
    --vim.keymap.set('n', '<ESC>', '<cmd>q<CR>', {noremap=true, buffer=params.buf, desc="close window"})
  end,
  desc = "<q> close command window",
})

--- spell check Command
vim.opt.spelllang = "en_us,cjk"
vim.api.nvim_create_user_command('SpellCheckToggle', function()
  if vim.wo.spell then
    vim.opt_local.spell = false
  else
    vim.opt_local.spell = true
  end
end, {bang=true, bar=true})

--- 其他设置 --------------------------------------------------------------------------------------- {{{
--- NOTE: keymap 'gO' 被 g:no_plugin_maps disable. 没什么作用.
--- <cmd>call man#show_toc()<CR> 是 neovim 源代码中的设置.
-- vim.api.nvim_create_autocmd("FileType", {
--   pattern = {"help"},
--   callback = function(params)
--     local cmd = '<cmd>lua require("man").show_toc()<CR>'
--     vim.keymap.set('n', 'gO', cmd, {
--       noremap=true,
--       silent=true,
--       buffer=params.buf,
--       desc='table of contents',
--     })
--   end
-- })
-- -- }}}



