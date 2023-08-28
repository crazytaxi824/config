local go_run            = require("utils.go.go_run")
local go_test_single    = require("utils.go.go_test_single")
local go_test_pkg       = require("utils.go.go_test_pkg")
local tool_gomodifytags = require("utils.go.tool_gomodifytags")
local tool_gotests      = require("utils.go.tool_gotests")
local tool_impl         = require("utils.go.tool_impl")

local M = {
  --- methods
  run = go_run.go_run,

  test = {
    single_func = go_test_single.go_test_single_func,
    run_pkg     = go_test_pkg.go_test_run_pkg,
    run_proj    = go_test_pkg.go_test_run_proj,
    bench_pkg   = go_test_pkg.go_test_bench_pkg,
    bench_proj  = go_test_pkg.go_test_bench_proj,
  },

  tag = {
    add         = tool_gomodifytags.go_add_tags_and_opts,
    remove      = tool_gomodifytags.go_remove_tags,
    remove_opts = tool_gomodifytags.go_remove_tags_opts,
  },

  tool = {
    gotests = tool_gotests.gotests_cmd_tool,
    impl    = tool_impl.go_impl,
  },
}

return M
