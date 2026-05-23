local g = require('myplugins.my_term.deps.global')


local M = {}

-- close all my_term windows
function M.close_all()
  g.range_TermPost(function(term_post)
    term_post:close_win()
  end)
end

-- open all terms which are cached in global_my_term_cache and bufnr is valid.
function M.open_all()
  g.range_TermPost(function(term_post)
    if vim.fn.bufwinid(term_post.bufnr) < 0 then
      term_post:open_win()
    end
  end)
end

-- jobstop(job_id) & :bwipeout all terminal buffers
function M.wipeout_all()
  ---@type MyTermPost[]
  local tps = {}
  g.range_TermPost(function(term_post)
    table.insert(tps, term_post)
  end)

  for _, _tp in ipairs(tps) do
    _tp:wipeout()
  end
end

-- close all first, then open all
function M.toggle_all()
  -- 获取所有的 my_term windows
  local open_winid_list= {}

  g.range_TermPost(function(term_post)
    if vim.api.nvim_buf_is_valid(term_post.bufnr) then
      for _, w in ipairs(vim.fn.win_findbuf(term_post.bufnr)) do
        table.insert(open_winid_list, w)
      end
    end
  end)

  -- 如果有任何 my_term window 是打开的状态, 则全部关闭.
  if not vim.tbl_isempty(open_winid_list) then
    for _, win_id in ipairs(open_winid_list) do
      vim.api.nvim_win_close(win_id, true)
    end
    return
  end

  -- 如果所有 my_term window 都是关闭状态, 则 open_all()
  M.open_all()
end


return M
