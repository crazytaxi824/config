-- NOTE: 返回光标所在位置是否已经在最左侧了, 或者光标前一个字符是否为 %s, 即:\n \t \r space ...
--       目的是判断是否需要执行 backspace.
--       true - 本行前一位没有任何字符; nil - 本行前一位有字符.
function CheckBackspace()
  local col = vim.fn.col(".") - 1
  return col == 0 or vim.fn.getline("."):sub(col, col):match("%s")
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

--- 使用 `$ which` 查看插件所需 tools 是否存在 -----------------------------------------------------
function Check_Cmd_Tools(tools)
  local result = {"These Tools should be in the $PATH"}
  local count = 0
  for tool, install in pairs(tools) do
    vim.fn.system('which '.. tool)
    if vim.v.shell_error ~= 0 then
      table.insert(result, tool .. ": " .. install)
      count = count + 1
    end
  end

  if count > 0 then
    Notify(result, "WARN", {title = {"Check_Tools()", "util.lua"}, timeout = false})
  end
end



