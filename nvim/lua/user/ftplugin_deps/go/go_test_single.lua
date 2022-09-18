--- go test single function under the cursor -------------------------------------------------------

local go_utils = require("user.ftplugin_deps.go.utils")

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

  local testfn = string.match(func_line, "func Test[%w_]*%([%w_]* %*testing%.T%)")
  if testfn then
    return string.match(testfn, "Test[%w_]*"), 'run'
  end

  testfn = string.match(func_line, "func Benchmark[%w_]*%([%w_]* %*testing%.B%)")
  if testfn then
    return string.match(testfn, "Benchmark[%w_]*"), 'bench'
  end

  testfn = string.match(func_line, "func Fuzz[%w_]*%([%w_]* %*testing%.F%)")
  if testfn then
    return string.match(testfn, "Fuzz[%w_]*"), 'fuzz'
  end
end
-- -- }}}

--- opt.mode: 'run' | 'bench' | 'fuzz'
--- return (cmd: string|nil), eg: cmd = "go test -v -run TestFoo ImportPath"
local function go_test_single(testfn_name, opt)
  --- 判断 flag 是否存在. Internal
  local flag_cmd = go_utils.parse_testflag_cmd(opt.flag)
  if not flag_cmd then
    return
  end

  --- add regexp pattern to test function name
  local testfn_name_regexp = '"^' .. testfn_name .. '$" '

  --- 获取当前文件所在文件夹路径.
  local dir = vim.fn.expand('%:h')

  --- 获取 go import path, `cd src/xxx && go list -f '{{.ImportPath}}'`
  local import_path = go_utils.get_import_path(dir)
  if not import_path then
    return
  end

  local cmd = 'cd ' .. dir .. ' &&' .. flag_cmd.prefix
  if opt.mode == 'run' then
    --- go test -v -timeout 10s -run TestXxx ImportPath
    cmd = cmd .. ' go test -v' .. flag_cmd.flag .. ' -timeout 10s -run ' .. testfn_name_regexp .. import_path
  elseif opt.mode == 'bench' then
    --- go test -v -timeout 10s -run ^$ -benchmem -bench BenchmarkXxx ImportPath
    cmd = cmd .. ' go test -v' .. flag_cmd.flag .. ' -timeout 10s -run ^$ -benchmem -bench ' .. testfn_name_regexp .. import_path
  elseif opt.mode == 'fuzz' then
    --- go test -v -run ^$ -fuzztime 30s -fuzz FuzzXxx ImportPath
    cmd = cmd .. ' go test -v -fuzztime 15s' .. flag_cmd.flag .. ' -run ^$ -fuzz ' .. testfn_name_regexp .. import_path
  else
    Notify("go test single function {opt.mode} should be: 'run' | 'bench' | 'fuzz'", "DEBUG")
    return
  end

  -- print(cmd)
  _Exec(cmd, false, function()
    --- :GoPprof command
    if vim.tbl_contains({'cpu', 'mem', 'mutex', 'block', 'trace'}, opt.flag) then
      go_utils.set_pprof_cmd_keymap()
    end

    --- run `go tool pprof ...` in background terminal
    if flag_cmd.suffix and flag_cmd.suffix ~= '' then
      go_utils.bg_term_spawn(flag_cmd.suffix)
    end
  end)
end

M.go_test_single_func = function(prompt)
  --- 判断当前文件是否 _test.go
  if not string.match(vim.fn.expand('%:t'), "_test%.go$") then
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
    }, function (choice)
      if choice then
        go_test_single(testfn_name, {mode = mode, flag = choice})
      end
    end)
  elseif mode == 'fuzz' then
    local select = {'fuzz_default', 'fuzz30s', 'fuzz60s', 'fuzz5m', 'fuzz10m', 'fuzz_input'}
    vim.ui.select(select, {
      prompt = 'choose go test flag: [Fuzz test cannot use pprof & coverage flags]',
      format_item = function(item)
        return go_utils.get_testflag_desc(item)
      end
    }, function (choice)
      if choice then
        go_test_single(testfn_name, {mode = mode, flag = choice})
      end
    end)
  else
    Notify("go test single function {mode} should be: 'run' | 'bench' | 'fuzz'", "DEBUG")
  end
end

return M
