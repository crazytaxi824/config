local M = {}

--- 设置 bg_term for 
local bg_terms = {}

M.bg_term_spawn = function(cmd)
  local term_status_ok, term = pcall(require, "toggleterm.terminal")
  if not term_status_ok then
    Notify("toggleterm.terminal cannot be loaded", "ERROR")
    return
  end

  local bg_term = term.Terminal:new({
    count = 3001,  -- NOTE: 所有 bg_term 使用同一个 count.
    hidden = true,
    close_on_exit = false,  -- VVI: 必须要, 否则在 :shutdown() 的时候会因为 close_on_exit 开始退出, 导致 :open() 在执行下一个命令的过程中 terminal 退出.
    on_open = function(t)
      -- print(vim.inspect(t))
      -- table.insert(bg_terms_bufnr, t.bufnr)  -- cache bufnr
      table.insert(bg_terms, t)  -- cache terminal
    end
  })

  --- 设置 cmd
  bg_term.cmd = cmd
  --- NOTE: 如果使用 :new() 生成了新的实例, 需要重新缓存新生成的实例, 否则无法 open() / close() ...
  --exec_term = exec_term:new(vim.tbl_deep_extend('error', exec_opts, {cmd = cmd}))
  --my_terminals[exec_term_id] = exec_term  -- VVI: 缓存新的 exec terminal

  --- run cmd
  bg_term:spawn()
end

M.bg_term_shutdown_all = function ()
  for _, bg_term in ipairs(bg_terms) do
    bg_term:shutdown()
  end
  bg_terms = {}
end

return M
