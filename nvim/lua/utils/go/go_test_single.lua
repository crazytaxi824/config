--- `go test run/bench` single test function.
--- `go test run/bench=^TEST_Func_Name$ ImportPath`, test 单独的 package.

local go_list_module = require("utils.go.deps.go_list")
local test_cmds = require("utils.go.deps.test_cmds")
local utils = require("utils.go.deps.utils")

local M = {}

--- `go test run/bench=^TEST_Func_Name$ ImportPath`
---
--- @param prompt? 'pprof' `go test pprof`
function M.go_test_single_func(prompt)
  --- 判断当前文件是否 _test.go
  if not string.match(vim.fn.bufname(), "_test%.go$") then
    Notify('not "_test.go" file', "ERROR")
    return
  end

  --- 判断当前函数是否 TestXXX. 如果是, 则获取 test function name.
  local testfn_name, mode = utils.get_exact_testfn_name()
  if not testfn_name or not mode then
    return
  end

  --- 获取 go list info, `cd src/xxx && go list -json`
  local go_list = go_list_module.go_list()

  --- @type GoTestOpts
  local opts = {
    testfn_name = '^'..testfn_name..'$',
    mode = mode,
    flag = 'none',
    go_list = go_list,
  }

  --- no prompt
  if not prompt then
    test_cmds.go_test(opts)
    return
  end

  --- prompt exist
  if mode == 'run' or mode == 'bench' then
    local select = {'cpu', 'mem', 'mutex', 'block', 'trace', 'cover', 'coverprofile'}
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
    return
  end

  if mode == 'fuzz' then
    local select = {'fuzz30s', 'fuzz60s', 'fuzz5m', 'fuzz10m', 'fuzz_input'}
    vim.ui.select(select, {
      prompt = 'choose go test flag: [Fuzz test cannot use pprof & coverage flags]',
      format_item = function(item)
        return test_cmds.get_testflag_desc(item)
      end
    }, function(choice)
      if choice then
        opts.flag = choice
        test_cmds.go_test(opts)
      end
    end)
    return
  end

  --- mode error
  Notify("go test single function {mode} should be: 'run' | 'bench' | 'fuzz'", "WARN")
end

return M
