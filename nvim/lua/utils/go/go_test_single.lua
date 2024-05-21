--- `go test run/bench` single test function.
--- `go test run/bench=^TEST_Func_Name$ ImportPath`, test 单独的 package.

local go_utils = require("utils.go.utils")

local M = {}

--- get test function name Test/Benchmark/FuzzXxx -------------------------------------------------- {{{
local function get_func_line()  -- return (func_name: string|nil)
  local lcontent = vim.fn.getline('.')  -- 获取行内容

  --- 如果找到 ^func.* 则返回整行内容.
  if string.match(lcontent, "^func .*") then
    return lcontent
  end
  --- 如果没找到则返回 nil
end

--- 返回 Test Function Name, "TestXxx(t *testing.T)", "BenchmarkXxx(b *testing.B)", "FuzzXxx(f *testing.F)"
--- return {funcname: string|nil, mode :string|nil}
local function get_test_func_name()
  local func_line = get_func_line()
  if not func_line then
    return
  end

  --- NOTE: go test 函数不允许 func [T any]TestXxx(), 不允许有 type param.
  --- %w     - 单个 char [a-zA-Z0-9]
  --- [%w_]  - 单个 char [a-zA-Z0-9] && _
  --- [BFMT] - 单个 char B|F|M|T

  local testfn = string.match(func_line, "func Test[%w_]*%([%w_]* ?%*testing%.T%)")
  if testfn then
    return string.match(testfn, "Test[%w_]*"), 'run'
  end

  testfn = string.match(func_line, "func Benchmark[%w_]*%([%w_]* ?%*testing%.B%)")
  if testfn then
    return string.match(testfn, "Benchmark[%w_]*"), 'bench'
  end

  testfn = string.match(func_line, "func Fuzz[%w_]*%([%w_]* ?%*testing%.F%)")
  if testfn then
    return string.match(testfn, "Fuzz[%w_]*"), 'fuzz'
  end
end
-- -- }}}

--- go test single function under the cursor -------------------------------------------------------
--- opt.mode: 'run' | 'bench' | 'fuzz'
--- return (cmd: string|nil), eg: cmd = "go test -v -run TestFoo ImportPath"
local function go_test_single(opts)
  --- 获取 flag_cmd {prefix, flag, suffix}
  go_utils.parse_testflag_cmd(opts)
end

--- opts = {
---   testfn_name = testfn_name,
---   mode = mode,
---   flag = 'none' | 'cpu' | 'mem' | ...,
---   go_list = {},
---   project = string|nil,
--- }
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
  local dir = vim.fn.expand('%:h')
  local go_list = go_utils.go_list(dir)
  if not go_list then
    return
  end

  local opts = {
    testfn_name = testfn_name,
    mode = mode,
    flag = 'none',
    go_list = go_list,
  }

  --- no prompt for testflags
  if not prompt then
    go_test_single(opts)
    return
  end

  --- prompt choose testflags
  if mode == 'run' or mode == 'bench' then
    local select = {'cpu', 'mem', 'mutex', 'block', 'trace', 'cover', 'coverprofile'}
    vim.ui.select(select, {
      prompt = 'choose go test flag:',
      format_item = function(item)
        return go_utils.get_testflag_desc(item)
      end
    }, function(choice)
      if choice then
        opts.flag = choice
        go_test_single(opts)
      end
    end)
  elseif mode == 'fuzz' then
    local select = {'fuzz30s', 'fuzz60s', 'fuzz5m', 'fuzz10m', 'fuzz_input'}
    vim.ui.select(select, {
      prompt = 'choose go test flag: [Fuzz test cannot use pprof & coverage flags]',
      format_item = function(item)
        return go_utils.get_testflag_desc(item)
      end
    }, function(choice)
      if choice then
        opts.flag = choice
        go_test_single(opts)
      end
    end)
  else
    Notify("go test single function {mode} should be: 'run' | 'bench' | 'fuzz'", "DEBUG")
  end
end

return M
