--- NOTE: 全局 keymap 设置
--- Readme ----------------------------------------------------------------------------------------- {{{
--- vim.keymap.set() & vim.keymap.del()
--- vim.api.nvim_set_keymap() & vim.api.nvim_del_keymap()
--- vim.api.nvim_buf_set_keymap() & vim.api.nvim_buf_del_keymap()
--- vim.keymap.set() 可以同时设置多个模式, vim.api.nvim_set_keymap() 每次只能设置一个模式
--- <S-F12> 在 neovim 中是 <F24>, <C-F12> 是 <F36>, <C-S-F12> 是 <F48>. 其他组合键都可以通过 insert 模式打印出来.
-- -- }}}
--- 常用组合键前缀:
---   - <leader>
---   - g
---   - z
---   - i_CTRL-R | c_CTRL-R  NOTE: 在 insert/command 模式下 paste register 到 file/command line.
---                          eg: insert/command 模式下输入 <CTRL-R>0 相当于 normal 模式下 "0p
---                          后面接 = 可以填入 expr. eg: insert/command 模式下输入 <CTRL-R>=100-80, 得到 20.
---   - "  - select register for paste. 可以用在 y,p,d,x 等复制/剪切/粘贴功能上. eg: "*y
---   - @  - execute content of register, like macro.
---   - [ | ]  - navigation in file
---
--- 常用固定组合键:
---   - i_CTRL-X_CTRL-O  - omni completion
---   - i_CTRL-O  - 用于在 insert mode 中执行一个 command 然后回到 insert mode.
---   - i_CTRL-C | v_CTRL-C  - insert/visual 退回到 normal mode.
---   - v_CTRL-G  - 切换 visual/select mode, select mode 是 visual 的一个子模式, 多用于代码补全的默认值.

