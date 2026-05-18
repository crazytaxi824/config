local g = require('myplugins.my_term.deps.global')


local M = {}

--- autocmd 根据 events 执行 on_open(), on_close()
---
--- @param term MyTerm
--- @param term_bufnr integer
function M.autocmd_callback(term, term_bufnr)
  --- 关闭 terminal window 之后再打开时触发 BufWinEnter, 但不会触发 TermOpen.
  --- buffer 离开所有 window 才会触发 BufWinLeave.
  local g_id = vim.api.nvim_create_augroup('my_term_bufnr_' .. term_bufnr, {clear=true})
  vim.api.nvim_create_autocmd({"BufWinEnter", "BufWinLeave"}, {
    group = g_id,
    buffer = term_bufnr,
    callback = function(args)
      if args.event == "BufWinEnter" then
        local callbacks = term:on_open()
        if callbacks then
          for _, on_open in ipairs(callbacks) do
            on_open(term, term_bufnr)
          end
        end
      elseif args.event == "BufWinLeave" then
        local callbacks = term:on_close()
        if callbacks then
          for _, on_close in ipairs(callbacks) do
            on_close(term, term_bufnr)
          end
        end
      end
    end,
    desc = "my_term: on_open() & on_close() callback",
  })

  --- 全局保存 my_term window height
  vim.api.nvim_create_autocmd("WinClosed", {
    group = g_id,
    buffer = term_bufnr,
    callback = function(args)
      --- persist window height
      --- NOTE: 在 WinClosed event 中, params.file & params.match 都是 win_id, 数据类型是 string.
      local win_id = tonumber(args.match)
      if win_id then
        g.win_height = vim.api.nvim_win_get_height(win_id)
      end
    end,
    desc = "my_term: persist window height",
  })

  --- auto delete augroup
  vim.api.nvim_create_autocmd("BufWipeout", {
    group = g_id,
    once = true,
    buffer = term_bufnr,
    callback = function(args)
      vim.api.nvim_del_augroup_by_id(g_id)
    end,
    desc = "my_term: delete augroup by id",
  })
end

--- buffer 被 wipeout 的时候自动 jobstop(), 同时 remove terminal object from my_term cache.
---
--- @param term_id integer
--- @param term_bufnr integer
function M.autocmd_jobstop(term_id, term_bufnr)
  local g_id = vim.api.nvim_create_augroup('my_term_post_' .. term_id, {clear=true})
  vim.api.nvim_create_autocmd("BufWipeout", {
    group = g_id,
    once = true,
    buffer = term_bufnr,
    callback = function(args)
      local tp = g.get_TermPost(term_id)
      if tp then
        --- stop job in console_exec()
        vim.fn.jobstop(tp.job_id)

        --- remove from cache
        g.delete_TermPost(term_id)
      end

      --- delete augroup
      vim.api.nvim_del_augroup_by_id(g_id)
    end,
    desc = "my_term: jobstop() when buffer wipeout",
  })
end

return M
