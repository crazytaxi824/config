local g = require('utils.my_term.deps.global')
local t_win = require('utils.my_term.deps.term_win')

local M = {}

--- open terminal window
---
--- @param term_id integer
--- @return integer|nil win_id
function M.open_win(term_id)
  local tp = g.global_my_term_cache[term_id]
  if not tp then
    return
  end

  local term_wins = vim.fn.getbufinfo(tp.bufnr)[1].windows
  if #term_wins > 0 then
    --- 如果有 window 正在显示该 term buffer, 则跳转到该 window.
    if vim.fn.win_gotoid(term_wins[1]) == 0 then
      error('vim cannot win_gotoid(' .. term_wins[1] .. ')')
    end

    return term_wins[1]
  else
    --- 如果没有任何 window 显示该 terminal 则创建一个新的 window, 然后加载该 buffer.
    return t_win.create_term_win(tp.bufnr)
  end
end

--- close all windows which displays this term buffer.
---
--- @param term_id integer
function M.close_win(term_id)
  local tp = g.global_my_term_cache[term_id]
  if not tp then
    return
  end

  local term_wins = vim.fn.getbufinfo(tp.bufnr)[1].windows
  for _, w in ipairs(term_wins) do
    vim.api.nvim_win_close(w, true)
  end
end

--- 检查 terminal 运行情况.
---
--- @param term_id integer
--- @return integer|nil job_status
function M.job_status(term_id)
  local tp = g.global_my_term_cache[term_id]
  if not tp then
    return
  end

  --- `:help jobwait()`
  return vim.fn.jobwait({tp.job_id}, 0)[1]
end

--- wipeout term buffer and jobstop(job_id)
---
--- @param term_id integer
function M.wipeout(term_id)
  local tp = g.global_my_term_cache[term_id]
  if not tp then
    return
  end

  --- VVI: 保险起见先 jobstop() 再 wipeout buffer, 否则 job 可能还在继续执行.
  vim.fn.jobstop(tp.job_id)

  --- wipeout term buffer
  --- require('utils.my_term.deps.autocmd_callback').autocmd_jobstop()
  --- buffer 被 wipeout 的时候自动 jobstop(), 同时 remove terminal object from cache.
  vim.api.nvim_buf_delete(tp.bufnr, {force=true})

  --- remove from cache
  g.global_my_term_cache[term_id] = nil
end

return M
