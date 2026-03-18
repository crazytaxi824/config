local winvar = "my_winbar"


--- @param win_id integer
local function win_bar(win_id)
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
    win_bar(win_id)
  end
})


--- Debug
function WinbarLine()
  local win_id = vim.api.nvim_get_current_win()
  print(win_id, vim.inspect(vim.w[win_id][winvar]))
end
