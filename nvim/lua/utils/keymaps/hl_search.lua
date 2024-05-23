--- highlight search result

local M = {}

local hl_group = "IncSearch"
local priority = 101  -- highlight & sign priority
local cache_last_hl = nil  -- 缓存 { win_id=win_id, hl_id=matchadd() }, for vim.fn.matchdelete()

local function hl_search_at_cursor_pos()
  --- NOTE: `:help /ordinary-atom`
  --- `\%#` 意思是 match cursor 所在位置. Matches with the cursor position.
  --- `\c`  意思是 ignore-case. 可以被 overwrite 例如 `/foo\C`
  --- getreg() 是获取 register 值.
  local search_pattern = '\\c\\%#' .. vim.fn.getreg('/')
  local hl_id = vim.fn.matchadd(hl_group, search_pattern, priority)

  --- 缓存 matchadd() 数据, 为了后面 matchdelete()
  cache_last_hl = {hl_id = hl_id, win_id = vim.api.nvim_get_current_win()}
end

--- 删除 matchadd() and unplace sign
local function delete_prev_hl()
  --- 如果 win 已经关闭 (win_id 不存在), 则不能使用 matchdelete(win_id), 否则报错.
  if cache_last_hl and vim.api.nvim_win_is_valid(cache_last_hl.win_id) then
    vim.fn.matchdelete(cache_last_hl.hl_id, cache_last_hl.win_id)
  end

  cache_last_hl = nil  -- clear cache
end

M.hl_search = function(key)
  --- 相当于 pcall(vim.cmd, ...)
  local status, errmsg = pcall(vim.api.nvim_exec2, 'normal! ' .. key, {output = false})
  if not status then
    error(vim.inspect(errmsg))
  end

  --- 删除上一个 matchadd()
  delete_prev_hl()

  --- 重新在新的 cursor position 添加 matchadd()
  hl_search_at_cursor_pos()
end

--- search VISUAL selected word | \<word\>
--- whole_word: bool, 是否使用 \<word\>
M.hl_visual_search = function(key, whole_word)
  --- NOTE: 利用 register "f, 缓存 VISUAL selected 内容.
  --- 使用 "fy 拷贝时, register '"' 也会储存拷贝的内容, 所以需要先缓存之前的 '"' register 内容.
  local cache_reg = vim.fn.getreg('"')  -- cache register '"' 的内容.

  vim.cmd[[normal! "fy]]  -- 将 VISUAL selected 内容拷贝到 register 'f' 中.
  local search_reg = vim.fn.getreg("f")  -- 获取 register 'f' 的内容, 用于搜索.

  if whole_word then
    vim.fn.setreg('/', '\\<' .. search_reg .. '\\>')  -- 将 search register '/' 设置为搜索内容.
  else
    vim.fn.setreg('/', search_reg)
  end

  vim.fn.setreg('"', cache_reg)  -- 恢复 register '"' 的内容.
  M.hl_search(key)
end

--- 删除之前的 highlight
M.delete = function()
  delete_prev_hl()
  vim.cmd('nohlsearch')
end

--- search 命令 / ? 按下 <CR> 后 highlight
vim.api.nvim_create_autocmd({"CmdlineLeave"}, {
  pattern = {"/", "\\?"},
  callback = function(params)
    if vim.v.event.abort then  -- search abort
      return
    end

    --- 必须使用 schedule() 否则 vim.fn.getreg('/') 获取的是 old search 的 word.
    vim.schedule(function()
      hl_search_at_cursor_pos()
    end)
  end,
})

return M
