-- 防抖函数, 短时间内多次执行会自动取消前面的执行
--
---@param fn function
---@param ms integer  time_duration
---@return function|nil
function Debounce(fn, ms)
  -- 闭包变量，用来持久化保存定时器实例
  local timer, err = vim.uv.new_timer()
  if err then
    vim.notify(err, vim.log.levels.ERROR)
    return
  end

  if not timer then
    vim.notify("Debounce timer init failed", vim.log.levels.ERROR)
    return
  end

  return function(...)
    local args = {...}

    -- 核心逻辑：如果定时器正在倒计时，立刻强行取消函数执行
    if timer:is_active() then
      timer:stop()
    end

    -- 重新启动一个新的定时器倒计时
    timer:start(ms, 0, vim.schedule_wrap(function()
      fn(unpack(args))
    end))
  end
end
