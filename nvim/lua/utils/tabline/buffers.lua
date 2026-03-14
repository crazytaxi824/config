local oset = require("utils.ordered_set")

--- dict<tab_id: integer, buf_ids: integer[]>
--- @type table<integer, OrderedSet<integer>>
local cache_tab_buffers = {}


local M = {}


--- @param tab_id integer
--- @param buf_id integer
function M.append(tab_id, buf_id)
  tab_id = tab_id ~= 0 and tab_id or vim.api.nvim_get_current_tabpage()
  buf_id = buf_id ~= 0 and buf_id or vim.api.nvim_get_current_buf()

  if not vim.api.nvim_buf_is_valid(buf_id) or not vim.api.nvim_tabpage_is_valid(tab_id) then
    return
  end

  if not cache_tab_buffers[tab_id] then
    cache_tab_buffers[tab_id] = oset.new()
  end

  cache_tab_buffers[tab_id]:append(buf_id)
end


--- @param tab_id integer
--- @param buf_id integer
function M.delete_buf(tab_id, buf_id)
  tab_id = tab_id ~= 0 and tab_id or vim.api.nvim_get_current_tabpage()
  buf_id = buf_id ~= 0 and buf_id or vim.api.nvim_get_current_buf()

  if not vim.api.nvim_buf_is_valid(buf_id) or not vim.api.nvim_tabpage_is_valid(tab_id) then
    return
  end

  if cache_tab_buffers[tab_id] then
    cache_tab_buffers[tab_id]:remove_single(buf_id)
  end
end


--- @param tab_id integer
--- @param buf_id integer
--- @param side 'left'|'right'|'others'
function M.delete_buf_side(tab_id, buf_id, side)
  tab_id = tab_id ~= 0 and tab_id or vim.api.nvim_get_current_tabpage()
  buf_id = buf_id ~= 0 and buf_id or vim.api.nvim_get_current_buf()

  if not vim.api.nvim_buf_is_valid(buf_id) or not vim.api.nvim_tabpage_is_valid(tab_id) then
    return
  end

  if side == 'left' then
    cache_tab_buffers[tab_id]:remove_left(buf_id)
  elseif side == 'right' then
    cache_tab_buffers[tab_id]:remove_right(buf_id)
  elseif side == 'others' then
    cache_tab_buffers[tab_id]:remove_others(buf_id)
  else
    error("side value error: " .. side)
  end
end


--- @return integer[]|nil
function M.list_bufs(tab_id)
  tab_id = tab_id ~= 0 and tab_id or vim.api.nvim_get_current_tabpage()
  if not vim.api.nvim_tabpage_is_valid(tab_id) then
    return
  end

  if cache_tab_buffers[tab_id] then
    return cache_tab_buffers[tab_id]:values()
  end
end


return M
