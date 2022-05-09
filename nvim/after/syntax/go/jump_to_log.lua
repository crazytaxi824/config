-- 利用 local list 跳转到 log 文件 -----------------------------------------------------------------
-- 用来储存 setloclist() 用的 winnr.
local go_run_win_id = vim.fn.win_getid()  -- for loclist display fmt/log

local function gotoLogFile()
  local lcontent = vim.fn.getline('.')
  if lcontent == "" then
    return
  end

  local fp = vim.split(lcontent, ":")

  local item = {}
  if vim.fn.filereadable(fp[1]) == 1 then
    local lnum = tonumber(fp[2])
    if not lnum then
      lnum = 1
    end
    local qfitem = {filename = fp[1], lnum = lnum, text = vim.fn.join({unpack(fp, 3, #fp)}, ":")}
    table.insert(item, qfitem)
  end

  if #item > 0 then
    vim.fn.setloclist(go_run_win_id, item, 'r')
    vim.fn.win_gotoid(go_run_win_id)
    vim.cmd('lfirst')
  end
end

vim.api.nvim_create_autocmd('TermOpen', {
  pattern = {"term://*toggleterm#*"},
  callback = function()
    --- VVI: api.nvim_{buf}_set_keymap 需要使用 callback 来传入 local lua function
    vim.api.nvim_buf_set_keymap(0, 'n', '<CR>', '', {noremap = true, callback = gotoLogFile})
  end,
})


