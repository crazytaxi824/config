--- 有序的 set
--- @class OrderedSet<T>
--- @field private _index table<T, integer>
--- @field private _list  T[]
local OrderedSet = {}
OrderedSet.__index = OrderedSet

--- @generic T
--- @return OrderedSet<T>
function OrderedSet.new()
  --- @type OrderedSet<T>
  local s = setmetatable({
    _index = {},  -- dict<value, integer> 维护 index
    _list  = {},
  }, OrderedSet)
  return s
end

--- @param value T
function OrderedSet:append(value)
  if not self._index[value] then
    table.insert(self._list, value)
    self._index[value] = #self._list
  end
end

--- @param value T
function OrderedSet:remove_single(value)
  local idx = self._index[value]
  if not idx then return end

  table.remove(self._list, idx)
  self._index[value] = nil
  -- 必须更新被删除元素之后的所有索引（这是有序 Set 的代价）
  for i = idx, #self._list do
    self._index[self._list[i]] = i
  end
end

--- @param value T
function OrderedSet:remove_left(value)
  local idx = self._index[value]
  if not idx then return end

  --- 按顺序 copy 右侧 items
  local new_list = {}
  local new_index = {}
  for i = idx, #self._list, 1 do
    local item = self._list[i]
    local new_i = #new_list + 1

    new_list[new_i] = item
    new_index[item] = new_i
  end
  self._list = new_list
  self._index = new_index
end


--- @param value T
function OrderedSet:remove_right(value)
  local idx = self._index[value]
  if not idx then return end

  --- 按顺序 copy 左侧 items
  local new_list = {}
  local new_index = {}
  for i = 1, idx, 1 do
    local item = self._list[i]

    new_list[i] = item
    new_index[item] = i
  end
  self._list = new_list
  self._index = new_index
end


--- @param value T
function OrderedSet:remove_others(value)
  local idx = self._index[value]
  if not idx then return end

  self._list = { value }
  self._index = { [value] = 1 }
end


--- @param values T[]
function OrderedSet:remove_multi(values)
  if #values < 1 then
    return
  end

  local to_remove = {}
  for _, value in ipairs(values) do
    if self._index[value] then
      to_remove[value] = true
      self._index[value] = nil
    end
  end

  local new_list = {}
  for _, item in ipairs(self._list) do
    if not to_remove[item] then
      new_list[#new_list + 1] = item
      self._index[item] = #new_list
    end
  end

  self._list = new_list
end

--- @param value T
--- @return boolean
function OrderedSet:has(value)
  return self._index[value] ~= nil
end

--- @return integer
function OrderedSet:size()
  return #self._list
end

--- copy list. 避免内部数据被修改.
--- @return T[]
function OrderedSet:values()
  return table.move(self._list, 1, #self._list, 1, {})
end

--- @return fun(): T
function OrderedSet:iter()
  local i = 0
  return function()
    i = i + 1
    return self._list[i]
  end
end

--- @return integer
function OrderedSet:__len()
  return #self._list
end

--- @return string
function OrderedSet:__tostring()
  return "OrderedSet{" .. table.concat(self._list, ", ") .. "}"
end

return OrderedSet
