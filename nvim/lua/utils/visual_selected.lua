--- 获取 visual selected word.

local M = {}

--- trim: boolean
M.visual_selected = function(trim)
  --- NOTE: getpos("'<") 和 getpos("'>") 必须在 normal 模式执行,
  --- 即: <C-c> 从 visual mode 退出后再执行以下函数.
  local startpos = vim.fn.getpos("'<")  -- [bufnum, lnum, col, off]
  local endpos = vim.fn.getpos("'>")

  local lines = vim.fn.getline("'<", "'>")
  if type(lines) ~= 'table' then
    return
  end

  local v_selected = ''
  if startpos[2] == endpos[2] then
    --- same line
    v_selected = string.sub(vim.fn.getline("'<"), startpos[3], endpos[3])
    if trim then
      v_selected = vim.trim(v_selected)
    end
  else
    --- multi-lines
    lines[1] = string.sub(lines[1], startpos[3])
    lines[#lines] = string.sub(lines[#lines], 0, endpos[3])

    if trim then
      for i in ipairs(lines) do
        lines[i] = vim.trim(lines[i])
      end
    end

    v_selected = table.concat(lines, '')
  end

  vim.notify(v_selected)

  return v_selected
end

return M
