-- NOTE: 返回光标所在位置是否已经在最左侧了, 或者光标前一个字符是否为 %s, 即:\n \t \r space ...
--       目的是判断是否需要执行 backspace.
--       true - 本行前一位没有任何字符; nil - 本行前一位有字符.
function CheckBackspace()
  local col = vim.fn.col(".") - 1
  return col == 0 or vim.fn.getline("."):sub(col, col):match("%s")
end

--- 获取所有 window 的 filetype 和 syntax ---------------------------------------------------------- {{{
--    `:help winnr()`   " winnr()    - 当前 window_index
--                      " winnr('#') - prev_window_index
--                      " winnr('$') - total_window_number
--
--    `:help winheight()`   " winheight(win_index)   - 获取 window height
--                          " winheight(winnr())     - 当前 window height
--                          " winheight('%')         - 当前 window height, 和上面一样
--
--    `:help winwidth()`   " 获取 window 宽度, 使用方法和 winheight() 一样. winwidth(win_index)
--
--    `:help win_getid(win_index)`   " 通过 window_index 获取 window_id
--    `:help getwinvar(win_index)`   " 获取 window 变量
--    `:help getwininfo(win_id)`     " VVI: 获取 window 所有信息
--    `:help getwininfo()`           " VVI: 获取所有 window 的所有信息
--    `:help win_gettype(win_id)`    " 获取 window 类型
-- -- }}}
function GetWinInfo()
  local infos = {}

  for win_index = 1, vim.fn.winnr('$'), 1 do
    local win_id = vim.fn.win_getid(win_index)

    local info = {
      win_index = win_index,
      win_id = win_id,
      win_height = vim.fn.winheight(win_index),
      win_width = vim.fn.winwidth(win_index),
      filetype = vim.fn.getwinvar(win_index, '&filetype'),  -- print(vim.bo.filetype) 打印当前 win filetype.
      syntax = vim.fn.getwinvar(win_index, '&syntax'),
      buftype = vim.fn.getwinvar(win_index, '&buftype'),
      win_type = vim.fn.win_gettype(win_id),
    }
    table.insert(infos, info)
  end

  print(vim.inspect(infos))
end

--- 去掉 string prefix suffix whitespace -----------------------------------------------------------
function TrimString(str)
  return string.match(str, "^%s*(.-)%s*$")
end

--- 提醒使用 notify 插件或者 vim.notify() 函数 -----------------------------------------------------
--- msg - string|[]string
--- lvl - string|number. "TRACE"-0, "DEBUG"-1, "INFO"-2, "WARN"-3, "ERROR"-4, `:help vim.log.levels`, `:help notify.setup`
--- opt - table, nvim-notify 插件专用 `:help notify.Options`, title, timeout...
function Notify(msg, lvl, opt)
  --- switch to vim.log.levels
  local l = nil
  if type(lvl) == 'number' then
    l = lvl
  elseif type(lvl) == 'string' then
    if string.upper(lvl) == "TRACE" then
      l = 0
    elseif string.upper(lvl) == "DEBUG" then
      l = 1
    elseif string.upper(lvl) == "INFO" then
      l = 2
    elseif string.upper(lvl) == "WARN" then
      l = 3
    elseif string.upper(lvl) == "ERROR" then
      l = 4
    end
  end

  local notify_status_ok, notify = pcall(require, "notify")
  if notify_status_ok then
    notify(msg, l, opt)
  else
    if type(msg) == 'table' then
      --- msg should be table array, join message []string with '\n'
      vim.notify(vim.fn.join(msg, '\n'), l)
    else
      vim.notify(msg, l)
    end
  end
end

--- TEST: test functions ---






