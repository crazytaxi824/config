local M = {}

local hex_slice = {'00', '5F', '87', 'AF', 'D7', 'FF'}
local eight_bit_slice = {0, 95, 135, 175, 215, 255}

--- r*36 + g*6 + b + 16 = 8bit color
local function nearest_8bit(num)
  for i = 1, 5, 1 do
    if num >= eight_bit_slice[i] and num <= eight_bit_slice[i+1] then
      if num - eight_bit_slice[i] <= eight_bit_slice[i+1] - num then
        return i-1
      else
        return i
      end
    end
  end
end

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
    return '#' .. hex_slice[r+1] .. hex_slice[g+1] .. hex_slice[b+1]
end

M.to_hex_color = function(num)
  --- 排除 ctermfg=NONE ctermbg=NONE
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

--- hex color without start '#'
M.to_nearest_8bit_color = function(hex)
  local r = tonumber(string.sub(hex,1,2), 16)
  local g = tonumber(string.sub(hex,3,4), 16)
  local b = tonumber(string.sub(hex,5,6), 16)

  --- NOTE: calculate nearest 8bit color
  --- r*36 + g*6 + b + 16 = 8bit color
  return nearest_8bit(r)*36+nearest_8bit(g)*6+nearest_8bit(b) + 16
end

--- get color by name then calculate to 8bit color
M.to_nearest_8bit_color_by_name = function(hl)
  local c = vim.api.nvim_get_hl(0, {name=hl})

  if c.fg and not c.ctermfg then
    local hex = string.format('%06x', c.fg)
    c.ctermfg = M.to_nearest_8bit_color(hex)
  end

  if c.bg and not c.ctermbg then
    local hex = string.format('%06x', c.bg)
    c.ctermbg = M.to_nearest_8bit_color(hex)
  end

  vim.api.nvim_set_hl(0, hl, c)
end

return M
