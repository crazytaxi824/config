local g = require('utils.my_term.deps.global')
local t_win = require('utils.my_term.deps.term_win')


local M = {}

--- open terminal window
---
--- @param term_id integer
--- @return integer|nil win_id
function M.open_win(term_id)
  local tp = g.get_TermPost(term_id)
  if not tp then
    return
  end

  local term_win = vim.fn.bufwinid(tp.bufnr)
  if term_win > 0 then
    --- 如果有 window 正在显示该 term buffer, 则跳转到该 window.
    if vim.fn.win_gotoid(term_win) == 0 then
      error('vim cannot win_gotoid(' .. term_win .. ')')
    end

    return term_win
  else
    --- 如果没有任何 window 显示该 terminal 则创建一个新的 window, 然后加载该 buffer.
    return t_win.create_term_win(tp.bufnr)
  end
end

--- close all windows which displays this term buffer.
---
--- @param term_id integer
function M.close_win(term_id)
  local tp = g.get_TermPost(term_id)
  if not tp then
    return
  end

  for _, w in ipairs(vim.fn.win_findbuf(tp.bufnr)) do
    vim.api.nvim_win_close(w, true)
  end
end

--- 检查 terminal 运行情况.
---
--- @param term_id integer
--- @return integer|nil job_status
function M.job_status(term_id)
  local tp = g.get_TermPost(term_id)
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
  local tp = g.get_TermPost(term_id)
  if not tp then
    return
  end

  --- VVI: 保险起见先 jobstop() 再 wipeout buffer, 否则 job 可能还在继续执行.
  vim.fn.jobstop(tp.job_id)

  --- require('utils.my_term.deps.autocmd_callback').autocmd_jobstop()
  --- buffer 被 wipeout 的时候自动 jobstop(), 同时 remove terminal object from cache.
  if vim.api.nvim_buf_is_valid(tp.bufnr) then
    vim.api.nvim_buf_delete(tp.bufnr, {force=true})  -- :bwipeout
  end

  --- remove from cache
  g.delete_TermPost(term_id)
end

return M
