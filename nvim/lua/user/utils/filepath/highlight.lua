local pat = require('user.utils.filepath.pattern')

local M = {}

vim.api.nvim_set_hl(0, 'Filepath', {underline = true}) -- 自定义颜色, for matchadd()
vim.api.nvim_set_hl(0, 'URL', {ctermfg = Color.info_blue, underline = true}) -- 自定义颜色, for matchadd()

--- NOTE: matchadd() 每次执行只能作用在 current window 上. 所有在该 window 打开的 buffer 都会收到影响.
--- 而且状态持续, 当该 window 打开别的 buffer 时, highlight 一样会存在.
M.highlight_filepath = function(bufnr, win_id, priority)
  priority = priority or 0
  --- highlight filepath
  --- matchadd() 默认的 highlight priority 是 10. 这时 Search 的 highlight 会被 matchadd() 覆盖.
  local m1 = vim.fn.matchadd('Filepath', pat.file_schema_pattern, priority, -1, { window = win_id })
  local m2 = vim.fn.matchadd('Filepath', pat.filepath_pattern,    priority, -1, { window = win_id })
  local m3 = vim.fn.matchadd('URL',      pat.url_schema_pattern,  priority, -1, { window = win_id })

  --- 自动删除 filepath highlight
  local group_id = vim.api.nvim_create_augroup('my_filepath_hl_' .. bufnr, {clear=true})
  vim.api.nvim_create_autocmd("BufWinLeave", {
    group = group_id,
    buffer = bufnr,
    callback = function(params)
      --- delete highlight
      vim.fn.matchdelete(m1, win_id)
      vim.fn.matchdelete(m2, win_id)
      vim.fn.matchdelete(m3, win_id)
    end,
    desc = "delete filepath highlight",
  })

  --- 删除 filepath highlight augroup.
  --- NOTE: terminal 都是 unlisted buffer, 所以不会触发 BufDelete event. 这里需要使用 BufWipeout.
  vim.api.nvim_create_autocmd("BufWipeout", {
    group = group_id,
    buffer = bufnr,
    callback = function(params)
      vim.api.nvim_del_augroup_by_id(group_id)
    end,
    desc = "delete filepath highlight augroup",
  })
end

return M
