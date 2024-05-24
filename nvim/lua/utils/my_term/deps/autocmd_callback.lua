local g = require('utils.my_term.deps.global')

local M = {}

M.autocmd_callback = function(term_obj)
  --- 关闭 terminal window 之后再打开时触发 BufWinEnter, 但不会触发 TermOpen.
  --- buffer 离开所有 window 才会触发 BufWinLeave.
  local g_id = vim.api.nvim_create_augroup('my_term_bufnr_' .. term_obj.bufnr, {clear=true})
  vim.api.nvim_create_autocmd({"BufWinEnter", "BufWinLeave"}, {
    group = g_id,
    buffer = term_obj.bufnr,
    callback = function(params)
      --- callback
      if params.event == "BufWinEnter" and term_obj.on_open then
        g.exec_callbacks(term_obj.on_open, term_obj)
        return
      end
      --- callback
      if params.event == "BufWinLeave" and term_obj.on_close then
        g.exec_callbacks(term_obj.on_close, term_obj)
      end
    end,
    desc = "my_term: on_open() & on_close() callback",
  })

  vim.api.nvim_create_autocmd("WinClosed", {
    group = g_id,
    buffer = term_obj.bufnr,
    callback = function(params)
      --- persist window height
      --- NOTE: 在 WinClosed event 中, params.file & params.match 都是 win_id, 数据类型是 string.
      local win_id = tonumber(params.match)
      if win_id then
        g.win_height = vim.api.nvim_win_get_height(win_id)
      end
    end,
    desc = "my_term: persist window height",
  })

  --- delete augroup
  vim.api.nvim_create_autocmd("BufWipeout", {
    group = g_id,
    buffer = term_obj.bufnr,
    callback = function(params)
      --- stop job in buf_job_output()
      vim.fn.jobstop(term_obj.job_id)

      --- remove from global_my_term_cache
      g.global_my_term_cache[term_obj.id] = nil

      vim.api.nvim_del_augroup_by_id(g_id)
    end,
    desc = "my_term: delete augroup by id",
  })
end

return M
