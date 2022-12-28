--- highlight search result
local M = {}

--- 在当前 search result 前放置 search_sign.
--- {group} as a namespace for {id}, thus two groups can use the same IDs.
local my_search = {
  sign = {
    id = 10010,
    group = "MySearchSignGroup",
    name = "MySearchSign",
    text = "⚲",  -- 类似 icon, ⌕☌⚲⚯
  },
  hl_group = "IncSearch",
  cache_last_hl = nil  -- 缓存 { win_id=win_id, hl_id=matchadd() }, for vim.fn.matchdelete()
}
--- define my_search_sign
vim.fn.sign_define(my_search.sign.name, {text=my_search.sign.text, texthl=my_search.hl_group})

local function hl_search_at_cursor_pos()
  --- NOTE: `:help /ordinary-atom`
  --- `\%#` 意思是 match cursor 所在位置. Matches with the cursor position.
  --- `\c`  意思是 ignore-case. 可以被 overwrite 例如 `/foo\C`
  --- getreg() 是获取 register 值.
  local search_pattern = '\\c\\%#' .. vim.fn.getreg('/')
  local hl_id = vim.fn.matchadd(my_search.hl_group, search_pattern, 101)

  --- NOTE: 通过 cursor position 来 place my_search_sign.
  local cur_pos = vim.fn.getpos('.')  -- [bufnum, lnum, col, off]
  vim.fn.sign_place(my_search.sign.id, my_search.sign.group, my_search.sign.name, vim.fn.bufnr(),
    {lnum=cur_pos[2], priority=101})

  --- 缓存 matchadd() 数据, 为了后面 matchdelete()
  my_search.cache_last_hl = {hl_id = hl_id, win_id = vim.api.nvim_get_current_win()}
end

--- 删除 matchadd() and unplace sign
local function delete_prev_hl()
  --- VVI: 如果 win 已经关闭 (win_id 不存在), 则不能使用 matchdelete(win_id), 否则报错.
  --- win_gettype(win_id) == "unknown", window not found. 避免 cache 中的 window 被关闭了.
  if my_search.cache_last_hl and vim.fn.win_gettype(my_search.cache_last_hl.win_id) ~= "unknown" then
    vim.fn.matchdelete(my_search.cache_last_hl.hl_id, my_search.cache_last_hl.win_id)
  end

  vim.fn.sign_unplace(my_search.sign.group)  -- clear search_sign
  my_search.cache_last_hl = nil  -- clear cache
end

M.hl_search = function(key)
  local status, errmsg = pcall(vim.cmd, 'normal! ' .. key)
  if not status then
    vim.notify(errmsg, vim.log.levels.ERROR) -- 这里不要使用 notify 插件, 显示错误信息.
    return
  end

  --- 删除上一个 matchadd()
  delete_prev_hl()

  --- 重新在新的 cursor position 添加 matchadd()
  hl_search_at_cursor_pos()
end

--- search VISUAL selected word | \<word\>
--- whole_word: bool, 是否使用 \<word\>
M.hl_visual_search = function(key, whole_word)
  --- 利用 register "f
  vim.cmd[[normal! "fy]]  -- copy VISUAL select to register 'f'
  local tmp_search = vim.fn.getreg("f")
  if whole_word then
    vim.fn.setreg('/', '\\<' .. tmp_search .. '\\>')
  else
    vim.fn.setreg('/', tmp_search)
  end

  M.hl_search(key)
end

--- 删除之前的 highlight
M.delete = function()
  delete_prev_hl()
  vim.cmd('nohlsearch')
end

return M
