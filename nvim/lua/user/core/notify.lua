--- 提醒使用 notify 插件或者 vim.notify() 函数
--- msg - string|[]string
--- lvl - string|number. "TRACE"-0, "DEBUG"-1, "INFO"-2, "WARN"-3, "ERROR"-4,
---       `:help vim.log.levels`, `:help notify.setup`
--- opt - table, nvim-notify 插件专用 `:help notify.Options`, title, timeout...
function Notify(msg, lvl, opt)
  --- switch to vim.log.levels
  local l = nil
  if type(lvl) == 'number' then  -- vim.log.levels.ERROR & vim.lsp.log_levels.ERROR 都是 number.
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
    --- NOTE: debug.getinfo() 获取 source filename & function name
    --- debug.getinfo() 第一个参数是 stack level, 如果是 1 则会返回本文件名, 即: 'plugin_utils.lua'.
    --- 如果是 2 则会返回调用 Notify() 的文件名.
    --- source 返回的内容中:
    ---   If source starts with a '@', it means that the function was defined in a file;
    ---   If source starts with a '=', the remainder of its contents describes the source
    ---                                in a user-dependent manner.
    ---   Otherwise, the function was defined in a string where source is that string.
    local call_file = debug.getinfo(2, 'S').source

    local default_title = {}
    if string.sub(call_file, 1, 1) == '@' then
      default_title = {title = vim.fn.fnamemodify(call_file, ':t')}
    end

    opt = opt or {}  -- 确保 opt 是 table, 而不是 nil. 否则无法用于 vim.tbl_deep_extend()
    opt = vim.tbl_deep_extend('force', default_title, opt)

    --- 如果调用本函数时传入了 opt, 则使用传入的值.
    notify.notify(msg, l, opt)

  else
    --- 如果 nvim-notify 不存在则使用 vim.notify()
    if type(msg) == 'table' then
      --- msg should be table array, join message []string with '\n'
      vim.notify(table.concat(msg, '\n'), l)
    else
      vim.notify(msg, l)
    end
  end
end



