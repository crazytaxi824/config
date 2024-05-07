--- choose window to jump, 受到 nvim-tree 的 window_picker 启发.

local M = {}

--- statusline color
local my_win_picker = 'my_window_picker'
vim.api.nvim_set_hl(0, my_win_picker, {
  ctermfg=Colors.black.c, fg=Colors.black.g,
  ctermbg=Color.magenta, bg=Color_gui.magenta,
  bold=true,
})

--- 获取单个 char 的输入
local function get_user_input_char()
  --- Get a single character from the user or input stream.
  --- 按下 'a', vim.fn.getchar() 返回 97.
  local c = vim.fn.getchar()
  while type(c) ~= "number" do
    c = vim.fn.getchar()
  end
  --- vim.fn.nr2char(97) == 'a'
  return vim.fn.nr2char(c)
end

--- choose window
M.choose = function()
  local win_map = {}  -- cache window id map
  local win_marker = "1234567890ABCDEFGHIJKLMNOPQRSTUVWXYZ"  -- 窗口标识.

  local window_ids = vim.api.nvim_tabpage_list_wins(0)
  if #window_ids < 2 then
    vim.notify("There is only 1 window to choose.")
    return
  elseif #window_ids > #win_marker then
    Notify("There are too many windows, (> #win_marker)", "WARN")
    return
  end

  for i, win_id in ipairs(window_ids) do
    local key = string.sub(win_marker,i,i)
    --- `:help 'statusline'`
    --- %=   Separation point between alignment sections.
    ---      Each section will be separated by an equal number of spaces.
    --- %#   use %#HLname# for highlight group HLname.
    vim.api.nvim_set_option_value(
      'statusline',
      '%#' .. my_win_picker .. '#%=%#' .. my_win_picker .. '#' .. key .. '%=',
      {scope='local', win=win_id}
    )

    --- cache win_map
    win_map[key] = win_id
  end

  vim.cmd('redraw')  -- VVI: 刷新 statusline 显示.

  --- prompt choose window
  vim.notify("Choose window:")
  local char = string.upper(get_user_input_char())  -- 这里返回的是 string 类型

  --- jump to window
  local win_jump_id = win_map[char]
  if win_jump_id then
    vim.fn.win_gotoid(win_jump_id)
  end

  --- clear command line prompt message.
  vim.cmd("normal! :")
end

return M
