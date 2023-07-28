--- 通过 matchadd() 来 highlight filepath 和 URL

local pat = require('user.utils.filepath.pattern')

local M = {}

local hl_filepath = 'my_filepath'
local hl_url = 'my_url'

vim.api.nvim_set_hl(0, hl_filepath, {underline = true}) -- 自定义颜色, for matchadd()
vim.api.nvim_set_hl(0, hl_url, {ctermfg = Color.blue, underline = true}) -- 自定义颜色, for matchadd()

--- NOTE: matchadd() 每次执行只能作用在 current window 上. 所有在该 window 打开的 buffer 都会收到影响.
--- 而且状态持续, 当该 window 打开别的 buffer 时, highlight 一样会存在.
M.highlight_filepath = function(bufnr, win_id, priority)
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
  local m1 = vim.fn.matchadd(hl_filepath, pat.file_schema_pattern, priority, -1, { window = win_id })
  local m2 = vim.fn.matchadd(hl_filepath, pat.filepath_pattern,    priority, -1, { window = win_id })
  local m3 = vim.fn.matchadd(hl_url,      pat.url_schema_pattern,  priority, -1, { window = win_id })

  --- 自动删除 filepath highlight
  --- VVI: 这里不能使用 augroup, 否则多次执行 highlight_filepath 的情况下之前的 matchadd() 无法被 autocmd 删除.
  vim.api.nvim_create_autocmd("BufWinLeave", {
    buffer = bufnr,
    callback = function(params)
      --- delete highlight, getmatches(win_id), clearmatches(win_id)
      --- win_gettype(win_id) == "unknown", window not found. 避免 cache 中的 window 被关闭了.
      if vim.fn.win_gettype(win_id) ~= "unknown" then
        local ms = vim.fn.getmatches(win_id)
        for _, m in ipairs(ms) do
          if m.id == m1 or m.id == m2 or m.id == m3 then
            vim.fn.matchdelete(m.id, win_id)
          end
        end
      end

      --- 粗暴的处理方式: pcall 防止 matchdelete() 报错. eg: win_id 已被关闭. m1,m2,m3 已被关闭.
      --pcall(vim.fn.matchdelete, m1, win_id)
      --pcall(vim.fn.matchdelete, m2, win_id)
      --pcall(vim.fn.matchdelete, m3, win_id)
    end,
    desc = "delete filepath highlight",
  })
end

return M
