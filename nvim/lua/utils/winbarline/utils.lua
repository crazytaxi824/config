local M = {}

M.winvar = "my_winbar"

local sign_indicator = '▌'
local sign_modified = '●'


--- 找出 value 在 list 中的 index
---
--- @generic T
--- @param list T[]
--- @param val T
--- @return integer|nil
function M.list_index_value(list, val)
  for i, v in ipairs(list) do
    if v == val then
      return i
    end
  end
end


--- 将一个 value 从 list 中 remove
---
--- @generic T
--- @param list T[]
--- @param val T
function M.list_remove_value(list, val)
  local idx = M.list_index_value(list, val)
  if idx then
    table.remove(list, idx)
  end
end


--- bufname modification
---
--- @param buf integer
--- @return string
local function bufname_mod(buf)
  local bufname = vim.api.nvim_buf_get_name(buf)

  if bufname == '' and vim.fn.buflisted(buf) == 1 then
    bufname = '[No Name]'
  elseif bufname == '' and vim.fn.buflisted(buf) == 0 then
    if vim.bo[buf].buftype == 'nofile' then
      bufname = '[Scratch]'  -- 特殊情况
    else
      bufname = '[' .. vim.bo[buf].buftype .. ']'
    end
  elseif bufname ~= '' and vim.fn.buflisted(buf) == 0 then
    bufname = '[' .. vim.fs.basename(bufname) .. ']'  -- unlisted buffer
  else
    bufname = vim.fs.basename(bufname)
  end

  return bufname
end


--- 给 bufname 前后添加 highlight, idx, indicator
---
--- @param idx integer
--- @param bufnr integer
--- @param selected? boolean  是否是 current window & current buffer
--- @return string
local function winbar_highlight(idx, bufnr, selected)
  local bufname = bufname_mod(bufnr)
  if bufname == '' then
    return ''
  end

  local str = ''
  if selected and not vim.bo[bufnr].modified then
    str = '%#MyWinBarLineIndicatorSelected#' .. sign_indicator .. '%#MyWinBarLineBufferSelected#' .. idx .. '. ' .. bufname .. ' %*'
  elseif selected and vim.bo[bufnr].modified then
    str = '%#MyWinBarLineIndicatorSelected#' .. sign_indicator .. '%#MyWinBarLineBufferSelectedModified#' .. idx .. '. ' .. bufname .. ' ' .. sign_modified .. ' %*'
  elseif not selected and vim.bo[bufnr].modified then
    str = '%#MyWinBarLineBuffer# ' .. idx .. '. ' .. bufname .. '%#MyWinBarLineBufferModified# ' .. sign_modified .. ' %*'
  else
    str = '%#MyWinBarLineBuffer# ' .. idx .. '. ' .. bufname .. ' %*'
  end

  return str
end


--- 通过 winvar 给 winbar 设置 buffers
---
--- @param win_id integer
--- @param enter? boolean  是否需要计算 selected buffer
function M.set_winbar(win_id, enter)
  local current_buf = vim.api.nvim_get_current_buf()

  --- 没有 winvar 的 window 不显示 WinBarLine
  local win_bufs = vim.w[win_id][M.winvar]
  if not win_bufs then
    return
  end

  local str = ''
  for idx, buf in ipairs(win_bufs) do
    local winbar_buf_str = winbar_highlight(idx, buf, enter and buf == current_buf)
    if str == '' then
      str = winbar_buf_str
    else
      str = str .. " " .. winbar_buf_str
    end
  end

  local tabs = vim.api.nvim_list_tabpages()
  if #tabs > 1 then
    str = str .. '%=%#MyWinBarLineTab# ' .. vim.fn.tabpagenr() .. ' '
  end

  vim.api.nvim_set_option_value('winbar', str, { scope='local', win=win_id })
end

return M
