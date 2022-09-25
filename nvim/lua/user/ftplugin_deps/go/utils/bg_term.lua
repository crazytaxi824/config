local M = {}

local cache_bg_terms = {}  -- 缓存 bg_term

local bg_term_count = 3001  -- bg_term count 从这个数字开始增长.

M.bg_term_spawn = function(cmd)
  local term_status_ok, term = pcall(require, "toggleterm.terminal")
  if not term_status_ok then
    Notify("toggleterm.terminal cannot be loaded", "ERROR")
    return
  end

  local bg_term = term.Terminal:new({
    --- NOTE: count 在 term job end 之后可以被新的 term 使用, :ls! 中可以看到两个相同 count 的 buffer.
    --- 但是如果有相同 count 的 term job 还未结束时, 新的 term 无法运行.
    count = bg_term_count,

    --- bg_term_spawn 窗口不打开, 不显示任何信息, 可以在执行完 job 之后自动退出.
    close_on_exit = true,

    --- 不允许被 :ToggleTerm 控制.
    hidden = true,
  })

  --- 缓存当前 bg_term
  table.insert(cache_bg_terms, bg_term)

  --- 设置下一个 bg_term 的 count
  bg_term_count = bg_term_count + 1

  --- 设置 cmd
  bg_term.cmd = cmd
  --- NOTE: 如果使用 :new() 生成了新的实例, 需要重新缓存新生成的实例, 否则无法 open() / close() ...
  --exec_term = exec_term:new(vim.tbl_deep_extend('error', exec_opts, {cmd = cmd}))
  --my_terminals[exec_term_id] = exec_term  -- VVI: 缓存新的 exec terminal

  --- run cmd
  bg_term:spawn()
end

M.bg_term_shutdown_all = function()
  for _, bg_term in ipairs(cache_bg_terms) do
    bg_term:shutdown()
  end

  --- 清空 cache
  cache_bg_terms = {}
end

return M
