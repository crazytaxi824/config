local M = {}

--- for persist my_term window height
--local win_height = 10
M.win_height = math.ceil(vim.o.lines/4)

--- cache all my_term object
--- @type table<integer, MyTermPost>
M.global_my_term_cache = {}

--- 根据 id 返回 MyTermPost.bufnr
---
--- @param term_id integer
--- @return integer|nil
function M.get_bufnr(term_id)
  local t = M.global_my_term_cache[term_id]
  if t then
    return t.bufnr
  end
end

--- 根据 id 返回 MyTermPost.job_id
---
--- @param term_id integer
--- @return integer|nil
function M.get_job_id(term_id)
  local t = M.global_my_term_cache[term_id]
  if t then
    return t.job_id
  end
end

return M
