local go_import_path = require("user.ftplugin_deps.go.utils.import_path")
local go_testflags = require("user.ftplugin_deps.go.utils.testflags")

local M = {
  get_import_path = go_import_path.get_import_path,
  parse_testflag_cmd = go_testflags.parse_testflag_cmd,
  get_testflag_desc = go_testflags.get_testflag_desc,
  set_pprof_cmd_keymap = go_testflags.set_pprof_cmd_keymap,
}

return M
