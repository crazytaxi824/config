local M = {}

--- for persist my_term window height
--local win_height = 10
M.win_height = math.ceil(vim.o.lines/4)

--- cache all my_term object
--- @type table<integer, MyTermPost>
local global_my_term_cache = {}


--- 根据 id 返回 MyTermPost
---
--- @param term_id integer
--- @return MyTermPost|nil
function M.get_TermPost(term_id)
  return global_my_term_cache[term_id]
end

--- 缓存 MyTermPost
---
--- @param term_id integer
--- @param termpost MyTermPost
function M.set_TermPost(term_id, termpost)
  global_my_term_cache[term_id] = termpost
end

--- 删除 MyTermPost
---
--- @param term_id any
function M.delete_TermPost(term_id)
  global_my_term_cache[term_id] = nil
end

--- for range MyTermPost dict
---
--- @param callback fun(term_post: MyTermPost): boolean|nil
function M.range_TermPost(callback)
  for term_id, term_post in pairs(global_my_term_cache) do
    if callback(term_post) == false then
      return  -- break for-loop
    end
  end
end

--- debug ------------------------------------------------------------------------------------------
function Get_all_myterms()
  vim.print(global_my_term_cache)
end

return M
