local M = {}

--- for persist my_term window height
--local win_height = 10
M.win_height = math.ceil(vim.o.lines/4)

--- cache all my_term object
--- @type table<integer, MyTermPost>
M.global_my_term_cache = {}

return M
