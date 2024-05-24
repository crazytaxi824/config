local M = {}

--- for persist my_term window height
--local win_height = 10
M.win_height = math.ceil(vim.o.lines/4)

--- map-like table { job_id:term_obj }
M.global_my_term_cache = {}

--- 判断 terminal bufnr 是否存在, 是否有效
M.term_buf_exist = function(bufnr)
  if bufnr and vim.api.nvim_buf_is_valid(bufnr) then
    return true
  end
end

--- on_exit = function | table{fn1, fn2, ...}
M.exec_callbacks = function(callbacks, ...)
  if not callbacks then
    return
  end

  local typ = type(callbacks)
  if typ == 'function' then
    callbacks(...)
  elseif typ == 'table' then
    for _, cb in ipairs(callbacks) do
      cb(...)
    end
  end
end

return M
