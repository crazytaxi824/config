----------------------------------------------------------------------------------------------------
--- NOTE: 全局 keymap 设置
----------------------------------------------------------------------------------------------------
--- Readme ----------------------------------------------------------------------------------------- {{{
--- vim.keymap.set() & vim.keymap.del()
--- vim.api.nvim_set_keymap() & vim.api.nvim_del_keymap()
--- vim.api.nvim_buf_set_keymap() & vim.api.nvim_buf_del_keymap()
--- vim.keymap.set() 可以同时设置多个模式, vim.api.nvim_set_keymap() 每次只能设置一个模式
--- <S-F12> 在 neovim 中是 <F24>, <C-F12> 是 <F36>, <C-S-F12> 是 <F48>. 其他组合键都可以通过 insert 模式打印出来.
-- -- }}}

--- functions for key mapping ---------------------------------------------------------------------- {{{
--- close all terminal window function -------------------------------------------------------------
local function delete_all_terminals()
  local buf_list = {}

  -- 获取所有 bufnr, 判断 bufname 是否匹配 term://*
  for bufnr = vim.fn.bufnr('$'), 1, -1 do
    if string.match(vim.fn.bufname(bufnr), "^term://*") then
      table.insert(buf_list, bufnr)
    end
  end

  if #buf_list > 0 then
    vim.cmd('bdelete! ' .. vim.fn.join(buf_list, ' '))  -- NOTE: 需要使用 '!' 强制退出 term
  end
end

--- for Search Highlight ---------------------------------------------------------------------------
local function hl_search(key)
  local status, errmsg = pcall(vim.cmd, 'normal! ' .. key)
  if not status then
    vim.notify(errmsg, vim.log.levels.ERROR) -- 这里不要使用 notify 插件, 显示错误信息.
    return
  end

  local search_pat = '\\%#' .. vim.fn.getreg('/')
  local blink_time = '40m'
  for _ = 1, 2, 1 do  -- 循环闪烁
    local hl_id = vim.fn.matchadd('HLSearchWord', search_pat, 101)
    vim.cmd[[redraw]]
    vim.cmd('sleep '..blink_time)
    vim.fn.matchdelete(hl_id)
    vim.cmd[[redraw]]
    vim.cmd('sleep '..blink_time)
  end
end

--- word: bool, 是否使用 \<word\>
local function hl_visual_search(key, whole_word)
  --- 利用 register "f
  vim.cmd[[normal! "fy]]  -- copy VISUAL select to register f
  local tmp_search = vim.fn.getreg("f")
  if whole_word then
    vim.fn.setreg('/', '\\<' .. tmp_search .. '\\>')
  else
    vim.fn.setreg('/', tmp_search)
  end
  hl_search(key)
end

--- 删除其他 buffer --------------------------------------------------------------------------------
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
    -- print('bdelete ' .. vim.fn.join(buf_list, ' ')) -- DEBUG
    vim.cmd('bdelete ' .. vim.fn.join(buf_list, ' '))
  end
end

--- [[, ]], jump to previous/next section ---------------------------------------------------------- {{{
local function find_ts_root_node()
  local tsparser_status_ok, tstrees = pcall(vim.treesitter.get_parser, 0)
  if not tsparser_status_ok then
    vim.notify(tstrees, vim.log.levels.WARN)
    return
  end

  for _, tree in ipairs(tstrees:trees()) do
    local tree_root = tree:root()
    if tree_root then
      return tree_root
    end
  end
  return nil
end

local function ts_root_children()
  local root = find_ts_root_node()
  if not root then
    return
  end

  local child_without_comment = {}  -- named child without comment.

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

  return nil
end

local function nodes_around_cursor()
  local root_children = ts_root_children()
  if not root_children then
    return nil
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
        vim.notify("it's first node in this buffer", vim.log.levels.WARN)
      end
    else
      --- jump to cursor current node first line.
      vim.fn.cursor(current_node_lnum+1, 1)
    end
  else
    vim.notify("it's first node in this buffer", vim.log.levels.WARN)
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
      vim.notify("it's last node in this buffer", vim.log.levels.WARN)
    end
  end
end
-- -- }}}

-- -- }}}

-- vim.keymap.set() - option `:help :map-arguments`
-- noremap = { noremap = true },
-- nowait = { nowait = true },
-- silent = { silent = true },
-- buffer = { buffer = true },  -- buffer 有效
-- script = { script = true },
-- expr = { expr = true },
local opt = { noremap = true, silent = true }

--- NOTE: { mode, key, remap, opt, description }  - description for 'which-key'
local keymaps = {
  --- common use -----------------------------------------------------------------------------------
  {'v', '<leader>y', '"*y', opt, 'Copy to system clipboard'},
  {'n', 'D', '"_dd', opt},
  {'v', 'D', '"_x', opt},
  {'n', 'O', 'O<C-c><Down>', opt},

  --- move cursor ----------------------------------------------------------------------------------
  {'n', '<S-Up>', '6gk', opt},
  {'v', '<S-Up>', '6gk', opt},
  {'i', '<S-Up>', '<C-o>6gk', opt},
  {'n', '<S-Down>', '6gj', opt},
  {'v', '<S-Down>', '6gj', opt},
  {'i', '<S-Down>', '<C-o>6gj', opt},

  {'n', '<PageUp>', 'zbH', opt},
  {'v', '<PageUp>', 'zbH', opt},
  {'i', '<PageUp>', '<C-o>zb<C-o>H', opt},
  {'n', '<PageDown>', 'ztL', opt},
  {'v', '<PageDown>', 'ztL', opt},
  {'i', '<PageDown>', '<C-o>zt<C-o>L', opt},

  {'n', '<C-Up>', '3<C-y>', opt},
  {'v', '<C-Up>', '3<C-y>', opt},
  {'i', '<C-Up>', '<C-o>3<C-y>', opt},
  {'n', '<C-Down>', '3<C-e>', opt},
  {'v', '<C-Down>', '3<C-e>', opt},
  {'i', '<C-Down>', '<C-o>3<C-e>', opt},

  {'n', 'G', 'Gzz', opt},  -- put last line in center

  --- Tab ------------------------------------------------------------------------------------------
  {'n', '<Tab>', '<C-w><C-w>', opt},

  --- Search ---------------------------------------------------------------------------------------
  {'n','*',  function() hl_search("*")  end, opt},
  {'n','#',  function() hl_search("#")  end, opt},
  {'n','g*', function() hl_search("g*") end, opt, 'Search <cword> Next'},
  {'n','g#', function() hl_search("g#") end, opt, 'Search <cword> Previous'},

  --- NOTE: "fy - copy VISUAL selected text to register "f"
  --    `let @/ = @f` - copy register "f" to register "/" (search register)
  {'v', '*',  function() hl_visual_search('n', true) end, opt, 'Search <cword> Next'},
  {'v', '#',  function() hl_visual_search('N', true) end, opt, 'Search <cword> Previous'},
  {'v', 'g*', function() hl_visual_search('n') end, opt, 'Search <cword> Next'},
  {'v', 'g#', function() hl_visual_search('N') end, opt, 'Search <cword> Previous'},

  {'n','n', function() hl_search("n") end, opt},
  {'n','N', function() hl_search("N") end, opt},

  --- NOTE: 这里不能使用 silent, 否则 command line 中不显示 '?' 和 '/'
  --- ':echo v:hlsearch' 显示目前 hlsearch 状态.
  {'n', '?', ":nohlsearch<CR>?", {noremap=true}},
  {'n', '/', ":nohlsearch<CR>/", {noremap=true}},

  --- CTRL -----------------------------------------------------------------------------------------
  {'n', '<C-s>', ':update<CR>', opt},
  {'v', '<C-s>', '<C-c>:update<CR>', opt},
  {'i', '<C-s>', '<C-c>:update<CR>', opt},
  --- VVI: <Ctrl-Z> 是危险操作. 意思是 :stop. Suspend vim, 退出到 terminal 界面, 但保留 job.
  --- 需要使用 `jobs -l` 列出 Suspended 列表,
  --- 使用 `fg %1` 恢复 job,
  --- 或者 `kill %1` 终止 job (不推荐, 会留下 .swp 文件).
  {'n', '<C-z>', 'u', opt},
  {'v', '<C-z>', '<Nop>', opt},
  {'i', '<C-z>', '<C-o>u', opt},

  --- fold -----------------------------------------------------------------------------------------
  --- 这里是模拟 vscode keymaps.
  {'n', '<leader>k1', 'zM', opt, "Close all folds"},
  {'n', '<leader>kj', 'zR', opt, "Open all folds"},

  --- <leader> -------------------------------------------------------------------------------------
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
  {'n', '<leader>D', delete_all_other_buffers, opt, 'Close All Other Buffers'},
  --{'n', '<leader>d', 'bdelete', opt, 'Close This Buffer'},  -- 使用 airline 的功能删除 buffer.

  --- 关闭所有其他窗口
  {'n', '<leader>W', '<C-w><C-o>', opt, 'Close All Other Windows'},

  --- NOTE: terminal key mapping 在 "toggleterm.lua" 中设置了.
  {'n', '<leader>T', delete_all_terminals, opt, "Close All Terminal Window"},

  --- 其他 -----------------------------------------------------------------------------------------
  --- ZZ same as `:x`
  {'n', 'ZZ', '<Nop>', opt},
  {'v', 'ZZ', '<Nop>', opt},

  {'n', '[[', jump_to_prev_section, opt, 'Jump to Prev Section'},
  {'n', ']]', jump_to_next_section, opt, 'Jump to Next Section'},
}

--- 这里是设置所有 key mapping 的地方 --------------------------------------------------------------
Keymap_set_and_register(keymaps, {
  key_desc = {k = {name = "Fold Method"}},
  opts = {mode='n', prefix='<leader>'}
})



