local winvar = "my_winbar"
local indicator = ''  -- ▌


--- 将一个 value 从 list 中 remove
local function list_remove_value(list, val)
  for i, v in ipairs(list) do
    if v == val then
      table.remove(list, i)
      return
    end
  end
end


--- 给 bufname 前后添加 highlight, idx, indicator
---
--- @param idx integer
--- @param bufname string
--- @param selected? boolean  是否是 current window & current buffer
--- @return string
local function winbar_highlight(idx, bufname, selected)
  if bufname == '' then
    return ''
  end

  local str = ''
  if selected then
    str = '%#MyWinBarLineIndicatorSelected#' .. indicator .. '%#MyWinBarLineBufferSelected# ' .. idx .. '. ' .. bufname .. ' %*'
  else
    str = '%#MyWinBarLine# ' .. idx .. '. ' .. bufname .. ' %*'
  end

  local tabs = vim.api.nvim_list_tabpages()
  if #tabs > 1 then
    str = str .. '%=%#MyWinBarLineTab# ' .. vim.fn.tabpagenr() .. ' '
  end

  return str
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
    bufname = '(' .. vim.bo[buf].buftype .. ')'  -- 特殊情况
  elseif bufname ~= '' and vim.fn.buflisted(buf) == 0 then
    bufname = '<' .. vim.fs.basename(bufname) .. '>'
  else
    bufname = vim.fs.basename(bufname)
  end

  return bufname
end


--- 通过 winvar 给 winbar 设置 buffers
---
--- @param win_id integer
--- @param enter? boolean  是否需要计算 selected buffer
local function set_winbar(win_id, enter)
  local current_buf = vim.api.nvim_get_current_buf()

  --- 没有 winvar 的 window 不显示 WinBarLine
  local win_bufs = vim.w[win_id][winvar]
  if not win_bufs then
    return
  end

  local str = ''
  for idx, buf in ipairs(win_bufs) do
    local bufname = bufname_mod(buf)
    local winbar_buf_str = winbar_highlight(idx, bufname, enter and buf == current_buf)
    if str == '' then
      str = winbar_buf_str
    else
      str = str .. " " .. winbar_buf_str
    end
  end
  vim.api.nvim_set_option_value('winbar', str, { scope='local', win=win_id })
end


--- autocmd ----------------------------------------------------------------------------------------
local gid = vim.api.nvim_create_augroup(winvar, { clear = true })

vim.api.nvim_create_autocmd({"BufWinEnter"}, {
  group = gid,
  callback = function(args)
    local win_id = vim.api.nvim_get_current_win()

    --- floating window 不显示 WinBarLine
    local win_cfg = vim.api.nvim_win_get_config(win_id)
    if win_cfg.relative ~= '' then
      return
    end

    local win_bufs = vim.w[win_id][winvar] or {}
    if not vim.list_contains(win_bufs, args.buf) then
      table.insert(win_bufs, args.buf)
    end
    vim.w[win_id][winvar] = win_bufs

    --- 如果 bufname 存在则直接渲染
    local bufname = vim.api.nvim_buf_get_name(args.buf)
    if bufname ~= '' then
      set_winbar(win_id, true)
      return
    end

    --- 如果 bufname == '' 则延迟用于获取准确的 bufname
    vim.schedule(function ()
      set_winbar(win_id, true)
    end)
  end
})


--- 从所有的 window buffer list 中删除 buf
vim.api.nvim_create_autocmd({"BufUnload"}, {
  group = gid,
  callback = function(args)
    local current_win = vim.api.nvim_get_current_win()
    local wins = vim.api.nvim_list_wins()
    for _, win_id in ipairs(wins) do
      local win_bufs = vim.w[win_id][winvar] or {}
      list_remove_value(win_bufs, args.buf)
      vim.w[win_id][winvar] = win_bufs
      set_winbar(win_id, win_id == current_win)
    end
  end
})


vim.api.nvim_create_autocmd({"WinEnter", "WinLeave"}, {
  group = gid,
  callback = function(args)
    local win_id = vim.api.nvim_get_current_win()
    set_winbar(win_id, args.event == 'WinEnter')
  end
})


--- Debug
function WinbarLine()
  local win_id = vim.api.nvim_get_current_win()
  print(win_id, vim.inspect(vim.w[win_id][winvar]))
end
