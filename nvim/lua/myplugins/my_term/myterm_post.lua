local g = require('myplugins.my_term.deps.global')
local t_win = require('myplugins.my_term.deps.term_win')


--- 继承 MyTerm
--- @class MyTermPost: MyTerm
--- @field bufnr integer
--- @field job_id integer
local MyTermPost = setmetatable({}, { __index = require("myplugins.my_term.myterm") })  -- 继承 MyTerm
MyTermPost.__index = MyTermPost


--- @param myterm MyTerm
--- @param bufnr integer
--- @param job_id integer
--- @return MyTermPost
function MyTermPost.from(myterm, bufnr, job_id)
  --- @cast myterm MyTermPost
  myterm.bufnr = bufnr
  myterm.job_id = job_id

  --- @type MyTermPost
  local self = setmetatable(myterm, MyTermPost)
  return self
end

--- @return integer|nil win_id
function MyTermPost:open_win()
  local term_win = vim.fn.bufwinid(self.bufnr)
  if term_win > 0 then
    --- 如果有 window 正在显示该 term buffer, 则跳转到该 window.
    if vim.fn.win_gotoid(term_win) == 0 then
      error('vim cannot win_gotoid(' .. term_win .. ')')
    end

    return term_win
  else
    --- 如果没有任何 window 显示该 terminal 则创建一个新的 window, 然后加载该 buffer.
    return t_win.create_term_win(self.bufnr)
  end
end

function MyTermPost:close_win()
  for _, w in ipairs(vim.fn.win_findbuf(self.bufnr)) do
    if vim.api.nvim_win_is_valid(w) then
      vim.api.nvim_win_close(w, true)
    end
  end
end

--- @return integer|nil job_status
function MyTermPost:job_status()
  --- VVI: jobwait({job_id}, 0) 如果没有 0 则会同步阻塞整个 neovim
  return vim.fn.jobwait({self.job_id}, 0)[1]
end

function MyTermPost:wipeout()
  --- NOTE: 保险起见先 jobstop() 再 wipeout buffer, 否则 job 可能还在继续执行.
  vim.fn.jobstop(self.job_id)

  --- require('myplugins.my_term.deps.autocmd_callback').autocmd_jobstop()
  --- buffer 被 wipeout 的时候自动 jobstop(), 同时 remove terminal object from cache.
  if vim.api.nvim_buf_is_valid(self.bufnr) then
    vim.api.nvim_buf_delete(self.bufnr, {force=true})  -- :bwipeout
  end

  --- remove from cache
  g.delete_TermPost(self.id)
end

return MyTermPost
