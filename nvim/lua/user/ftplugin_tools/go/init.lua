local go_run = require("user.ftplugin_tools.go.go_run")
local go_test_single = require("user.ftplugin_tools.go.go_test_single")
local go_test_pkg = require("user.ftplugin_tools.go.go_test_pkg")
local go_modifytags = require("user.ftplugin_tools.go.tool_gomodifytags")
local gotests = require("user.ftplugin_tools.go.tool_gotests")

local M = {
  --- methods
  go_run = go_run.go_run,

  go_test_single_func = go_test_single.go_test_single_func,
  go_test_run_pkg = go_test_pkg.go_test_run_pkg,
  go_test_run_proj = go_test_pkg.go_test_run_proj,
  go_test_bench_pkg = go_test_pkg.go_test_bench_pkg,
  go_test_bench_proj = go_test_pkg.go_test_bench_proj,

  go_add_tags_and_opts = go_modifytags.go_add_tags_and_opts,
  go_remove_tags = go_modifytags.go_remove_tags,
  go_remove_tags_opts = go_modifytags.go_remove_tags_opts,

  gotests_cmd_tool = gotests.gotests_cmd_tool,
}

return M
