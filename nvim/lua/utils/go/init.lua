local M = {
  -- methods
  run = require("utils.go.go_run").go_run,

  test = {
    single_func = require("utils.go.go_test_single").go_test_single_func,
    pkg     = require("utils.go.go_test_pkg").go_test_pkg,
    proj    = require("utils.go.go_test_proj").go_test_proj,
  },

  -- gomodifytags
  tag = {
    add         = require("utils.go.tool_gomodifytags").go_add_tags_and_opts,
    remove      = require("utils.go.tool_gomodifytags").go_remove_tags,
    remove_opts = require("utils.go.tool_gomodifytags").go_remove_tags_opts,
  },

  tool = {
    gotests = require("utils.go.tool_gotests").gotests_cmd_tool,

    -- impl    = require("utils.go.tool_impl").go_impl,
    impl    = require("utils.go.tool_impl_ts").go_impl,
  },
}

return M
