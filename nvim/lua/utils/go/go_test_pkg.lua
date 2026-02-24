--- `go test run/bench ImportPath`, test 单独的 package.

local go_list_module = require("utils.go.deps.go_list")
local test_cmds = require("utils.go.deps.test_cmds")
local utils = require("utils.go.deps.utils")

local M = {}

--- 测试 package `go test run/bench ImportPath`
---
--- @param mode 'run'|'bench'
M.go_test_pkg = function(mode)
  --- VVI: 异步函数, 必须在回调函数中运行 go test
  local select = {'none', 'cpu', 'mem', 'mutex', 'block', 'trace', 'cover', 'coverprofile'}
  vim.ui.select(select, {
    prompt = 'choose go test flag:',
    format_item = function(item)
      return test_cmds.get_testflag_desc(item)
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
      test_cmds.go_test(opts)
    end
  end)
end

return M
