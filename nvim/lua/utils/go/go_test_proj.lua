--- `go test run/bench ./...` whole project
--- 在 project root 下执行 'go test ./...', 即 test 整个 Project.

local go_utils = require("utils.go.utils")

local M = {}

--- mode = 'run'|'bench'
M.go_test_proj = function(mode)
  --- 获取 go list info, `cd src/xxx && go list -json`
  local dir = vim.fn.expand('%:h')
  local go_list = go_utils.go_list(dir)
  if not go_list then
    return
  end

  --- opts = {
  ---   testfn_name = testfn_name,
  ---   mode = mode,
  ---   flag = 'none' | 'cpu' | 'mem' | ...,
  ---   go_list = {},
  ---   project = string|nil,
  --- }
  local opts = {
      go_list = go_list,
      project = 'project', --- VVI: 标记为 test 整个 project, 传递的 string 是 -coverprofile 的文件名.
  }
  if mode == 'run' then
    opts.testfn_name = '^Test.*'
    opts.mode = 'run'
  elseif mode == 'bench' then
    opts.testfn_name = '^Benchmark.*'
    opts.mode = 'bench'
  else
    error('go test mode error: "run" | "bench" only.')
  end

  --- cannot use pprof flag with multiple packages
  local select = {'none', 'cover', 'coverprofile'}
  vim.ui.select(select, {
    prompt = 'choose go test flag: [go test multiple packages cannot use pprof flags]',
    format_item = function(item)
      return go_utils.get_testflag_desc(item)
    end
  }, function(choice)
    if choice then
      opts.flag = choice
      go_utils.go_test(opts)
    end
  end)
end

return M
