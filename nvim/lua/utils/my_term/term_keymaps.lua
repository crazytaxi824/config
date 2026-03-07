local g = require('utils.my_term.deps.global')
local t_act = require('utils.my_term.term_actions')

--- close all other terms except term_id
---
--- @param term_id integer
local function close_others(term_id)
  local tp = g.get_TermPost(term_id)
  if not tp then
    Notify('term: "' .. term_id .. '" is not exist', "WARN")
    return
  end

  g.range_TermPost(function(term_post)
    if term_post.bufnr ~= tp.bufnr then
      t_act.close_win(term_post.id)
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

  if t_act.job_status(tp.id) == -1 then
    Notify("job_id is still running, please use `term:stop()` or `CTRL-C` first.", "WARN", {title="my_term"})
    return
  end

  t_act.wipeout(tp.id)
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
      t_act.wipeout(term_post.id)
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
    {'n', 'q', '<cmd>q<CR>', opt, 'my_term: close current my_term window'},
    {'n', 'Q', function() wipeout_term(term.id) end, opt, 'my_term: wipeout current my_term'},
  }
  require('utils.keymaps').set(keys)
end

return M
