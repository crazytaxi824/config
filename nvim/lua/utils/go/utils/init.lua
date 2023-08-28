local go_list_module = require("utils.go.utils.go_list")
local go_testflags   = require("utils.go.utils.testflags")
local go_pprof  = require("utils.go.utils.go_pprof")

local M = {
  go_list = go_list_module.go_list,
  go_pprof = go_pprof,

  parse_testflag_cmd = go_testflags.parse_testflag_cmd,
  get_testflag_desc = go_testflags.get_testflag_desc,
}

return M
