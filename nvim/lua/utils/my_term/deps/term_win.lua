local g = require('utils.my_term.deps.global')
local cb = require('utils.my_term.deps.autocmd_callback')

local M = {}

--- 根据 cached MyTermPost bufnr 寻找已有的 window ID, 不包括 normal terminal window.
---
--- @return integer win_id
local function find_exist_term_win()
  local win_id = -1

  g.range_TermPost(function (_, term_post)
    if vim.api.nvim_buf_is_valid(term_post.bufnr) then
      local term_wins = vim.fn.getbufinfo(term_post.bufnr)[1].windows
      for _, w in ipairs(term_wins) do
        if w > win_id then
          win_id = w
        end
      end
    end
  end)

  return win_id
end

--- create & enter 一个 window, 显示指定 bufnr, 用于 jobstart() 运行.
--- `vim.api.nvim_open_win()`
---
--- 寻找已有的(用于显示 MyTermPost.bufnr 的) window, 然后在右侧创建一个新的 window,
--- 如果没有用于显示 MyTermPost.bufnr 的 window, 则在底部创建一个新的 window.
---
--- @param bufnr integer
--- @return integer win_id
function M.create_term_win(bufnr)
  if not vim.api.nvim_buf_is_valid(bufnr) then
    error("bufnr is not exist")
  end

  local exist_term_win_id = find_exist_term_win()

  if exist_term_win_id > 0 then
    --- `nvim_open_win()`, 显示 buffer, 同时进入 window.
    --- at least 1 terminal window exist, 在该 my_term win 右边创建一个新的 my_term window
    return vim.api.nvim_open_win(bufnr, true, { win = exist_term_win_id, split = 'right' })
  else
    --- no terminal window exist, create a botright window for terminals.
    return vim.api.nvim_open_win(bufnr, true, { height = g.win_height, split = 'below' })
  end
end


--- 使用 old term bufnr 的 window 显示 new_term_bufnr, enter window
--- `vim.fn.win_gotoid()`, `vim.api.nvim_win_set_buf()`
---
--- @param new_term_bufnr integer
--- @param old_term_bufnr integer
--- @return integer|nil win_id
local function reuse_term_win(new_term_bufnr, old_term_bufnr)
  if not vim.api.nvim_buf_is_valid(new_term_bufnr) then
    error("bufnr is not exist")
  end

  local win_id

  local term_wins = vim.fn.getbufinfo(old_term_bufnr)[1].windows
  if #term_wins > 0 then
    win_id = term_wins[1]
    --- enter window
    if vim.fn.win_gotoid(win_id) == 1 then
      --- 将 bufnr 加载到指定 win_id
      vim.api.nvim_win_set_buf(win_id, new_term_bufnr)
    else
      error("term_win_id: " .. win_id .. " is not exist")
    end
  end

  --- NOTE: 放在最后避免 :bwipeout old_term_bufnr 时关闭了 old_term_wins.
  vim.api.nvim_buf_delete(old_term_bufnr, {force=true})  -- :bwipeout

  return win_id
end


--- 1. 创建一个 term buffer, `vim.api.nvim_create_buf()`
--- 2. 创建/重用一个 window, `vim.api.nvim_open_win()`
--- 3. 进入该 window, `vim.fn.win_gotoid()`, `vim.api.nvim_open_win()`
--- 4. 显示刚创建的 term buffer, `vim.api.nvim_win_set_buf()`, `vim.api.nvim_open_win()`
---
--- 运行过 jobstart() 的 buffer 不能再次运行 jobstart() 了. Can only call this function in an unmodified buffer.
--- 需要删除旧的 bufnr 然后重新创建一个新的 scratch bufnr 给 jobstart() 使用. 但是在删除旧 buffer 之前可以 re-use
--- 旧 buffer 的 window, 避免重新创建新的 window, 关闭旧的 window 造成的闪烁.
---
--- @param term MyTerm
--- @return integer bufnr
--- @return integer win_id
function M.set_myterm_current_win(term)
  --- DOCS: `:help nvim_buf_call()`, If the current
  --- window already shows "buffer", the window is not switched. If a window
  --- inside the current tabpage (including a float) already shows the buffer,
  --- then one of those windows will be set as current window temporarily.
  --- Otherwise a temporary scratch window (called the "autocmd window" for
  --- historical reasons) will be used.

  --- 每次运行 jobstart() 之前, 先创建一个新的 scratch buffer 给 terminal.
  local term_bufnr = vim.api.nvim_create_buf(false, true)  -- nobuflisted scratch buffer

  --- 设置 term buffer 属性
  vim.bo[term_bufnr].filetype = "my_term"
  vim.bo[term_bufnr].swapfile = false

  --- autocmd 放在这里运行主要是有两个限制条件:
  --- 1. 在获取到 terminal bufnr 之后运行, 为了在 autocmd 中使用 bufnr 作为触发条件.
  --- 2. 在 term window 打开并加载 term bufnr 之前运行, 为了触发 BufWinEnter event.
  cb.autocmd_callback(term, term_bufnr)

  --- 判断 term_id 是否已经 run(), 是否可以 re-use window
  local term_win_id
  local tp = g.get_TermPost(term.id)
  if tp then
    --- enter existing window
    term_win_id = reuse_term_win(term_bufnr, tp.bufnr)
  end

  if not term_win_id then
    --- 创建一个 new window
    term_win_id = M.create_term_win(term_bufnr)
  end

  --- 设置 term win 属性
  local scope = { scope = 'local', win = term_win_id }
  vim.api.nvim_set_option_value('sidescrolloff', 0, scope)
  vim.api.nvim_set_option_value('scrolloff', 0, scope)

  return term_bufnr, term_win_id
end

return M
