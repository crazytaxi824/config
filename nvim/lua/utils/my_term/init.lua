local g = require('utils.my_term.deps.global')
local t_win = require('utils.my_term.deps.term_win')
local t_act = require('utils.my_term.term_actions')
local shell_term = require("utils.my_term.instance_shell")
local console = require('utils.my_term.instance_console')


local M = {}

--- open shell terminal
M.open_shell_term = shell_term.open_shell_term

--- return console terminal
M.console = console.console

--- close all my_term windows
function M.close_all()
  g.range_TermPost(function(term_post)
    t_act.close_win(term_post.id)
  end)
end

--- open all terms which are cached in global_my_term_cache and bufnr is valid.
function M.open_all()
  g.range_TermPost(function(term_post)
    if vim.api.nvim_buf_is_valid(term_post.bufnr) then
      local term_win = vim.fn.bufwinid(term_post.bufnr)
      if term_win < 0 then
        t_win.create_term_win(term_post.bufnr)
      end
    end
  end)
end

--- jobstop(job_id) & :bwipeout all terminal buffers
function M.wipeout_all()
  g.range_TermPost(function(term_post)
    if vim.api.nvim_buf_is_valid(term_post.bufnr) then
      t_act.wipeout(term_post.id)
    end
  end)
end

--- close all first, then open all
function M.toggle_all()
  --- 获取所有的 my_term windows
  local open_winid_list= {}

  g.range_TermPost(function(term_post)
    if vim.api.nvim_buf_is_valid(term_post.bufnr) then
      for _, w in ipairs(vim.fn.win_findbuf(term_post.bufnr)) do
        table.insert(open_winid_list, w)
      end
    end
  end)

  --- 如果有任何 my_term window 是打开的状态, 则全部关闭.
  if #open_winid_list > 0 then
    for _, win_id in ipairs(open_winid_list) do
      vim.api.nvim_win_close(win_id, true)
    end
    return
  end

  --- 如果所有 my_term window 都是关闭状态, 则 open_all()
  M.open_all()
end

return M
