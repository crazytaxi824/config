local go_import_path = require("user.ftplugin_deps.go.utils.import_path")
local go_testflags   = require("user.ftplugin_deps.go.utils.testflags")
local bg_term        = require("user.ftplugin_deps.go.utils.bg_term")

local M = {
  get_import_path = go_import_path.get_import_path,
  parse_testflag_cmd = go_testflags.parse_testflag_cmd,
  get_testflag_desc = go_testflags.get_testflag_desc,
  set_pprof_cmd_keymap = go_testflags.set_pprof_cmd_keymap,

  bg_term_spawn = bg_term.bg_term_spawn,
  bg_term_shutdown_all = bg_term.bg_term_shutdown_all,
}

return M
