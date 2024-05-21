local go_list_module = require("utils.go.utils.go_list")
local go_pprof  = require("utils.go.utils.go_pprof")
local test_cmds = require("utils.go.utils.test_cmds")

local M = {
  go_list = go_list_module.go_list,
  go_pprof = go_pprof,

  go_test = test_cmds.go_test,
  get_testflag_desc = test_cmds.get_testflag_desc,
}

return M
