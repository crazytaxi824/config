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
local node_term_id = 201
M.node_term = Terminal:new({
  cmd = "node",
  hidden = true,  -- true: 该 term 不受 :ToggleTerm :ToggleTermToggleAll ... 命令影响.
  direction = "float",  -- horizontal(*) | vertical | float | tab
  count = node_term_id,
})

function _NODE_TOGGLE()
  M.node_term:toggle()
end

--- python3 --------------------------------------------------------------------
local py_term_id = 202
M.python_term = Terminal:new({
  cmd = "python3",
  hidden = true,  -- true: 该 term 不受 :ToggleTerm :ToggleTermToggleAll ... 命令影响.
  direction = "float",
  count = py_term_id,
})

function _PYTHON_TOGGLE()
  M.python_term:toggle()
end

return M
