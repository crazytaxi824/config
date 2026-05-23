-- 将 log lvl string 转成 integer
--
---@param lvl? string|integer  "TRACE"-0, "DEBUG"-1, "INFO"-2, "WARN"-3, "ERROR"-4, "OFF"-5
---@return integer
local function log_level(lvl)
  if type(lvl) == 'string' then
    lvl = string.upper(lvl)
    if lvl == "TRACE" then
      return vim.log.levels.TRACE
    elseif lvl == "DEBUG" then
      return vim.log.levels.DEBUG
    elseif lvl == "INFO" then
      return vim.log.levels.INFO
    elseif lvl == "WARN" then
      return vim.log.levels.WARN
    elseif lvl == "ERROR" then
      return vim.log.levels.ERROR
    elseif lvl == "OFF" then
      return vim.log.levels.OFF
    end
  elseif type(lvl) == 'number' then
    return lvl
  end

  -- default log level
  return vim.log.levels.INFO
end

-- 使用 nvim-notify 插件
--
---@param msg string|string[]
---@param lvl integer
---@param opt? {title: string|string[], timeout: number|boolean}  `:help notify.Options`
---@return boolean
local function nvim_notify(msg, lvl, opt)
  local notify_status_ok, notify = pcall(require, "notify")
  if not notify_status_ok then
    return false
  end

  -- NOTE: debug.getinfo() 获取 source filename & function name
  -- debug.getinfo() 第一个参数是 stack level, 如果是 1 则会返回本文件名, 即: 'notify.lua'.
  -- 如果是 2 则会返回调用 Notify() 的文件名.
  -- source 返回的内容中:
  --   If source starts with a '@', it means that the function was defined in a file;
  --   If source starts with a '=', the remainder of its contents describes the source
  --                                in a user-dependent manner.
  --   Otherwise, the function was defined in a string where source is that string.
  local call_file = debug.getinfo(2, 'S').source

  local default_title = {}
  if string.sub(call_file, 1, 1) == '@' then
    default_title = {title = vim.fs.basename(call_file)}
  else
    default_title = {title = call_file}
  end

  opt = opt or {}  -- 确保 opt 是 table, 而不是 nil. 否则无法用于 vim.tbl_deep_extend()
  opt = vim.tbl_deep_extend('force', default_title, opt)

  -- 如果调用本函数时传入了 opt, 则使用传入的值.
  notify.notify(msg, lvl, opt)
  return true
end

-- 提醒使用 notify 插件或者 vim.notify() 函数
--
---@param msg string|string[]
---@param lvl? string|integer  "TRACE"-0, "DEBUG"-1, "INFO"-2, "WARN"-3, "ERROR"-4, "OFF"-5
---@param opt? {title: string|string[], timeout: number|boolean}  `:help notify.Options`
function Notify(msg, lvl, opt)
  local log_lvl = log_level(lvl)

  -- nvim-notify 存在
  if nvim_notify(msg, log_lvl, opt) then
    return
  end

  -- 如果 nvim-notify 不存在则使用 vim.notify()
  if type(msg) == 'table' then
    -- msg should be table array, join message []string with '\n'
    vim.notify(table.concat(msg, '\n'), log_lvl)
  else
    vim.notify(msg, log_lvl)
  end
end



