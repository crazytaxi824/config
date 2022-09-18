--- 使用 gj / gk / g0 / g$ 在 wrap buffer 中移动 cursor.
local function set_cursor_move_in_wrap(bufnr)
  local opts = {buffer=bufnr, silent=true}
  local cursor_move_keymaps = {
    {{'n','v'}, '<Down>', 'gj', opts, 'display lines downward'},
    {{'n','v'}, '<Up>',   'gk', opts, 'display lines upward'},
    {{'n','v'}, '<Home>', 'g0', opts, 'first char of line'},  -- g0 相当于 g<Home>
    {{'n','v'}, '<End>',  'g$', opts, 'last char of line'},  -- g$ 相当于 g<End>

    {'i', '<Down>', '<C-o>gj', opts, 'display lines downward'},
    {'i', '<Up>',   '<C-o>gk', opts, 'display lines upward'},
    {'i', '<Home>', '<C-o>g0', opts, 'first char of line'},
    {'i', '<End>',  '<C-o>g$', opts, 'last char of line'},
  }

  Keymap_set_and_register(cursor_move_keymaps)
end

--- VVI: 不能直接使用 vim.keymap.del(), 因为如果在 '<Up>' ... 等 key 没有 set() 的情况下, del() 会报错.
--- 而且无法通过 vim.keymap.del(... {silent=true}) 禁止显示 error message.
--- 所以先通过 nvim_buf_get_keymap() 查看 {'<Up>','<Down>','<Home>','<End>'} 是否已经 set(), 如果有则删除.
local function del_cursor_move_in_wrap(bufnr)
  local keys = {'<Up>','<Down>','<Home>','<End>'}
  local modes = {'n', 'v', 'i'}

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

--- 通过 bufnr 给所有显示该 buffer 的 window 设置 wrap.
local function bufnr_set_wrap_to_all_windows(bufnr, on_off)
  --- 通过 bufinfo 的 windows 属性获取 {win_id}
  local buf_win_ids = vim.fn.getbufinfo(bufnr)[1].windows

  for _, win_id in ipairs(buf_win_ids) do
    vim.wo[win_id].wrap = on_off  -- setlocal wrap to specific window
  end
end

--- NOTE: 缓存 :WrapToggle 的 filepath / bufnr -----------------------------------------------------
--- 同一个 file 被 :bwipeout 之后再次打开, 会被分配一个新的 bufnr.
--- 如果 bufname() ~= '' 则缓存文件绝对路径. buffer 被 :bwipeout 之后再次打开时继承之前的设置.
--- 如果 bufname() == '' 则缓存 bufnr. 没有名字的 buffer 只能通过 bufnr 来缓存.
--- :bwipeout / :bdelete 的 buffer 再次打开时 wrap & keymap 设置不变.
local wrap_list = {}

--- 使用 command 手动切换 wrap 设置.
vim.api.nvim_create_user_command("WrapToggle", function()
  local bufnr = vim.fn.bufnr()
  local bufname = vim.api.nvim_buf_get_name(bufnr)  -- full path

  --- 如果 bufname() ~= '' 则缓存文件绝对路径. buffer 被 :bwipeout 之后再次打开时继承之前的设置.
  --- 如果 bufname() == '' 则缓存 bufnr. 没有名字的 buffer 只能通过 bufnr 来缓存.
  local buf
  if bufname == '' then
    buf = bufnr  -- [No Name] buffer, 缓存 bufnr
  else
    buf = bufname  -- 缓存文件的绝对路径
  end

  if not vim.wo.wrap then
    --- setlocal wrap to window
    bufnr_set_wrap_to_all_windows(bufnr, true)  -- vim.wo.wrap = true

    --- cache filepath/bufnr
    wrap_list[buf] = true

    --- 设置 keymaps
    set_cursor_move_in_wrap(bufnr)
  else
    --- setlocal nowrap to window
    bufnr_set_wrap_to_all_windows(bufnr, false)  -- vim.wo.wrap = false

    --- delete cache
    wrap_list[buf] = nil

    --- 删除 keymaps 设置
    del_cursor_move_in_wrap(bufnr)
  end
end, {bar=true})

--- BufEnter 在同一个 window 中切换 buffer 时重新设置 wrap, 因为 wrap 是 local to window.
--- WinEnter 同一个 buffer 在不同的 window 中显示时重新设置 wrap.
vim.api.nvim_create_autocmd({"BufEnter", "WinEnter"}, {
  pattern = {"*"},
  callback = function(params)
    --- 如果 bufname() ~= '' 则缓存文件绝对路径. buffer 被 :bwipeout 之后再次打开时继承之前的设置.
    --- 如果 bufname() == '' 则缓存 bufnr. 没有名字的 buffer 只能通过 bufnr 来缓存.
    --- NOTE: params.file 不一定是文件的绝对路径. [No Name] buffer 的 params.file == ''.
    local buf
    if params.file == '' then  -- [No Name] buffer
      buf = params.buf  -- [No Name] buffer, 缓存 bufnr
    else
      buf = vim.fn.fnamemodify(params.file, ":p")
    end

    if wrap_list[buf] then
      --vim.wo.wrap = true
      bufnr_set_wrap_to_all_windows(params.buf, true)
      set_cursor_move_in_wrap(params.buf)
    else
      --vim.wo.wrap = false
      bufnr_set_wrap_to_all_windows(params.buf, false)
      del_cursor_move_in_wrap(params.buf)
    end
  end
})



