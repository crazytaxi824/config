--- check white space & mix indent
--- buffer 内容改变时 nvim 会自动刷新 statusline

local M = {}

--- check Trailing-Whitespace --------------------------------------------------
local function check_trailing_whitespace()
  --- search() 是 C 实现的函数, 速度快.
  local space = vim.fn.search([[\s\+$]], 'nwc')
  return space ~= 0 and "T:"..space or ""
end

--- check Mixed-indent ---------------------------------------------------------
local function check_mixed_indent()
  local space_pat = [[\v^ +]]
  local tab_pat = [[\v^\t+]]
  local space_indent = vim.fn.search(space_pat, 'nwc')
  local tab_indent = vim.fn.search(tab_pat, 'nwc')
  local mixed = (space_indent > 0 and tab_indent > 0)  -- 判断同一个 file 中是否有 mixed_indent

  local mixed_same_line
  if not mixed then
    mixed_same_line = vim.fn.search([[\v^(\t+ | +\t)]], 'nwc')  -- 判断同一行中是否有 mixed_indent
    mixed = mixed_same_line > 0
  end
  if not mixed then return '' end  --- no mixed_indent

  --- 如果 mixed_same_line 则先返回 mixed_same_line
  if mixed_same_line ~= nil and mixed_same_line > 0 then
     return 'M:'..mixed_same_line
  end

  --- 如果 mixed_indent in file, 则返回数量少的 indent line.
  local space_indent_cnt = vim.fn.searchcount({pattern=space_pat, max_count=1e3}).total
  local tab_indent_cnt =  vim.fn.searchcount({pattern=tab_pat, max_count=1e3}).total
  if space_indent_cnt > tab_indent_cnt then
    return 'M:'..tab_indent
  else
    return 'M:'..space_indent
  end
end

--- 合并两个 check, 同时检查 ---------------------------------------------------
--- NOTE: 通过设置 set/get buffer var 来缓存 whitespace && mixed_indent 结果.
local bufvar_lualine = 'my_lualine_checks'
local cache_changetick = 0

local function my_trailing_whitespace()
  --- `:help b:changedtick` 判断 text 是否已经改变.
  if cache_changetick == vim.b.changedtick then
    return vim.b[bufvar_lualine] or ''
  end

  --- 只在 Normal mode 下 update lualine, 可以减少计算量.
  if vim.fn.mode() == 'n' then
    local mi = check_mixed_indent()
    local ts = check_trailing_whitespace()

    if mi ~= '' and ts ~= '' then
      vim.b[bufvar_lualine] = mi..' '..ts
    elseif mi ~= '' and ts == '' then
      vim.b[bufvar_lualine] = mi
    elseif mi == '' and ts ~= '' then
      vim.b[bufvar_lualine] = ts
    else
      vim.b[bufvar_lualine] = nil
    end

    --- NOTE: 在计算结果之后 update changedtick.
    cache_changetick = vim.b.changedtick
  end

  --- 通过 buf var 获取结果
  return vim.b[bufvar_lualine] or ''
end

return M
