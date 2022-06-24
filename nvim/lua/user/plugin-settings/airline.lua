--- 功能 -------------------------------------------------------------------------------------------
vim.g['airline#extensions#tabline#enabled'] = 1  -- 上方开启 buffer list

--- buffer list 编号模式. 用于 <Plug>AirlineSelectTabX 功能.
--- mode = 1 只能使用 <Plug>AirlineSelectTab0-9,   0 是最后一个 buffer 编号, 相当于 10
--- mode = 2 只能使用 <Plug>AirlineSelectTab11-99, 没有 0-9 可以用, 第一个编号是 11
--- mode = 3 可以使用 <Plug>AirlineSelectTab01-99, 第一个编号是 01, 而不是 1
vim.g['airline#extensions#tabline#buffer_idx_mode'] = 3

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
--- NOTE: 打开 unlisted buffer 后, <Plug>AirlineSelectPrev/NextTab 无法使用. 但是可以使用 <Plug>AirlineSelectTabX
--- 如果当前 buffer 是 unlisted active buffer, 即显示但不在 tabline 中的 buffer, 则
--- 使用 \d  跳转到 (#/first/last) listed buffer.
--- 不需要 bdelete, 因为该 buffer 本身是 unlisted.

--- functions for delete current buffer from tabline ----------------------------------------------- {{{
--- 寻找指定 listed bufnr 在 airline's tabline 中的 tab index 位置.
--- 如果 bufnr 不存在, 则返回 listed buffer 总数.
local function buf_index_in_airline_tab(bufnr)
  local buffers = vim.fn.getbufinfo()
  local tab_index = 0
  for i = 1, #buffers, 1 do
    if buffers[i].listed == 1 then  -- 只统计 listed buffer
      tab_index = tab_index + 1
      if bufnr and buffers[i].bufnr == bufnr then
        --- 如果 bufnr 存在, 则返回 bufnr 的 tab index,
        return tab_index
      end
    end
  end

  --- 如果传入的 bufnr 是 nil, 则 tab_index 是 listed buffer 总数, 即 last listed buffer tab index.
  return tab_index
end

--- if '#' buffer 存在, 而且是 listed, 则 load buffer, 如果 # 不存在, 则跳到 first/last listed buffer.
local function jump_to_listed_buffer()
  local prev_bufnr = vim.fn.bufnr('#')
  local tab_index = 0

  if prev_bufnr > 0 and vim.fn.buflisted(prev_bufnr) == 1 then
    --- prev_buffer 存在, 同时是 listed buffer.
    tab_index = buf_index_in_airline_tab(prev_bufnr)
  else
    --- prev_buffer 不存在, 或者不是 listed buffer.
    tab_index = buf_index_in_airline_tab()
  end

  --- NOTE: load buffer, 最好使用 <Plug>AirlineSelectTabX, 可以避免 NvimTree, term, tagbar 跳转到别的 buffer 上.
  --- 因为 airline#extensions#tabline#keymap_ignored_filetypes 的设置.
  if tab_index > 0 and tab_index < 10 then
    --- 个位数需要前面 +0, eg: <Plug>AirlineSelectTab01, FOR: buffer_idx_mode = 3 ONLY.
    vim.cmd([[execute "normal! \<Plug>AirlineSelectTab0]] .. tab_index .. '"')
  elseif tab_index >= 10 and tab_index < 100 then
    vim.cmd([[execute "normal! \<Plug>AirlineSelectTab]] .. tab_index .. '"')
  --- elseif tab_index >= 100 的情况不考虑.
  end
end

--- 利用 <Plug>AirlineSelectPrev/NextTab 判断是否需要 delete buffer.
local function airline_del_current_buffer()
  local before_select_bufnr = vim.fn.bufnr('%')  --- 获取当前 bufnr()
  vim.cmd([[execute "normal! \<Plug>AirlineSelectPrevTab"]])  -- 使用 airline 跳转到 prev/next buffer
  local after_select_bufnr = vim.fn.bufnr('%')   --- 获取跳转后 bufnr()

  if before_select_bufnr ~= after_select_bufnr then
    --- 如果 before != after 则执行 bdelete #.
    vim.cmd([[bdelete #]])
  else
    --- 如果 before == after, 出现这种情况主要是在 unlisted active buffer.
    --- 跳转到 listed buffer
    jump_to_listed_buffer()
  end
end
-- -- }}}

local opt = { noremap = true, silent = true }
local airline_keymaps = {
  -- airline ---------------------------------------------------------------------------------------
  {'n', '<leader>1', '<Plug>AirlineSelectTab01', opt, 'which_key_ignore'},
  {'n', '<leader>2', '<Plug>AirlineSelectTab02', opt, 'which_key_ignore'},
  {'n', '<leader>3', '<Plug>AirlineSelectTab03', opt, 'which_key_ignore'},
  {'n', '<leader>4', '<Plug>AirlineSelectTab04', opt, 'which_key_ignore'},
  {'n', '<leader>5', '<Plug>AirlineSelectTab05', opt, 'which_key_ignore'},
  {'n', '<leader>6', '<Plug>AirlineSelectTab06', opt, 'which_key_ignore'},
  {'n', '<leader>7', '<Plug>AirlineSelectTab07', opt, 'which_key_ignore'},
  {'n', '<leader>8', '<Plug>AirlineSelectTab08', opt, 'which_key_ignore'},
  {'n', '<leader>9', '<Plug>AirlineSelectTab09', opt, 'which_key_ignore'},
  {'n', '<leader>0', '<Plug>AirlineSelectTab10', opt, 'which_key_ignore'},

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



