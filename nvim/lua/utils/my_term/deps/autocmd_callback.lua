local g = require('utils.my_term.deps.global')

local M = {}

--- autocmd 根据 events 执行 on_open(), on_close()
---
--- @param term_opts MyTermOpts
--- @param term_bufnr integer
function M.autocmd_callback(term_opts, term_bufnr)
  --- 关闭 terminal window 之后再打开时触发 BufWinEnter, 但不会触发 TermOpen.
  --- buffer 离开所有 window 才会触发 BufWinLeave.
  local g_id = vim.api.nvim_create_augroup('my_term_bufnr_' .. term_bufnr, {clear=true})
  vim.api.nvim_create_autocmd({"BufWinEnter", "BufWinLeave"}, {
    group = g_id,
    buffer = term_bufnr,
    callback = function(params)
      --- callback
      if params.event == "BufWinEnter" and term_opts.on_open then
        term_opts.on_open(term_opts, term_bufnr)
        return
      end
      --- callback
      if params.event == "BufWinLeave" and term_opts.on_close then
        term_opts.on_close(term_opts, term_bufnr)
      end
    end,
    desc = "my_term: on_open() & on_close() callback",
  })

  --- 全局保存 my_term window height
  vim.api.nvim_create_autocmd("WinClosed", {
    group = g_id,
    buffer = term_bufnr,
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

  --- auto delete augroup
  vim.api.nvim_create_autocmd("BufWipeout", {
    group = g_id,
    buffer = term_bufnr,
    callback = function(params)
      vim.api.nvim_del_augroup_by_id(g_id)
    end,
    desc = "my_term: delete augroup by id",
  })
end

--- buffer 被 wipeout 的时候自动 jobstop(), 同时 remove terminal object from my_term cache.
---
--- @param term_opts MyTermOpts
--- @param term_bufnr integer
--- @param job_id integer
function M.autocmd_jobstop(term_opts, term_bufnr, job_id)
  local g_id = vim.api.nvim_create_augroup('my_term_job_' .. job_id, {clear=true})
  vim.api.nvim_create_autocmd("BufWipeout", {
    group = g_id,
    buffer = term_bufnr,
    callback = function(params)
      --- stop job in console_exec()
      vim.fn.jobstop(job_id)

      --- remove from cache
      g.delete_TermPost(term_opts.id)

      --- delete augroup
      vim.api.nvim_del_augroup_by_id(g_id)
    end,
    desc = "my_term: jobstop() when buffer wipeout",
  })
end

return M
