local go_run = require("user.ftplugin_deps.go.go_run")
local go_test_single = require("user.ftplugin_deps.go.go_test_single")
local go_test_pkg = require("user.ftplugin_deps.go.go_test_pkg")
local tool_gomodifytags = require("user.ftplugin_deps.go.tool_gomodifytags")
local tool_gotests = require("user.ftplugin_deps.go.tool_gotests")
local tool_impl = require("user.ftplugin_deps.go.tool_impl")

local M = {
  --- methods
  go_run = go_run.go_run,

  go_test_single_func = go_test_single.go_test_single_func,
  go_test_run_pkg = go_test_pkg.go_test_run_pkg,
  go_test_run_proj = go_test_pkg.go_test_run_proj,
  go_test_bench_pkg = go_test_pkg.go_test_bench_pkg,
  go_test_bench_proj = go_test_pkg.go_test_bench_proj,

  go_add_tags_and_opts = tool_gomodifytags.go_add_tags_and_opts,
  go_remove_tags = tool_gomodifytags.go_remove_tags,
  go_remove_tags_opts = tool_gomodifytags.go_remove_tags_opts,

  gotests_cmd_tool = tool_gotests.gotests_cmd_tool,
  go_impl = tool_impl.go_impl,
}

return M
