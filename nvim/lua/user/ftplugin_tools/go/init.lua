local go_run = require("user.ftplugin_tools.go.go_run")
local go_test_single = require("user.ftplugin_tools.go.go_test_single")
local go_test_pkg = require("user.ftplugin_tools.go.go_test_pkg")

local M = {
  --- methods
  go_run = go_run.go_run,
  go_test_single_func = go_test_single.go_test_single_func,
  go_test_run_pkg = go_test_pkg.go_test_run_pkg,
  go_test_run_proj = go_test_pkg.go_test_run_proj,
  go_test_bench_pkg = go_test_pkg.go_test_bench_pkg,
  go_test_bench_proj = go_test_pkg.go_test_bench_proj,
}

return M
