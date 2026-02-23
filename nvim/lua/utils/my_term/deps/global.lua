local M = {}

--- for persist my_term window height
--local win_height = 10
M.win_height = math.ceil(vim.o.lines/4)

--- map-like table { job_id: MyTerm }
---@type table<integer, MyTerm>
M.global_my_term_cache = {}

return M
