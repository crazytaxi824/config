--- 编辑器内的 terminal. 常用于在编辑器内执行 cmd.
--- 是 toggleterm 的实例. 预设了多个实例, 包括 horizontal, vertical, float.
--- 也包括 Node, python3.

local Terminal = require("toggleterm.terminal").Terminal

local M = {}

--- normal terminals -----------------------------------------------------------
M.h1_term = Terminal:new({count = 1})
M.h2_term = Terminal:new({count = 2})
M.h3_term = Terminal:new({count = 3})
M.h4_term = Terminal:new({count = 4})
M.h5_term = Terminal:new({count = 5})
M.h6_term = Terminal:new({count = 6})
M.v7_term = Terminal:new({count = 7, direction = "vertical"})
M.v8_term = Terminal:new({count = 8, direction = "vertical"})
M.v9_term = Terminal:new({count = 9, direction = "vertical"})

--- node -----------------------------------------------------------------------
M.node_term = Terminal:new({
  cmd = "node",
  direction = "vertical",  -- horizontal(*) | vertical | float | tab
  count = 201,
})

function _NODE_TOGGLE()
  M.node_term:toggle()
end

--- python3 --------------------------------------------------------------------
M.python_term = Terminal:new({
  cmd = "python3",
  direction = "vertical",
  count = 202,
})

function _PYTHON_TOGGLE()
  M.python_term:toggle()
end

return M
