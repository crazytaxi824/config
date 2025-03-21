--- `:set wrap` 的情况下使用 gj / gk / g0 / g$ 移动 cursor.

local key_fn = require('utils.keymaps')

--- 使用 gj / gk / g0 / g$ 在 wrap buffer 中移动 cursor.
local function set_cursor_move_in_wrap(bufnr)
  local opts = { buffer = bufnr, silent = true }
  local cursor_move_keymaps = {
    {'n', '<Down>', 'gj', opts, 'which_key_ignore'},
    {'n', '<Up>',   'gk', opts, 'which_key_ignore'},
    {'n', '<Home>', function() key_fn.home.wrap() end, opts, 'which_key_ignore'},  -- g0 相当于 g<Home>
    {'n', '<End>',  'g$', opts, 'which_key_ignore'},  -- g$ 相当于 g<End>

    {'v', '<Down>', 'gj', opts, 'which_key_ignore'},
    {'v', '<Up>',   'gk', opts, 'which_key_ignore'},
    {'v', '<Home>', function() key_fn.home.wrap() end, opts, 'which_key_ignore'},
    {'v', '<End>',  'g$', opts, 'which_key_ignore'},

    {'i', '<Down>', '<C-o>gj', opts, 'which_key_ignore'},
    {'i', '<Up>',   '<C-o>gk', opts, 'which_key_ignore'},
    {'i', '<Home>', function() key_fn.home.wrap() end, opts, 'which_key_ignore'},
    {'i', '<End>',  '<C-o>g$', opts, 'which_key_ignore'},
  }

  key_fn.set(cursor_move_keymaps)
end

--- VVI: 不能直接使用 vim.keymap.del(), 因为如果在 '<Up>' ... 等 key 没有 set() 的情况下, del() 会报错.
--- 而且无法通过 vim.keymap.del(... {silent=true}) 禁止显示 error message.
--- 所以先通过 nvim_buf_get_keymap() 查看 {'<Up>','<Down>','<Home>','<End>'} 是否已经 set(), 如果有则删除.
local function del_cursor_move_in_wrap(bufnr)
  local keys = {'<Up>','<Down>','<Home>','<End>'}
  local modes = {'n', 'v', 'i'}

  --- 也可以使用 :silent! nunmap <buffer> <UP> ... 但无法指定 bufnr.
  for _, mode in ipairs(modes) do
    local buf_keymaps = vim.api.nvim_buf_get_keymap(bufnr, mode)
    for _, key in ipairs(keys) do
      for _, buf_keymap in ipairs(buf_keymaps) do
        if buf_keymap['lhs'] == key then
          vim.api.nvim_buf_del_keymap(bufnr, mode, key)
        end
      end
    end
  end
end

--- buffer 被 `:bdelete` 之后设置的属性会消失.
--- 同一个 file 被 `:bwipeout` 之后再次打开, 会被分配一个新的 bufnr.
--- 缓存文件绝对路径. buffer 被 `:bwipeout` 之后再次打开时继承之前的设置.
--- `:bwipeout` / `:bdelete` 的 buffer 再次打开时 wrap & keymap 设置不变.
local wrap_map = {}  -- cache fullpath, map-like

wrap_map.add = function(bufnr)
  local bufname = vim.api.nvim_buf_get_name(bufnr)  -- full path
  wrap_map[bufname] = true
end

wrap_map.remove = function(bufnr)
  local bufname = vim.api.nvim_buf_get_name(bufnr)  -- full path
  wrap_map[bufname] = nil
end

wrap_map.exist = function(bufnr)
  local bufname = vim.api.nvim_buf_get_name(bufnr)  -- full path
  return wrap_map[bufname]
end

--- command 设置 cursor keymaps
vim.api.nvim_create_user_command("CursorMove", function(params)
  if params.args == "nowrap" then
    del_cursor_move_in_wrap(0)
  elseif params.args == "wrap" then
    set_cursor_move_in_wrap(0)
  end
end, {nargs=1, bar=true})

--- :bwipeout 之后再次打开已经设置为 wrap 的文件时, 自动设置为 wrap.
vim.api.nvim_create_autocmd('BufWinEnter', {
  pattern = {"*"},
  callback = function(params)
    local win_id = vim.api.nvim_get_current_win()
    if vim.api.nvim_win_get_buf(win_id) ~= params.buf then
      Notify("BufWinEnter win_id not match bufnr", "ERROR")
      return
    end

    if vim.wo[win_id].wrap then
      set_cursor_move_in_wrap(params.buf)  -- 设置 keymaps
      wrap_map.add(params.buf)
    elseif wrap_map.exist(params.buf) then
      set_cursor_move_in_wrap(params.buf)  -- 设置 keymaps
      vim.api.nvim_set_option_value('wrap', true, { scope='local', win=win_id })
    end
  end,
  desc = "wrap: set (no)wrap based on cached results",
})

--- :write 保存 [No Name] file 时, 如果文件是 wrap, 则 cache 到 list 中.
vim.api.nvim_create_autocmd('BufWritePre', {
  pattern = {"*"},
  callback = function(params)
    if vim.wo.wrap then
      wrap_map.add(params.buf)  -- 加入到 map
    end
  end,
  desc = "wrap: [No Name] file cache to wrap_list",
})



