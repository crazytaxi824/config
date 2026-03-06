--- `go test run/bench ImportPath`, test 单独的 package.

local go_none = require("utils.go.deps.go_testflag_none")
local go_pprof = require("utils.go.deps.go_testflag_pprof")
local go_cover = require("utils.go.deps.go_testflag_cover")

local go_list_module = require("utils.go.deps.go_list")
local test_cmds = require("utils.go.deps.test_cmds")
local utils = require("utils.go.deps.utils")


local M = {}

--- 测试 package `go test run/bench ImportPath`
---
--- @param mode 'run'|'bench'
M.go_test_pkg = function(mode)
  --- 排序
  local select = vim.iter({go_none.list, go_pprof.list, go_cover.list}):flatten():totable()

  --- @type table<string, GoTestFlag>
  local test_flags = vim.tbl_deep_extend('force', go_none.flags, go_pprof.flags, go_cover.flags)

  --- VVI: 异步函数, 必须在回调函数中运行 go test
  vim.ui.select(select, {
    prompt = 'choose go test flag:',
    format_item = function(item)
      return test_flags[item].desc
    end
  }, function(choice)
    if choice then
      --- @type GoTestOpts
      local opts = {
        testfn_name = utils.get_testfn_name_regexp(mode),
        go_list = go_list_module.go_list(),
        mode = mode,
        flag = choice,
      }

      --- 运行 `go test`
      local myterm_opts = test_flags[choice].term_opts(opts)
      test_cmds.go_test(myterm_opts)
    end
  end)
end

return M
