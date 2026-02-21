--- `go test run/bench` single test function.
--- `go test run/bench=^TEST_Func_Name$ ImportPath`, test 单独的 package.

local go_list_module = require("utils.go.deps.go_list")
local test_cmds = require("utils.go.deps.test_cmds")

local M = {}

---get test function name Test/Benchmark/FuzzXxx -------------------------------------------------- {{{

---返回 Test Function Name, "TestXxx(t *testing.T)", "BenchmarkXxx(b *testing.B)", "FuzzXxx(f *testing.F)"
---
---@return string|nil
---@return 'run'|'bench'|'fuzz'|nil
local function get_test_func_name()
  local lcontent = vim.fn.getline('.')  -- 获取行内容

  --- NOTE: go test 函数不允许 func [T any]TestXxx(), 不允许有 type param.
  --- %w     - 单个 char [a-zA-Z0-9]
  --- [%w_]  - 单个 char [a-zA-Z0-9] && _
  --- [BFMT] - 单个 char B|F|M|T
  local testfn = lcontent:match("^func%s+(Test[%w_]*)%s*%([%w_]*%s*%*testing%.T%)")
  if testfn then
    return testfn, 'run'
  end

  testfn = lcontent:match("^func%s+(Benchmark[%w_]*)%s*%([%w_]*%s*%*testing%.B%)")
  if testfn then
    return testfn, 'bench'
  end

  testfn = lcontent:match("^func%s+(Fuzz[%w_]*)%s*%([%w_]*%s*%*testing%.F%)")
  if testfn then
    return testfn, 'fuzz'
  end
end
-- -- }}}

---`go test run/bench=^TEST_Func_Name$ ImportPath`
---
---@param prompt string|nil
M.go_test_single_func = function(prompt)
  --- 判断当前文件是否 _test.go
  if not string.match(vim.fn.bufname(), "_test%.go$") then
    Notify('not "_test.go" file', "ERROR")
    return
  end

  --- 判断当前函数是否 TestXXX. 如果是, 则获取 test function name.
  local testfn_name, mode = get_test_func_name()
  if not testfn_name or not mode then
    Notify('Please Put cursor on "func Test/Benchmark/Fuzz_XXX()"', "INFO")
    return
  end

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
  local opts = {
    testfn_name = '^'..testfn_name..'$',
    mode = mode,
    flag = 'none',
    go_list = go_list,
  }

  --- no prompt for testflags
  if not prompt then
    test_cmds.go_test(opts)
    return
  end

  --- prompt choose testflags
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
  elseif mode == 'fuzz' then
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
  else
    Notify("go test single function {mode} should be: 'run' | 'bench' | 'fuzz'", "DEBUG")
  end
end

return M
