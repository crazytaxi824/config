local g = require('myplugins.my_term.deps.global')


local M = {}

--- autocmd 根据 events 执行 on_open(), on_close()
---
---@param term MyTerm
---@param term_bufnr integer
function M.autocmd_callback(term, term_bufnr)
  --- 关闭 terminal window 之后再打开时触发 BufWinEnter, 但不会触发 TermOpen.
  --- buffer 离开所有 window 才会触发 BufWinLeave.
  local g_id = vim.api.nvim_create_augroup('my_term_#buf:' .. term_bufnr, {clear=true})
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
        --- cache myterm window height
        local win_id = vim.api.nvim_get_current_win()
        g.win_height = vim.api.nvim_win_get_height(win_id)

        local callbacks = term:on_close()
        if callbacks then
          --- on_close callbacks
          for _, on_close in ipairs(callbacks) do
            on_close(term, term_bufnr)
          end
        end
      end
    end,
    desc = "my_term: on_open() & on_close() callback",
  })

  --- buffer 被 wipeout 的时候自动 jobstop(), 同时 remove terminal object from my_term cache.
  vim.api.nvim_create_autocmd("BufWipeout", {
    group = g_id,
    once = true,
    buffer = term_bufnr,
    callback = function(args)
      local tp = g.get_TermPost(term.id)
      if tp then
        vim.fn.jobstop(tp.job_id)  --- stop job in console_exec()
        g.delete_TermPost(term.id)  --- remove from cache
      end

      vim.api.nvim_del_augroup_by_id(g_id)
    end,
    desc = "my_term: jobstop() when buffer wipeout",
  })
end

return M
