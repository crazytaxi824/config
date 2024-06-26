--- `go test run/bench ImportPath`, test 单独的 package.

local go_list_module = require("utils.go.deps.go_list")
local test_cmds = require("utils.go.deps.test_cmds")

local M = {}

--- mode = 'run'|'bench'
M.go_test_pkg = function(mode)
  --- 获取 go list info, `cd src/xxx && go list -json`
  local go_list = go_list_module.go_list()
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
  local opts = { go_list = go_list }
  if mode == 'run' then
    opts.testfn_name = '^Test.*'
    opts.mode = 'run'
  elseif mode == 'bench' then
    opts.testfn_name = '^Benchmark.*'
    opts.mode = 'bench'
  else
    error('go test mode error: "run" | "bench" only.')
  end

  local select = {'none', 'cpu', 'mem', 'mutex', 'block', 'trace', 'cover', 'coverprofile'}
  vim.ui.select(select, {
    prompt = 'choose go test flag:',
    format_item = function(item)
      return test_cmds.get_testflag_desc(item)
    end
  }, function(choice)
    if choice then
      opts.flag = choice
      test_cmds.go_test(opts)
    end
  end)
end

return M
