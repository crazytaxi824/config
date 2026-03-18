local winvar = "my_winbar"


local function list_remove_value(list, val)
  for i, v in ipairs(list) do
    if v == val then
      table.remove(list, i)
      return
    end
  end
end


--- @param win_id integer
local function set_winbar(win_id)
  local str = ''
  local win_bufs = vim.w[win_id][winvar] or {}
  for _, buf in ipairs(win_bufs) do
    local bufname = vim.fs.basename(vim.api.nvim_buf_get_name(buf))
    if str == '' then
      str = bufname
    else
      str = str .. " │ " .. bufname
    end
  end
  vim.api.nvim_set_option_value('winbar', str, { scope='local', win=win_id })
end


local gid = vim.api.nvim_create_augroup(winvar, { clear = true })
vim.api.nvim_create_autocmd({"BufWinEnter"}, {
  group = gid,
  callback = function(args)
    local win_id = vim.api.nvim_get_current_win()
    local win_bufs = vim.w[win_id][winvar] or {}
    if not vim.list_contains(win_bufs, args.buf) then
      table.insert(win_bufs, args.buf)
    end
    vim.w[win_id][winvar] = win_bufs
    set_winbar(win_id)
  end
})


--- 从所有的 window buffer list 中删除 buf
vim.api.nvim_create_autocmd({"BufUnload"}, {
  group = gid,
  callback = function(args)
    local buf_wins = vim.fn.win_findbuf(args.buf)
    for _, win_id in ipairs(buf_wins) do
      local win_bufs = vim.w[win_id][winvar] or {}
      list_remove_value(win_bufs, args.buf)
      vim.w[win_id][winvar] = win_bufs
      set_winbar(win_id)
    end
  end
})


--- Debug
function WinbarLine()
  local win_id = vim.api.nvim_get_current_win()
  print(win_id, vim.inspect(vim.w[win_id][winvar]))
end
