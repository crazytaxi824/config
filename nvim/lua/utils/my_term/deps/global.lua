local M = {}

--- for persist my_term window height
--local win_height = 10
M.win_height = math.ceil(vim.o.lines/4)

--- map-like table { job_id:term_obj }
---@type table<integer, MyTerm>
M.global_my_term_cache = {}

--- 判断 terminal bufnr 是否存在, 是否有效
---@param bufnr? integer
---@return boolean?
function M.term_buf_exist(bufnr)
  return bufnr and vim.api.nvim_buf_is_valid(bufnr)
end

return M
