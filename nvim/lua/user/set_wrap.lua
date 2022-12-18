--- <Home> 快捷键先跳到 'g^' first non-blank character of the line, 再跳到 'g0' first character of the line.
function _Home_action_wrap()
  local before_pos = vim.fn.getpos('.')
  vim.cmd('normal! g^')

  local after_pos = vim.fn.getpos('.')
  if before_pos[2] == after_pos[2] and before_pos[3] == after_pos[3] then
    vim.cmd('normal! g0')
  end
end

--- 使用 gj / gk / g0 / g$ 在 wrap buffer 中移动 cursor.
local function set_cursor_move_in_wrap(bufnr)
  local opts = {buffer=bufnr, silent=true}
  local cursor_move_keymaps = {
    {'n', '<Down>', 'gj', opts, 'which_key_ignore'},
    {'n', '<Up>',   'gk', opts, 'which_key_ignore'},
    {'n', '<Home>', _Home_action_wrap, opts, 'which_key_ignore'},  -- g0 相当于 g<Home>
    {'n', '<End>',  'g$', opts, 'which_key_ignore'},  -- g$ 相当于 g<End>

    {'v', '<Down>', 'gj', opts, 'which_key_ignore'},
    {'v', '<Up>',   'gk', opts, 'which_key_ignore'},
    {'v', '<Home>', _Home_action_wrap, opts, 'which_key_ignore'},
    {'v', '<End>',  'g$', opts, 'which_key_ignore'},

    {'i', '<Down>', '<C-o>gj', opts, 'which_key_ignore'},
    {'i', '<Up>',   '<C-o>gk', opts, 'which_key_ignore'},
    {'i', '<Home>', '<C-o><cmd>lua _Home_action_wrap()<CR>', opts, 'which_key_ignore'},
    {'i', '<End>',  '<C-o>g$', opts, 'which_key_ignore'},
  }

  Keymap_set_and_register(cursor_move_keymaps)
end

--- VVI: 不能直接使用 vim.keymap.del(), 因为如果在 '<Up>' ... 等 key 没有 set() 的情况下, del() 会报错.
--- 而且无法通过 vim.keymap.del(... {silent=true}) 禁止显示 error message.
--- 所以先通过 nvim_buf_get_keymap() 查看 {'<Up>','<Down>','<Home>','<End>'} 是否已经 set(), 如果有则删除.
local function del_cursor_move_in_wrap(bufnr)
  local keys = {'<Up>','<Down>','<Home>','<End>'}
  local modes = {'n', 'v', 'i'}

  --- NOTE: 也可以使用 :silent! nunmap <UP>/<Down> ... remove keymaps.
  for _, mode in ipairs(modes) do
    local buf_keymaps = vim.api.nvim_buf_get_keymap(bufnr, mode)
    for _, key in ipairs(keys) do
      for _, buf_keymap in ipairs(buf_keymaps) do
        if buf_keymap.lhs == key then
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
local wrap_list = {}  -- cache fullpath

function wrap_list.add(bufnr)
  local bufname = vim.api.nvim_buf_get_name(bufnr)  -- full path
  wrap_list[bufname] = true
end

function wrap_list.remove(bufnr)
  local bufname = vim.api.nvim_buf_get_name(bufnr)  -- full path
  wrap_list[bufname] = nil
end

function wrap_list.exist(bufnr)
  local bufname = vim.api.nvim_buf_get_name(bufnr)  -- full path
  return wrap_list[bufname]
end

--- 设置 :set wrap 时触发.
vim.api.nvim_create_autocmd('OptionSet', {
  pattern = {"wrap"},
  callback = function(params)
    if vim.wo.wrap then
      wrap_list.add(params.buf)  -- 加入到 list
      set_cursor_move_in_wrap(params.buf)  -- 设置 keymaps
    else
      wrap_list.remove(params.buf)  -- 从 list 中移除
      del_cursor_move_in_wrap(params.buf)  -- 删除 keymaps 设置
    end
  end
})

vim.api.nvim_create_autocmd('BufEnter', {
  pattern = {"*"},
  callback = function(params)
    if wrap_list.exist(params.buf) then
      vim.opt_local.wrap = true  -- setlocal wrap
    end
    if vim.wo.wrap then
      set_cursor_move_in_wrap(params.buf)  -- 设置 keymaps
    end
  end
})

--- 使用 command 手动切换 wrap 设置.
vim.api.nvim_create_user_command("WrapToggle", function()
  vim.opt_local.wrap = not vim.wo.wrap
end, {bang=true, bar=true})



