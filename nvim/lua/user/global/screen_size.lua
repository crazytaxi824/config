--- 测量整个 screen 尺寸的方法:
--- `:tabnew` 新建一个 tab 没有任何 window 分割.
--- 获取 winheight(winnr()) & winwidth(winnr())
--- `:tabclose` 关闭当前 tab.
function Get_screen_size()
  -- nvim_tabpage_list_wins()
  vim.cmd('tabnew')

  local tabpage_id = vim.api.nvim_get_current_tabpage()
  local noname_buf = vim.api.nvim_get_current_buf()  -- tabnew 会创建一个 [No Name] buffer.

  --- 获取 screen height & width
  local h = vim.api.nvim_win_get_height(0)
  local w = vim.api.nvim_win_get_width(0)

  --- close new tab & bwipeout noname buffer
  local tabpagenr = vim.api.nvim_tabpage_get_number(tabpage_id)
  vim.cmd('tabclose ' .. tabpagenr .. " | bwipeout " .. noname_buf)

  return h, w
end



