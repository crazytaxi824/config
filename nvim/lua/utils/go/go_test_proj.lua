--- `go test run/bench ./...` whole project
--- 在 project root 下执行 'go test ./...', 即 test 整个 Project.

local go_list_module = require("utils.go.deps.go_list")
local test_cmds = require("utils.go.deps.test_cmds")
local utils = require("utils.go.deps.utils")

local M = {}

--- 测试整个 project `go test run/bench ./...`
---
--- @param mode 'run'|'bench'
M.go_test_proj = function(mode)
  --- cannot use pprof flag with multiple packages
  local select = {'none', 'cover', 'coverprofile'}
  vim.ui.select(select, {
    prompt = 'choose go test flag: [go test multiple packages cannot use pprof flags]',
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
        project = 'project', --- VVI: 标记为 test 整个 project, 传递的 string 是 -coverprofile 的文件名.
      }

      --- 运行 `go test`
      test_cmds.go_test(opts)
    end
  end)
end

return M
