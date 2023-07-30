--- 通过 matchadd() 来 highlight filepath 和 URL

local pat = require('user.utils.filepath.pattern')

local M = {}

local hl_filepath = 'my_filepath'
local hl_url = 'my_url'

vim.api.nvim_set_hl(0, hl_filepath, {underline = true}) -- 自定义颜色, for matchadd()
vim.api.nvim_set_hl(0, hl_url, {ctermfg = Color.blue, underline = true}) -- 自定义颜色, for matchadd()

--- NOTE: matchadd() 每次执行只能作用在 current window 上. 所有在该 window 打开的 buffer 都会收到影响.
--- 而且状态持续, 当该 window 打开别的 buffer 时, highlight 一样会存在.
M.highlight_filepath = function(win_id, priority)
  --- win_id 不存在
  if vim.fn.win_gettype(win_id) == "unknown" then
    return
  end

  --- 如果该 window 已经设置了 hl_filepath or hl_url 则 return
  local matches = vim.fn.getmatches(win_id)
  for _, m in ipairs(matches) do
    if m.group == hl_filepath or m.group == hl_url then
      return
    end
  end

  priority = priority or 0
  --- highlight filepath
  --- matchadd() 默认的 highlight priority 是 10. 这时 Search 的 highlight 会被 matchadd() 覆盖.
  vim.fn.matchadd(hl_filepath, pat.file_schema_pattern, priority, -1, { window = win_id })
  vim.fn.matchadd(hl_filepath, pat.filepath_pattern,    priority, -1, { window = win_id })
  vim.fn.matchadd(hl_url,      pat.url_schema_pattern,  priority, -1, { window = win_id })
end

--- 删除自定义 filepath highlight.
M.highlight_filepath_clear = function(win_id)
  --- win_id 不存在
  if vim.fn.win_gettype(win_id) == "unknown" then
    return
  end

  local matches = vim.fn.getmatches(win_id)
  for _, m in ipairs(matches) do
    if m.group == hl_filepath or m.group == hl_url then
      vim.fn.matchdelete(m.id, win_id)
    end
  end
end

return M
