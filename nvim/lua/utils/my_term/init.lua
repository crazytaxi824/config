local g = require('utils.my_term.deps.global')
local t_win = require('utils.my_term.deps.term_win')
local meta_method = require("utils.my_term.meta_method")

local M = {}

M.new = function(opts)
  opts = vim.tbl_deep_extend('force', meta_method.default_opts, opts or {})

  --- NOTE: terminal 已经存在, 无法使用相同 id 创建新的 terminal.
  if g.global_my_term_cache[opts.id] then
    error('terminal id='.. opts.id .. ' is already created')
  end

  --- terminal object
  local my_term = opts

  --- generate metatable - term:methods()
  local mt = meta_method.metatable_funcs()

  --- VVI: set all term:methods() to terminal object's metatable
  setmetatable(my_term, { __index = mt })

  return my_term
end

M.open_shell_term = function()
  if vim.v.count1 > 999 then
    Notify("my_term id should be 1~999 in this method", "INFO")
    return
  end

  local t = M.get_term_by_id(vim.v.count1)
  --- terminal 没有被缓存则 :new()
  if not t then
    t = M.new({
      id = vim.v.count1,
      cmd = vim.go.shell,  -- `:help 'shell'`, 相当于 os.getenv('SHELL')
      after_run = function(term_obj)
        --- after_run 的时候 cursor 在 terminal window 中则执行 stopinsert.
        if vim.api.nvim_win_get_buf(vim.api.nvim_get_current_win()) == term_obj.bufnr then
          vim.cmd('startinsert')
        end
      end,
      on_exit = function(term_obj)
        --- VVI: 手动 :bw 删除 buffer 时会触发 TermClose, 导致重复 wipeout buffer 而报错.
        if g.term_buf_exist(term_obj.bufnr) then
          vim.api.nvim_buf_delete(term_obj.bufnr, {force=true})
        end

        --- NOTE: jobdone 的时候 cursor 在 terminal window 中则执行 stopinsert.
        -- if vim.api.nvim_win_get_buf(vim.api.nvim_get_current_win()) == term_obj.bufnr then
        --   vim.cmd('stopinsert')
        -- end
      end,
    })
    t:run()

    --- source Python Virtual Environment
    local local_venv = '.venv/bin/activate'
    if vim.fn.filereadable(local_venv) == 1 then
      vim.fn.chansend(t.job_id, 'source ' .. local_venv .. '&& clear\n')
    end

    return
  end

  if not t:open_win() then
    Notify('cached my_term with No bufnr', "ERROR")
  end
end

--- return an term object by id
M.get_term_by_id = function(id)
  return g.global_my_term_cache[id]
end

--- get term_id by term_win_id
M.get_term_id_by_win = function(win_id)
  if vim.api.nvim_win_is_valid(win_id) then
    local bufnr = vim.api.nvim_win_get_buf(win_id)
    return vim.b[bufnr][meta_method.bufvar_myterm]
  end
end

--- close all my_term windows
M.close_all = function()
  for _, term_obj in pairs(g.global_my_term_cache) do
    term_obj:close_win()
  end
end

--- open all terms which are cached in global_my_term_cache and bufnr is valid.
M.open_all = function()
  for _, term_obj in pairs(g.global_my_term_cache) do
    if g.term_buf_exist(term_obj.bufnr) then
      local term_wins = vim.fn.getbufinfo(term_obj.bufnr)[1].windows
      if #term_wins < 1 then
        t_win.create_term_win(term_obj.bufnr)
      end
    end
  end
end

M.wipeout_all = function()
  for _, term_obj in pairs(g.global_my_term_cache) do
    if g.term_buf_exist(term_obj.bufnr) then
      term_obj:wipeout()
    end
  end
end

--- close all first, then open all
M.toggle_all = function()
  --- 获取所有的 my_term windows
  local open_winid_list= {}
  for _, term_obj in pairs(g.global_my_term_cache) do
    if g.term_buf_exist(term_obj.bufnr) then
      local term_wins = vim.fn.getbufinfo(term_obj.bufnr)[1].windows
      for _, w in ipairs(term_wins) do
        table.insert(open_winid_list, w)
      end
    end
  end

  --- 如果有任何 my_term window 是打开的状态, 则全部关闭.
  if #open_winid_list > 0 then
    for _, win_id in ipairs(open_winid_list) do
      vim.api.nvim_win_close(win_id, true)
    end
    return
  end

  --- 如果所有 my_term window 都是关闭状态, 则 open_all()
  M.open_all()
end

--- debug ------------------------------------------------------------------------------------------
function Get_all_my_terms()
  vim.print(g.global_my_term_cache)
end

return M
