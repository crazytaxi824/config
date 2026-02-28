local g = require('utils.my_term.deps.global')
local my_term = require("utils.my_term.my_term")


local M = {}

--- new MyTerm object
---
--- @param id integer
--- @param opts MyTermOpts
--- @return MyTerm
function M._new(id, opts)
  --- NOTE: terminal 已经存在, 无法使用相同 id 创建新的 terminal.
  if g.get_TermPost(id) then
    error('terminal id='.. id .. ' is already exist')
  end

  --- terminal object
  return vim.tbl_deep_extend('force', my_term, opts, {id = id})
end

return M
