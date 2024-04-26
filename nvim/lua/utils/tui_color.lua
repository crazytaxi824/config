local M = {}

local hex = {'00', '5F', '87', 'AF', 'D7', 'FF'}

local function gray_scale(num)
  local gray = (num-232)*10+8
  return '#' .. string.rep(string.format('%x', gray), 3, '')
end

local function color_cube(num)
    local t = (num-16)
    local r = math.floor(t/36)
    local gr = t%36

    local g = math.floor(gr/6)
    local b = gr%6
    return '#' .. hex[r+1] .. hex[g+1] .. hex[b+1]
end

M.hex_color = function(num)
  --- 排除 ctermbg=NONE
  if type(num) ~= 'number' then
    return
  end

  if num < 16 or num > 255 then
    -- vim.notify(num .. ' is error color!', vim.log.levels.ERROR)
    return
  end

  if num > 15 and num < 232 then
    return color_cube(num)
  end

  if num > 231 then
    return gray_scale(num)
  end
end

return M
