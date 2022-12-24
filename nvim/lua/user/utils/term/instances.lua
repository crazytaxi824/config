local exec_bot_term = require("user.utils.term.exec_bot_term")
local cmd_term = require("user.utils.term.cmd_term")

local M = {}

--- 缓存所有自定义 terminal 实例.
local my_terminals = {
  --- horizontal terminal, bottom
  [1]=cmd_term.h1_term, [2]=cmd_term.h2_term, [3]=cmd_term.h3_term,
  [4]=cmd_term.h4_term, [5]=cmd_term.h5_term, [6]=cmd_term.h6_term,

  --- vertical terminal, right
  [7]=cmd_term.v7_term, [8]=cmd_term.v8_term, [9]=cmd_term.v9_term,

  --- special use terminal
  [exec_bot_term.term_id]=exec_bot_term.exec_bot_term,
  [cmd_term.node_term_id]=cmd_term.node_term,
  [cmd_term.py_term_id]=cmd_term.python_term,
}

M.toggle_my_term = function()
  --- v:count1 默认值为1.
  my_terminals[vim.v.count1]:toggle()
end

--- open / close all terminals
M.toggle_all_my_terms = function()
  local active_terms_wins = {}
  local inactive_terms = {}

  --- 遍历所有 buffer, 筛选出 active_terms && inactive_terms
  for _, buf in ipairs(vim.fn.getbufinfo()) do
    if string.match(buf.name, '^term://') then
      if #buf.windows > 0 then  -- buf.windows 判断 buffer 是否 active.
        vim.list_extend(active_terms_wins, buf.windows)
      else
        --- NOTE: toggleterm 会在每个 toggleterm buffer 中 setbufvar('toggle_number'), 值是 terminal count/id
        --- 如果 table.insert(list, nil), 则 list 不会有任何影响.
        table.insert(inactive_terms, buf.variables["toggle_number"])
      end
    end
  end

  --- 如果有 active terminal 则全部关闭.
  if #active_terms_wins > 0 then
    for _, win_id in ipairs(active_terms_wins) do
      --- 关闭所有 active terminal 的窗口
      --- NOTE: 这里不使用 :close() 是因为 :close() 只能关闭 :open() 打开的窗口,
      --- 如果有多个窗口都显示同一个 terminal 则 :close() 无法关闭全部窗口.
      vim.api.nvim_win_close(win_id, false)
    end
    return
  end

  --- 如果没有 active terminal 则打开全部 inactive terminals.
  for _, term_id in ipairs(inactive_terms) do
    if my_terminals[term_id] then
      my_terminals[term_id]:open()
    end
  end
end

return M
