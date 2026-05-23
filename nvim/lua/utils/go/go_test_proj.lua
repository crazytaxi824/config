-- `go test run/bench ./...` whole project
-- 在 project root 下执行 'go test ./...', 即 test 整个 Project.

local go_none = require("utils.go.deps.go_testflag_none")
local go_cover = require("utils.go.deps.go_testflag_cover")

local go_list_module = require("utils.go.deps.go_list")
local test_cmds = require("utils.go.deps.test_cmds")
local utils = require("utils.go.deps.utils")


local M = {}

-- 测试整个 project `go test run/bench ./...`
--
---@param mode 'run'|'bench'
M.go_test_proj = function(mode)
  -- 排序
  local select = vim.iter({go_none.list, go_cover.list}):flatten():totable()

  ---@type table<string, GoTestFlag>
  local test_flags = vim.tbl_deep_extend('force', go_none.flags, go_cover.flags)

  vim.ui.select(select, {
    prompt = 'choose go test flag: [go test multiple packages cannot use pprof flags]',
    format_item = function(item)
      return test_flags[item].desc
    end
  }, function(choice)
    if choice then
      ---@type GoTestOpts
      local opts = {
        testfn_name = utils.get_testfn_name_regexp(mode),
        go_list = go_list_module.go_list(),
        mode = mode,
        flag = choice,
        project = 'project', -- VVI: 标记为 test 整个 project, 传递的 string 是 -coverprofile 的文件名.
      }

      -- 运行 `go test`
      local cmd, myterm_opts = test_flags[choice].term_opts(opts)
      test_cmds.go_test(cmd, myterm_opts)
    end
  end)
end

return M
