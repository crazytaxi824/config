-- choose window to jump, 受到 nvim-tree 的 window_picker 启发.

local M = {}

-- statusline color
local my_win_picker = 'my_window_picker'
vim.api.nvim_set_hl(0, my_win_picker, {
  ctermfg=Colors.black.c, fg=Colors.black.g,
  ctermbg=Colors.magenta.c, bg=Colors.magenta.g,
  bold=true,
})

-- 获取单个 char 的输入
local function get_user_input_char()
  -- Get a single character from the user or input stream.
  -- 按下 'a', vim.fn.getchar() 返回 97.
  local c = vim.fn.getchar()
  while type(c) ~= "number" do
    c = vim.fn.getchar()
  end
  -- vim.fn.nr2char(97) == 'a'
  return vim.fn.nr2char(c)
end

-- choose window to `win_gotoid()`
M.choose = function()
  local win_map = {}  -- cache window id map
  local win_marker = "1234567890ABCDEFGHIJKLMNOPQRSTUVWXYZ"  -- 窗口标识
  local max_win_num = #win_marker
  local win_marker_idx = 1

  local tab_wins = vim.api.nvim_tabpage_list_wins(0)
  for _, win_id in ipairs(tab_wins) do
    -- too many windows
    if win_marker_idx > max_win_num then
      break
    end

    local win_cfg = vim.api.nvim_win_get_config(win_id)

    -- 如果是 normal window 或者 focusable float window 则加入 choose list
    if win_cfg.relative == '' or win_cfg.focusable then
      local key = string.sub(win_marker, win_marker_idx, win_marker_idx)
      -- `:help 'statusline'`
      -- %=   Separation point between alignment sections.
      --      Each section will be separated by an equal number of spaces.
      -- %#   use %#HLname# for highlight group HLname.
      -- %*   clear highlight
      local stl_str = string.format("%%#%s#%%=%s%%=%%*", my_win_picker, key)
      vim.api.nvim_set_option_value('statusline', stl_str, { scope='local', win=win_id })
      -- TODO: remove float window statusline

      win_map[key] = win_id  -- cache win_map
      win_marker_idx = win_marker_idx + 1
    end
  end

  -- VVI: 刷新 statusline 显示.
  vim.cmd.redraw()

  -- prompt choose window
  vim.api.nvim_echo({{"Choose window: ", "Special"}}, false, {})
  local char = string.upper(get_user_input_char())  -- 这里返回的是 string 类型

  -- jump to window
  local win_jump_id = win_map[char]
  if win_jump_id then
    vim.fn.win_gotoid(win_jump_id)
    vim.cmd.normal({ args = {':'}, bang=true })  -- clear command line prompt message
  else
    vim.notify(string.format("Can Not goto window (%s)", char), vim.log.levels.WARN)
  end
end

return M
