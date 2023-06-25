--- 实现 toggle (open/close) 单个或者所有 terminal windows.

local exec_bot_term = require("user.utils.term.exec_bot_term")
local cmd_term = require("user.utils.term.cmd_term")

local M = {}

--- 缓存所有自定义 terminal 实例.
local my_terminals = {
  --- horizontal terminal, bottom
  cmd_term.h1_term, cmd_term.h2_term, cmd_term.h3_term,
  cmd_term.h4_term, cmd_term.h5_term, cmd_term.h6_term,

  --- vertical terminal, right
  cmd_term.v7_term, cmd_term.v8_term, cmd_term.v9_term,

  --- special use terminal
  exec_bot_term.exec_bot_term,
  cmd_term.node_term,
  cmd_term.python_term,
}

M.toggle_my_term = function()
  --- v:count1 默认值为1.
  my_terminals[vim.v.count1]:toggle()
end

--- open / close all terminals
M.toggle_all_my_terms = function()
  local opened_terms_wins = {}
  local closed_terms = {}

  for _, term in pairs(my_terminals) do
    --- 如果 term.bufnr 存在则说明 term 正在被使用.
    if term.bufnr then
      if term:is_open() then
        local wins = vim.fn.getbufinfo(term.bufnr)[1].windows
        vim.list_extend(opened_terms_wins, wins)
      else
        table.insert(closed_terms, term)
      end
    end
  end

  --- 如果有 active terminal 则全部关闭.
  if #opened_terms_wins > 0 then
    for _, win_id in ipairs(opened_terms_wins) do
      --- 关闭所有 active terminal 的窗口
      --- NOTE: 这里不使用 :close() 是因为 :close() 只能关闭 :open() 打开的窗口,
      --- 如果有多个窗口都显示同一个 terminal 则 :close() 无法关闭全部窗口.
      vim.api.nvim_win_close(win_id, false)
    end
    return
  end

  --- 如果没有 active terminal 则打开全部 inactive terminals.
  for _, term in ipairs(closed_terms) do
    term:open()
  end
end

return M
