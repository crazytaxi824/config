--- 功能 -------------------------------------------------------------------------------------------
vim.g['airline#extensions#tabline#enabled'] = 1  -- 上方开启 buffer list

--- buffer list 编号模式. 用于 <Plug>AirlineSelectTabX 功能.
--- mode = 1 只能使用 <Plug>AirlineSelectTab0-9,   0 是最后一个 buffer 编号, 相当于 10
--- mode = 2 只能使用 <Plug>AirlineSelectTab11-99, 没有 0-9 可以用, 第一个编号是 11
--- mode = 3 可以使用 <Plug>AirlineSelectTab01-99, 第一个编号是 01, 而不是 1
vim.g['airline#extensions#tabline#buffer_idx_mode'] = 1

--- 检查文档格式
--- indent: mixed indent within a line
--- long:   overlong lines
--- trailing: trailing whitespace
--- mixed-indent-file: different indentation in different lines
--- conflicts: checks for conflict Markers
vim.g['airline#extensions#whitespace#checks'] = {'indent', 'trailing', 'conflicts'}

--- VVI: 指定 filetype 中不能使用 <Plug>AirlineSelectXXX 功能.
vim.g['airline#extensions#tabline#keymap_ignored_filetypes'] = {'vimfiler', 'nerdtree', 'tagbar', 'NvimTree', 'toggleterm', 'myterm'}

--- VVI: 文件名(pattern)匹配则 unlist. 这里需要修改默认值, 否则 tagbar.lua 无法显示在 tabline 中.
vim.g['airline#extensions#tabline#ignore_bufadd_pat'] = '!|defx|gundo|term://'

--- buffer unlist 指定文件名(pattern), 和上面的 ignore_bufadd_pat 功能类似.
--vim.g['airline#extensions#tabline#excludes'] = {'term://'}  -- list

--- airline 插件设置, 默认都是开启状态 -------------------------------------------------------------
--vim.g['airline#extensions#branch#enabled'] = 1  -- "tpope/vim-fugitive"
--vim.g['airline#extensions#tagbar#enabled'] = 1  -- "tagbar"

--- 自定义样式 -------------------------------------------------------------------------------------
--- 自定义 theme 文件在 '~/.config/nvim/autoload/airline/themes/mydark.vim'
vim.g.airline_theme = "mydark"
--vim.g.airline_theme = "dark"   -- 自带主题

--- 自定义 formatter 文件在 '~/.config/nvim/autoload/airline/extensions/tabline/formatters/myfilename.vim'
vim.g['airline#extensions#tabline#formatter'] = 'myfilename'
--vim.g['airline#extensions#tabline#formatter'] = 'unique_tail'

--- `:help mode()` 显示所有模式 -------------------------------------------------------------------- {{{
vim.g.airline_mode_map = {
	['n']     = ' NORMAL -',
	['t']     = ' TERMINAL',
	['v']     = ' VISUAL -',
	['V']     = ' VISUAL L',
	['']    = ' VISUAL B',
	['s']     = ' SELECT -',
	['S']     = ' SELECT L',
	['']    = ' SELECT B',
	['i']     = ' INSERT -',
	['niI']   = ' INSERT N',
	['ic']    = ' INSERT C',
	['ix']    = ' INSERT C',
	['c']     = ' COMMAND ',
	['R']     = 'REPLACE -',
	['niR']   = 'REPLACE N',
	['Rc']    = 'REPLACE C',
	['Rx']    = 'REPLACE C',
	['Rv']    = 'V-REPLACE -',
	['niV']   = 'V-REPLACE N',
}
-- -- }}}

--- keymaps ----------------------------------------------------------------------------------------
--- 利用 <Plug>AirlineSelectPrev/NextTab 判断是否需要 delete buffer.
local function airline_del_current_buffer()
  local before_select_bufnr = vim.fn.bufnr('%')  --- 获取当前 bufnr()
  vim.cmd([[execute "normal! \<Plug>AirlineSelectPrevTab"]])  -- 使用 airline 跳转到 prev/next buffer
  local after_select_bufnr = vim.fn.bufnr('%')   --- 获取跳转后 bufnr()

  --- 如果 before != after 则执行 bdelete #.
  if before_select_bufnr ~= after_select_bufnr then
    vim.cmd([[bdelete #]])
  end
end

local opt = { noremap = true, silent = true }
local airline_keymaps = {
  -- airline ---------------------------------------------------------------------------------------
  {'n', '<leader>1', '<Plug>AirlineSelectTab1', opt, 'which_key_ignore'},
  {'n', '<leader>2', '<Plug>AirlineSelectTab2', opt, 'which_key_ignore'},
  {'n', '<leader>3', '<Plug>AirlineSelectTab3', opt, 'which_key_ignore'},
  {'n', '<leader>4', '<Plug>AirlineSelectTab4', opt, 'which_key_ignore'},
  {'n', '<leader>5', '<Plug>AirlineSelectTab5', opt, 'which_key_ignore'},
  {'n', '<leader>6', '<Plug>AirlineSelectTab6', opt, 'which_key_ignore'},
  {'n', '<leader>7', '<Plug>AirlineSelectTab7', opt, 'which_key_ignore'},
  {'n', '<leader>8', '<Plug>AirlineSelectTab8', opt, 'which_key_ignore'},
  {'n', '<leader>9', '<Plug>AirlineSelectTab9', opt, 'which_key_ignore'},
  {'n', '<leader>0', '<Plug>AirlineSelectTab0', opt, 'which_key_ignore'},

  --- NOTE: 如果 cursor 所在的 window 中显示的(active) buffer 是 unlisted (即: 不显示在 tabline 上的 buffer),
  --- 不能使用 <Plug>AirlineSelectPrev/NextTab 来进行 buffer 切换,
  --- 但是可以使用 <Plug>AirlineSelectTabX 直接跳转.
  {'n', '<lt>', '<Plug>AirlineSelectPrevTab'},  --- <lt>, less than, 代表 '<'. 也可以使用 '\<'
  {'n', '>', '<Plug>AirlineSelectNextTab'},

  --- airline 关闭 buffers.
  --- bufnr("#") > 0 表示 '#' (previous buffer) 存在, 如果不存在则 bufnr('#') = -1.
  --- 如果 # 存在, 但处于 unlisted 状态, 则 bdelete # 报错. 因为 `:bdelete` 本质就是 unlist buffer.
  {'n', '<leader>d', airline_del_current_buffer, opt, 'Close This Buffer'},
}

Keymap_set_and_register(airline_keymaps)



