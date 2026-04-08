local g = require('myplugins.my_term.deps.global')

--- close all other terms except term_id
---
--- @param term_id integer
local function close_others(term_id)
  if not g.get_TermPost(term_id) then
    Notify('term: "' .. term_id .. '" is not exist', "WARN")
    return
  end

  g.range_TermPost(function(term_post)
    if term_post.id ~= term_id then
      term_post:close_win()
    end
  end)
end

--- wipeout term
---
--- @param term_id integer
local function wipeout_term(term_id)
  local tp = g.get_TermPost(term_id)
  if not tp then
    Notify('term: "' .. term_id .. '" is not exist', "WARN")
    return
  end

  if tp:job_status() == -1 then
    Notify("job_id is still running, please use `term:stop()` or `CTRL-C` first.", "WARN", {title="my_term"})
    return
  end

  tp:wipeout()
end

--- wipeout all other terms except term_id
---
--- @param term_id integer
local function wipeout_others(term_id)
  local tp = g.get_TermPost(term_id)
  if not tp then
    Notify('term: "' .. term_id .. '" is not exist', "WARN")
    return
  end

  g.range_TermPost(function(term_post)
    if term_post.bufnr ~= tp.bufnr then
      term_post:wipeout()
    end
  end)
end


--- keymaps: for terminal buffer only --------------------------------------------------------------
local M = {}

--- set keymaps for my_term terminal & output-buffer.
---
--- @param term MyTerm
--- @param term_bufnr integer
function M.set_buf_keymaps(term, term_bufnr)
  local opt = { buffer = term_bufnr, silent = true }
  local keys = {
    {'n', '<leader>tc', function() close_others(term.id) end,   opt, 'my_term: close other my_terms windows'},
    {'n', '<leader>tw', function() wipeout_others(term.id) end, opt, 'my_term: wipeout other my_terms'},
    {'n', 'Q', function() wipeout_term(term.id) end, opt, 'my_term: wipeout current my_term'},
  }
  require('utils.keymaps').set(keys)
end

return M