--- functions for key mapping ---------------------------------------------------------------------- {{{
--- wipeout all terminals --------------------------------------------------------------------------
--- NOTE: close all terminals' window; stop all terminals' job; wipeout all terminals' buffer.
local function wipeout_all_terminals()
  local buf_list = {}

  -- 获取所有 bufnr, 判断 bufname 是否匹配 term://*
  for bufnr = vim.fn.bufnr('$'), 1, -1 do
    if string.match(vim.fn.bufname(bufnr), "^term://*") then
      table.insert(buf_list, bufnr)
    end
  end

  if #buf_list > 0 then
    vim.cmd('bw! ' .. table.concat(buf_list, ' '))  -- NOTE: 需要使用 '!' 强制结束 job, 并且关闭 term 窗口.
  end
end

--- delete all other buffers -----------------------------------------------------------------------
--- NOTE: `:bdelete` 本质是 unlist buffer. 即: listed = 0
local function delete_all_other_buffers()
  local buf_list = {}

  --- NOTE: nvimtree, tagbar, terminal 不会被关闭, 因为他们是 unlisted.
  for _, bufinfo in ipairs(vim.fn.getbufinfo({buflisted = 1})) do  -- 获取 listed buffer
    if bufinfo.changed == 0    -- 没有修改后未保存的内容.
      and bufinfo.hidden == 1  -- 是隐藏状态的 buffer. 如果是 active 状态(即: 正在显示的 buffer, 例如当前 buffer), 不会被删除.
    then
      table.insert(buf_list, bufinfo.bufnr)
    end
  end

  if #buf_list > 0 then
    vim.cmd('bdelete ' .. table.concat(buf_list, ' '))
  end
end

--- for Search Highlight --------------------------------------------------------------------------- {{{
--- 在当前 search result 前放置 search_sign.
local my_search_sign = {
  --- {group} as a namespace for {id}, thus two groups can use the same IDs.
  group = "MySearchSignGroup",
  sign = "MySearchSign",
  id = 10010,
  text = "⚲",  -- 类似 icon, ⌕☌⚲⚯
}
--- define my_search_sign
vim.fn.sign_define(my_search_sign.sign, {text=my_search_sign.text, texthl="IncSearch", numhl="IncSearch"})

--- 缓存 { win_id=win_getid(), hl_id=matchadd() }, for vim.fn.matchdelete()
local search_hl_cache

local function hl_search(key)
  local status, errmsg = pcall(vim.cmd, 'normal! ' .. key)
  if not status then
    vim.notify(errmsg, vim.log.levels.ERROR) -- 这里不要使用 notify 插件, 显示错误信息.
    return
  end

  --- VVI: 删除之前的 highlight. 必须删除, 然后重新 highlight.
  if search_hl_cache then
    vim.fn.matchdelete(search_hl_cache.hl_id, search_hl_cache.win_id)
  end
  vim.fn.sign_unplace(my_search_sign.group)  -- clear my_search_sign

  --- NOTE: `:help /ordinary-atom`
  --- `\%#` 意思是从 cursor 所在位置开始寻找 match.
  --- `\c`  意思是 ignore-case.
  local search_pattern = '\\c\\%#' .. vim.fn.getreg('/')
  local hl_id = vim.fn.matchadd('IncSearch', search_pattern, 101)

  --- NOTE: place my_search_sign
  local cur_pos = vim.fn.getpos('.')  -- [bufnum, lnum, col, off]
  vim.fn.sign_place(my_search_sign.id, my_search_sign.group, my_search_sign.sign, vim.fn.bufnr(),
    {lnum=cur_pos[2], priority=109})

  --- 缓存数据
  search_hl_cache = {hl_id = hl_id, win_id = vim.fn.win_getid()}
end

--- NOTE: 这里必须使用 global function, 因为还没找到使用 vim.api 执行 '/' 的方法.
function _Delete_search_hl()
  --- 删除之前的 highlight
  if search_hl_cache then
    --- NOTE: 如果 win 已经关闭 (win_id 不存在), 则不能使用 matchdelete(win_id), 否则报错.
    local win_info = vim.fn.getwininfo(search_hl_cache.win_id)
    if #win_info > 0 then
      vim.fn.matchdelete(search_hl_cache.hl_id, search_hl_cache.win_id)
    end

    search_hl_cache = nil  -- clear cache
  end

  vim.fn.sign_unplace(my_search_sign.group)  -- clear my_search_sign
  vim.cmd[[nohlsearch]]

  --- NOTE: 以下方法无法进行 'incsearch'. 但是可以使函数变成 local function.
  --local search_input = vim.fn.input('/')
  --vim.cmd('/' .. search_input)
end

--- word: bool, 是否使用 \<word\>
local function hl_visual_search(key, whole_word)
  --- 利用 register "f
  vim.cmd[[normal! "fy]]  -- copy VISUAL select to register 'f'
  local tmp_search = vim.fn.getreg("f")
  if whole_word then
    vim.fn.setreg('/', '\\<' .. tmp_search .. '\\>')
  else
    vim.fn.setreg('/', tmp_search)
  end
  hl_search(key)
end

-- -- }}}

--- [[, ]], jump to previous/next section ---------------------------------------------------------- {{{
local function parse_buffer_lang()
  --- 利用 nvim-treesitter 获取 buffer lang.
  local nvim_ts_ok, nvim_ts_parsers = pcall(require, "nvim-treesitter.parsers")
  if nvim_ts_ok then
    return nvim_ts_parsers.get_buf_lang(0)  -- 如果 nvim-treesitter 存在, 则 parse
  else
    return vim.bo.filetype  -- 如果 nvim-treesitter 不存在, 则使用 filetype
  end
end

local function find_ts_root_node()
  local lang = parse_buffer_lang()
  if not lang or lang == '' then
    vim.notify('treesitter-parser for current buffer is not available', vim.log.levels.WARN)
    return
  end

  --- vim.treesitter.get_parser(bufnr, lang)
  --- "bufnr", 0 current buffer
  --- "lang", default filetype.
  local tsparser_status_ok, tsparser = pcall(vim.treesitter.get_parser, 0, lang)
  if not tsparser_status_ok then
    vim.notify(tsparser, vim.log.levels.WARN)
    return
  end

  --- tsparser:parse() return a {table} of immutable trees
  local tstree = tsparser:parse()[1]
  if tstree then
    return tstree:root()
  end
end

local function ts_root_children()
  local root = find_ts_root_node()
  if not root then
    return
  end

  local child_without_comment = {}  -- cache named child without comment.

  local child_count = root:named_child_count()
  for i = 0, child_count-1 do
    local child = root:named_child(i)
    if child:type() ~= "comment" then
      table.insert(child_without_comment, child)
    end
  end

  if #child_without_comment>0 then
    return child_without_comment
  end
end

local function nodes_around_cursor()
  local root_children = ts_root_children()
  if not root_children then
    return
  end

  local cursor_lnum = vim.fn.getpos('.')[2]  -- {bufnr, line, col, bytes}, table_list/array, 从 1 开始计算.

  for index in ipairs(root_children) do
    local node_line = root_children[index]:start()  -- {line, col, bytes}, 从 0 开始计算.
    if cursor_lnum < node_line+1 then
      return {
        prev = root_children[index-2],
        current = root_children[index-1],
        next = root_children[index],
        cursor_lnum = cursor_lnum,
      }
    end
  end

  -- cursor at last node
  return {
    prev = root_children[#root_children-1],
    current = root_children[#root_children],
    next = nil,
    cursor_lnum = cursor_lnum,
  }
end

local function jump_to_prev_section()
  local result = nodes_around_cursor()
  if not result then
    return
  end

  if result.current then
    --- NOTE: cursor line < first non comment node 的情况下 result.current = nil.
    local current_node_lnum = result.current:start()

    if result.cursor_lnum == current_node_lnum+1 then
      -- cursor 在 current_node 第一行.
      if result.prev then
        local prev_node_lnum = result.prev:start()
        vim.fn.cursor(prev_node_lnum+1, 1)
      else
        --- 自己是 first node's first line 的情况
        vim.notify("it's first node in this buffer", vim.log.levels.INFO)
      end
    else
      --- jump to cursor current node first line.
      vim.fn.cursor(current_node_lnum+1, 1)
    end
  else
    vim.notify("it's first node in this buffer", vim.log.levels.INFO)
  end
end

local function jump_to_next_section()
  local result = nodes_around_cursor()
  if not result then
    return
  end

  if result.next then
    local next_node_lnum = result.next:start()
    vim.fn.cursor(next_node_lnum+1, 1)
  else
    --- NOTE: cursor_line > last node's last line 的情况.
    local current_node_last_line = result.current:end_()
    if result.cursor_lnum < current_node_last_line+1 then
      -- jump to last node's last line
      vim.fn.cursor(current_node_last_line+1, 1)
    else
      --- 自己在 last node's last line 的情况
      vim.notify("it's last node in this buffer", vim.log.levels.INFO)
    end
  end
end
-- -- }}}

-- -- }}}

--- vim.keymap.set() - option `:help :map-arguments`
--- { noremap = true },
--- { nowait = true },
--- { silent = true },
--- { buffer = true },  -- buffer 有效
--- { script = true },
--- { expr = true },
--- { desc = "key_description" }
local opt = { noremap = true, silent = true }

--- NOTE: { mode, key, remap, opt, description }  - description for 'which-key'
local keymaps = {
  --- common use -----------------------------------------------------------------------------------
  {'n', 'D', '"_dd', opt, "delete line No Copy"},
  {'v', 'D', '"_x', opt, "delete line No Copy"},
  {'n', 'O', 'O<C-c><Down>', opt, "add new line above cursor"},

  --- move cursor ----------------------------------------------------------------------------------
  {'n', '<S-Up>', '6gk', opt, 'which_key_ignore'},
  {'v', '<S-Up>', '6gk', opt, 'which_key_ignore'},
  {'i', '<S-Up>', '<C-o>6gk', opt, 'which_key_ignore'},
  {'n', '<S-Down>', '6gj', opt, 'which_key_ignore'},
  {'v', '<S-Down>', '6gj', opt, 'which_key_ignore'},
  {'i', '<S-Down>', '<C-o>6gj', opt, 'which_key_ignore'},

  {'n', '<PageUp>', 'zbH', opt, 'which_key_ignore'},
  {'v', '<PageUp>', 'zbH', opt, 'which_key_ignore'},
  {'i', '<PageUp>', '<C-o>zb<C-o>H', opt, 'which_key_ignore'},
  {'n', '<PageDown>', 'ztL', opt, 'which_key_ignore'},
  {'v', '<PageDown>', 'ztL', opt, 'which_key_ignore'},
  {'i', '<PageDown>', '<C-o>zt<C-o>L', opt, 'which_key_ignore'},

  {'n', '<C-Up>', '3<C-y>', opt, 'which_key_ignore'},
  {'v', '<C-Up>', '3<C-y>', opt, 'which_key_ignore'},
  {'i', '<C-Up>', '<C-o>3<C-y>', opt, 'which_key_ignore'},
  {'n', '<C-Down>', '3<C-e>', opt, 'which_key_ignore'},
  {'v', '<C-Down>', '3<C-e>', opt, 'which_key_ignore'},
  {'i', '<C-Down>', '<C-o>3<C-e>', opt, 'which_key_ignore'},

  {'n', 'G', 'Gzz', opt, 'which_key_ignore'},  -- put last line in center

  --- Tab ------------------------------------------------------------------------------------------
  {'n', '<Tab>', '<C-w><C-w>', opt, 'which_key_ignore'},  -- 切换到另一个窗口.

  --- Search ---------------------------------------------------------------------------------------
  {'n','*',  function() hl_search("*")  end, opt, 'search: \\<cword\\> Forward'},
  {'n','#',  function() hl_search("#")  end, opt, 'search: \\<cword\\> Backward'},
  {'n','g*', function() hl_search("g*") end, opt, 'search: <cword> Forward'},
  {'n','g#', function() hl_search("g#") end, opt, 'search: <cword> Backward'},

  --- NOTE: "fy - copy VISUAL selected text to register "f"
  --    `let @/ = @f` - copy register "f" to register "/" (search register)
  {'v', '*',  function() hl_visual_search('n', true) end, opt, 'search: \\<cword\\> Forward'},
  {'v', '#',  function() hl_visual_search('N', true) end, opt, 'search: \\<cword\\> Backward'},
  {'v', 'g*', function() hl_visual_search('n') end, opt, 'search: <cword> Forward'},
  {'v', 'g#', function() hl_visual_search('N') end, opt, 'search: <cword> Backward'},

  {'n','n', function() hl_search("n") end, opt, 'search: Forward'},
  {'n','N', function() hl_search("N") end, opt, 'search: Backward'},

  --- NOTE: 这里不能使用 silent, 否则 command line 中不显示 '?' 和 '/'
  --- ':echo v:hlsearch' 显示目前 hlsearch 状态.
  {'n', '?', "<cmd>lua _Delete_search_hl()<CR>?", {noremap=true}, 'which_key_ignore'},
  {'n', '/', "<cmd>lua _Delete_search_hl()<CR>/", {noremap=true}, 'which_key_ignore'},

  --- CTRL -----------------------------------------------------------------------------------------
  --- 可以使用的 Ctrl keymap --- {{{
  --- <C-q> 容易退出程序, 不要使用. 默认 Visual-Block mode
  --- <C-s> = remap save file.
  --- <C-z> = remap undo, 默认 ":stop" 中止 job.
  --- <C-j> = remap toggle Comments, 默认相当于 j (cursor down)
  --- <C-t> 默认 tag stack. NOTE: 还未 remap.
  --- <C-g> 默认 print current filename. NOTE: 还未 remap.
  -- -- }}}
  {'n', '<C-s>', ':update<CR>', opt, 'which_key_ignore'},
  {'v', '<C-s>', '<C-c>:update<CR>', opt, 'which_key_ignore'},
  {'i', '<C-s>', '<C-c>:update<CR>', opt, 'which_key_ignore'},

  --- VVI: <Ctrl-Z> 是危险操作. 意思是 :stop. Suspend vim, 退出到 terminal 界面, 但保留 job.
  --- 需要使用 `jobs -l` 列出 Suspended 列表,
  --- 使用 `fg %1` 恢复 job,
  --- 或者 `kill %1` 终止 job (不推荐, 会留下 .swp 文件).
  {'n', '<C-z>', 'u', opt, 'which_key_ignore'},
  {'v', '<C-z>', '<Nop>', opt, 'which_key_ignore'},
  {'i', '<C-z>', '<C-o>u', opt, 'which_key_ignore'},

  --- <leader> -------------------------------------------------------------------------------------
  --- copy / paste
  --- NOTE: 如果是 linux server 系统, 则没有系统级 clipboard, 则无法使用该 copy 方式.
  ---       在没有 cilpboard 的情况下如果想要粘贴 register 中的内容到 command line,
  ---       需要使用 |:<CTRL-R> {register}|. `:help c_CTRL-R`.
  {'v', '<leader>y', '"*y', opt, 'Copy to system clipboard'},

  --- fold code, 这里是模拟 vscode keymaps.
  {'n', '<leader>k1', 'zM', opt, "Close all folds"},
  {'n', '<leader>kj', 'zR', opt, "Open all folds"},

  --- <leader> keymaps 默认会显示在 which-key list 中, 所以需要使用 'which_key_ignore' 阻止显示
  {'n', '<leader>"', 'viw<C-c>`>a"<C-c>`<i"<C-c>', opt, 'which_key_ignore'},
  {'n', "<leader>'", "viw<C-c>`>a'<C-c>`<i'<C-c>", opt, 'which_key_ignore'},
  {'n', '<leader>`', 'viw<C-c>`>a`<C-c>`<i`<C-c>', opt, 'which_key_ignore'},
  {'n', '<leader>*', 'viw<C-c>`>a*<C-c>`<i*<C-c>', opt, 'which_key_ignore'},
  {'n', '<leader>_', 'viw<C-c>`>a_<C-c>`<i_<C-c>', opt, 'which_key_ignore'},
  {'n', '<leader>|', 'viw<C-c>`>a|<C-c>`<i|<C-c>', opt, 'which_key_ignore'},
  {'n', '<leader>$', 'viw<C-c>`>a$<C-c>`<i$<C-c>', opt, 'which_key_ignore'},
  {'n', '<leader>{', 'viw<C-c>`>a}<C-c>`<i{<C-c>', opt, 'which_key_ignore'},
  {'n', '<leader>}', 'viw<C-c>`>a}<C-c>`<i{<C-c>', opt, 'which_key_ignore'},
  {'n', '<leader>[', 'viw<C-c>`>a]<C-c>`<i[<C-c>', opt, 'which_key_ignore'},
  {'n', '<leader>]', 'viw<C-c>`>a]<C-c>`<i[<C-c>', opt, 'which_key_ignore'},
  {'n', '<leader>(', 'viw<C-c>`>a)<C-c>`<i(<C-c>', opt, 'which_key_ignore'},
  {'n', '<leader>)', 'viw<C-c>`>a)<C-c>`<i(<C-c>', opt, 'which_key_ignore'},
  {'n', '<leader>>', 'viw<C-c>`>a><C-c>`<i<<C-c>', opt, 'which_key_ignore'},
  {'n', '<leader><lt>', 'viw<C-c>`>a><C-c>`<lt>i<lt><C-c>', opt, 'which_key_ignore'},  -- '<' 使用 <lt> 代替.

  {'v', '<leader>"', '<C-c>`>a"<C-c>`<i"<C-c>v`><right><right>', opt, 'which_key_ignore'},
  {'v', "<leader>'", "<C-c>`>a'<C-c>`<i'<C-c>v`><right><right>", opt, 'which_key_ignore'},
  {'v', '<leader>`', '<C-c>`>a`<C-c>`<i`<C-c>v`><right><right>', opt, 'which_key_ignore'},
  {'v', '<leader>*', '<C-c>`>a*<C-c>`<i*<C-c>v`><right><right>', opt, 'which_key_ignore'},
  {'v', '<leader>_', '<C-c>`>a_<C-c>`<i_<C-c>v`><right><right>', opt, 'which_key_ignore'},
  {'v', '<leader>|', '<C-c>`>a|<C-c>`<i|<C-c>v`><right><right>', opt, 'which_key_ignore'},
  {'v', '<leader>$', '<C-c>`>a$<C-c>`<i$<C-c>v`><right><right>', opt, 'which_key_ignore'},
  {'v', '<leader>{', '<C-c>`>a}<C-c>`<i{<C-c>v`><right><right>', opt, 'which_key_ignore'},
  {'v', '<leader>}', '<C-c>`>a}<C-c>`<i{<C-c>v`><right><right>', opt, 'which_key_ignore'},
  {'v', '<leader>[', '<C-c>`>a]<C-c>`<i[<C-c>v`><right><right>', opt, 'which_key_ignore'},
  {'v', '<leader>]', '<C-c>`>a]<C-c>`<i[<C-c>v`><right><right>', opt, 'which_key_ignore'},
  {'v', '<leader>(', '<C-c>`>a)<C-c>`<i(<C-c>v`><right><right>', opt, 'which_key_ignore'},
  {'v', '<leader>)', '<C-c>`>a)<C-c>`<i(<C-c>v`><right><right>', opt, 'which_key_ignore'},
  {'v', '<leader>>', '<C-c>`>a><C-c>`<i<<C-c>v`><right><right>', opt, 'which_key_ignore'},
  {'v', '<leader><lt>', '<C-c>`>a><C-c>`<lt>i<lt><C-c>v`><right><right>', opt, 'which_key_ignore'},  -- '<' 使用 <lt> 代替.

  --- 关闭所有其他 buffers
  {'n', '<leader>Da', delete_all_other_buffers, opt, 'buffer: Close All Other Buffers'},
  --{'n', '<leader>d', 'bdelete', opt, 'buf: Close Current Buffer'},

  --- 关闭所有其他窗口
  {'n', '<leader>W', '<C-w><C-o>', opt, 'win: Close All Other Windows'},

  --- NOTE: terminal key mapping 在 "toggleterm.lua" 中设置了.
  {'n', '<leader>T', wipeout_all_terminals, opt, "terminal: Wipeout All Terminals"},

  --- 其他 -----------------------------------------------------------------------------------------
  --- ZZ same as `:x`
  {'n', 'ZZ', '<Nop>', opt},
  {'v', 'ZZ', '<Nop>', opt},

  {'n', '[[', jump_to_prev_section, opt, 'Jump to Prev Section'},
  {'n', ']]', jump_to_next_section, opt, 'Jump to Next Section'},

  --- 切换 buffer, NOTE: 目前使用 airline <Plug>AirlineSelectPrevTab 进行 buffer 切换
  --{'n', '<lt>', ':bprevious<CR>', opt, 'go to previous buffer'},
  --{'n', '>', ':bnext<CR>', opt, 'go to next buffer'},
}

--- 这里是设置所有 key mapping 的地方 --------------------------------------------------------------
Keymap_set_and_register(keymaps, {
  key_desc = {
    k = {name = "Fold Method"},
    D = {name = "Close Buffers"},
  },
  opts = {mode='n', prefix='<leader>'}
})

--- for key desc only
Keymap_set_and_register({}, {
  key_desc = {
    ['['] = {name="Section Jump"},
    [']'] = {name="Section Jump"},
    g = {name="g"},
    z = {name="z"},
    ['<leader>'] = {name="\\"},
    Y = {'copy whole line without "\\n"'},
    ['<C-L>'] = {'which_key_ignore'},
  },
  opts = {mode='n'},
})



