local Terminal = require("toggleterm.terminal").Terminal

local M = {}

local cache_bg_terms = {}  -- 缓存 bg_term, map-table: [job_id] = {bg_term, ... }

local bg_term_starting_count = 3001  -- bg_term count 从这个数字开始增长.

M.bg_term_spawn = function(cmd, job)
  local bg_term = Terminal:new({
    --- NOTE: count 在 term job end 之后可以被新的 term 使用, :ls! 中可以看到两个相同 count 的 buffer.
    --- 但是如果有相同 count 的 term job 还未结束时, 新的 term 无法运行.
    count = bg_term_starting_count,

    --- bg_term_spawn 窗口不会打开, 可以设置为在执行完 job 之后自动退出, 即: close_on_exit = true,
    --- NOTE: 但是如果 close_on_exit = true 会导致 bg_term job 结束后 cursor 自动跳转到其他 window.
    close_on_exit = false,

    --- 不允许被 :ToggleTerm 控制.
    hidden = true,

    --- BUG: bg_term:shutdown() 的时候不会触发 BufWipeout, 所以要手动清除 filepath highlight augroup.
    on_exit = function(term)
      vim.api.nvim_del_augroup_by_name('my_filepath_hl_' .. tostring(term.bufnr))
    end
  })

  --- 缓存当前 bg_term
  if cache_bg_terms[job] then
    table.insert(cache_bg_terms[job], bg_term)
  else
    cache_bg_terms[job] = {bg_term}
  end

  --- 设置下一个 bg_term 的 count
  bg_term_starting_count = bg_term_starting_count + 1

  --- 设置 cmd
  bg_term.cmd = cmd

  --- run cmd at background.
  bg_term:spawn()
end

M.bg_term_shutdown_all = function(job)
  for _, bg_term in ipairs(cache_bg_terms[job]) do
    bg_term:shutdown()
  end

  --- 清空 cache
  cache_bg_terms[job] = {}
end

return M
