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
local function go_test_single(testfn_name, opt)
  --- add regexp pattern to test function name
  local testfn_name_regexp = '"^' .. testfn_name .. '$" '

  --- 获取当前文件所在文件夹路径.
  local dir = vim.fn.expand('%:h')

  --- 获取 go list info, `cd src/xxx && go list -json`
  local go_list = go_utils.go_list(dir)
  if not go_list then
    return
  end

  --- 获取 flag_cmd {prefix, flag, suffix}
  local flag_cmd = go_utils.parse_testflag_cmd(opt.flag, go_list)
  if not flag_cmd then
    return
  end

  local cmd = 'cd ' .. go_list.Root .. ' &&'
  if opt.mode == 'run' then
    --- go test -v -timeout 10m -run TestXxx ImportPath
    cmd = cmd .. ' go test -v' .. flag_cmd.flag
      .. ' -timeout 10m -run ' .. testfn_name_regexp .. go_list.ImportPath
  elseif opt.mode == 'bench' then
    --- go test -v -timeout 10m -run ^$ -benchmem -bench BenchmarkXxx ImportPath
    cmd = cmd .. ' go test -v' .. flag_cmd.flag
      .. ' -timeout 10m -run ^$ -benchmem -bench ' .. testfn_name_regexp .. go_list.ImportPath
  elseif opt.mode == 'fuzz' then
    --- go test -v -run ^$ -fuzztime 15s -fuzz FuzzXxx ImportPath
    cmd = cmd .. ' go test -v -fuzztime 15s' .. flag_cmd.flag
      .. ' -run ^$ -fuzz ' .. testfn_name_regexp .. go_list.ImportPath
  else
    Notify("go test single function {opt.mode} should be: 'run' | 'bench' | 'fuzz'", "DEBUG")
    return
  end

  --- first run prefix shell command
  if flag_cmd.prefix and flag_cmd.prefix ~= '' then
    local result = vim.fn.system(flag_cmd.prefix)
    if vim.v.shell_error ~= 0 then  --- 判断 system() 结果是否错误
      Notify(vim.trim(result), "ERROR")
      return
    end
  end

  --- my_term on_exit callback function
  local on_exit = function(term, job)
    --- :GoPprof command
    if vim.tbl_contains({'cpu', 'mem', 'mutex', 'block', 'trace'}, opt.flag) then
      go_utils.go_pprof.set_cmd_and_keymaps(term.bufnr)
    end

    if flag_cmd.suffix and flag_cmd.suffix ~= '' then
      go_utils.go_pprof.autocmd_shutdown_all_jobs(term.bufnr)  -- autocmd BufWipeout jobstop()
      go_utils.go_pprof.job_exec(flag_cmd.suffix, term.bufnr)  -- run `go tool pprof ...` in background
    end
  end

  --- my_term 执行 command
  local t = require('utils.my_term.instances').exec_term
  t.cmd = cmd
  t.on_exit = on_exit
  t:stop()
  t:run()
end

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

  --- no prompt for testflags
  if not prompt then
    go_test_single(testfn_name, {mode = mode, flag = 'none'})
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
        go_test_single(testfn_name, {mode = mode, flag = choice})
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
        go_test_single(testfn_name, {mode = mode, flag = choice})
      end
    end)
  else
    Notify("go test single function {mode} should be: 'run' | 'bench' | 'fuzz'", "DEBUG")
  end
end

return M
