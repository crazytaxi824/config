--- Go Functions -----------------------------------------------------------------------------------
--- README:
--    获取 go import path, `cd src/xxx && go list -f '{{.ImportPath}}'`
--    获取 go module, `go list -m`, 项目中的任何路径下都能获取到.
--    lua regex - string.match(), https://fhug.org.uk/kb/kb-article/understanding-lua-patterns/
--
--  Go Test 操作方法:
--    cursor 指向 Test Function Name Line, 使用 <F6> 执行 go test singleTestFunc
--    <S-F6> go test -v -timeout 30s -run "^Test.*"
--    <C-F6> go test -v -timeout 30s -run ^$ -benchmem -bench "^Benchmark.*"

--- VVI: 获取 go import path, `cd src/xxx && go list -f '{{.ImportPath}}'`
local function go_import_path(dir)
  local result = vim.fn.system("cd " .. dir .. " && go list -f '{{.ImportPath}}'")
  if vim.v.shell_error ~= 0 then
    Notify(result,"ERROR")
    return
  end

  return string.match(result, "[%S ]*")  -- return import_path WITHOUT '\n'
end

--- `$ go help build`, go run & go build 使用相同的 flags.
--- `go run` 相当于: 1. 生成一个临时的 go build file, 2. 然后 run.
--- go run ----------------------------------------------------------------------------------------- {{{
local function go_run()
  --- 获取当前文件所在文件夹路径.
  local dir = vim.fn.expand('%:h')

  --- 获取 go import path, `cd src/xxx && go list -f '{{.ImportPath}}'`
  local import_path = go_import_path(dir)
  if not import_path then
    return
  end

  --- go run local/src
  _Exec("cd " .. dir .. " && go run " .. import_path, true)  -- cache cmd for re-run.
end
-- -- }}}

--- `$ go help testflag`
--- run 可以使用 coverage, pprof flags, eg: -cover, -coverprofile, -cpuprofile, -memprofile ...
--- go test run Package ---------------------------------------------------------------------------- {{{
local function go_test_run_pkg()
  --- 判断当前文件是否是 _test.go
  if not string.match(vim.fn.expand('%:t'), "_test%.go$") then
    Notify('not "_test.go" file',"ERROR")
    return
  end

  --- 获取当前文件所在文件夹路径.
  local dir = vim.fn.expand('%:h')

  --- 获取 go import path, `cd src/xxx && go list -f '{{.ImportPath}}'`
  local import_path = go_import_path(dir)
  if not import_path then
    return
  end

  --- go test -v -timeout 30s -run "^Test.*" ImportPath
  local cmd = 'cd ' .. dir .. ' && go test -v -timeout 30s -run "^Test.*" ' .. import_path
  _Exec(cmd)
end
-- -- }}}

--- benchmark 可以使用 pprof flags. eg: -cpuprofile ...; 但不能使用 -cover flags
--- go test bench Package -------------------------------------------------------------------------- {{{
local function go_test_bench_pkg()
  --- 判断当前文件是否是 _test.go
  if not string.match(vim.fn.expand('%:t'), "_test%.go$") then
    Notify('not "_test.go" file',"ERROR")
    return
  end

  --- 获取当前文件所在文件夹路径.
  local dir = vim.fn.expand('%:h')

  --- 获取 go import path, `cd src/xxx && go list -f '{{.ImportPath}}'`
  local import_path = go_import_path(dir)
  if not import_path then
    return
  end

  --- go test -v -timeout 30s -run ^$ -benchmem -bench "^Benchmark.*" ImportPath
  local cmd = 'cd ' .. dir .. ' && go test -v -timeout 30s -run ^$ -benchmem -bench "^Benchmark.*" ' .. import_path
  _Exec(cmd)
end
-- -- }}}

--- fuzz 不能使用 pprof flags. eg: -cpuprofile ...; 但可以使用 -cover flags
--- go test fuzz Package --------------------------------------------------------------------------- {{{
local function go_test_fuzz_pkg()
  --- 判断当前文件是否是 _test.go
  if not string.match(vim.fn.expand('%:t'), "_test%.go$") then
    Notify('not "_test.go" file',"ERROR")
    return
  end

  --- 获取当前文件所在文件夹路径.
  local dir = vim.fn.expand('%:h')

  --- 获取 go import path, `cd src/xxx && go list -f '{{.ImportPath}}'`
  local import_path = go_import_path(dir)
  if not import_path then
    return
  end

  --- go test -v -run ^$ -fuzztime 30s -fuzz "^Fuzz.*" ImportPath
  local cmd = 'cd ' .. dir .. ' && go test -v -fuzztime 30s -run ^$ -fuzz "^Fuzz.*" ' .. import_path
  _Exec(cmd)
end
-- -- }}}

--- go test single function ------------------------------------------------------------------------ {{{
local function get_func_line()  -- return (func_name: string|nil)
  local lcontent = vim.fn.getline('.')  -- 获取行内容

  --- 如果找到 ^func.* 则返回整行内容.
  if string.match(lcontent, "^func .*") then
    return lcontent
  end
  --- 如果没找到则返回 nil
end

--- 返回 Test Function Name, "TestXxx(t *testing.T)", "BenchmarkXxx(b *testing.B)", "FuzzXxx(f *testing.F)"
--- NOTE: mark - 0: error | 1: TestXxx | 2: BenchmarkXxx | 3: FuzzXxx
local function go_test_func_name()  -- return {funcname: string|nil, mark :number}
  local func_line = get_func_line()
  if not func_line then
    return nil, 0
  end

  --- NOTE: go test 函数不允许 func [T any]TestXxx(), 不允许有 type param.
  --- %w     - 单个 char [a-zA-Z0-9]
  --- [%w_]  - 单个 char [a-zA-Z0-9] && _
  --- [BFMT] - 单个 char B|F|M|T

  local testfn = string.match(func_line, "func Test[%w_]*%([%w_]* %*testing%.T%)")
  if testfn then
    return string.match(testfn, "Test[%w_]*"), 1
  end

  testfn = string.match(func_line, "func Benchmark[%w_]*%([%w_]* %*testing%.B%)")
  if testfn then
    return string.match(testfn, "Benchmark[%w_]*"), 2
  end

  testfn = string.match(func_line, "func Fuzz[%w_]*%([%w_]* %*testing%.F%)")
  if testfn then
    return string.match(testfn, "Fuzz[%w_]*"), 3
  end

  return nil, 0
end

--- 返回 "go test -v -run TestFoo ImportPath"
local function go_test_cmd()   -- return (cmd: string|nil)
  --- 判断当前文件是否 _test.go
  if not string.match(vim.fn.expand('%:t'), "_test%.go$") then
    Notify('not "_test.go" file',"ERROR")
    return
  end

  --- 判断当前函数是否 TestXXX. 如果是则 获取 test function name.
  local testfn_name, mark = go_test_func_name()
  if not testfn_name or mark == 0 then
    Notify('Please Put cursor on "func TestXXX()"',"WARN")
    return
  end

  --- add regexp pattern to test function name
  local testfn_name_regexp = '^' .. testfn_name .. '$'

  --- 获取当前文件所在文件夹路径.
  local dir = vim.fn.expand('%:h')

  --- 获取 go import path, `cd src/xxx && go list -f '{{.ImportPath}}'`
  local import_path = go_import_path(dir)
  if not import_path then
    return
  end

  local cmd
  if mark == 1 then
    --- go test -v -timeout 10s -run TestXxx ImportPath
    cmd = 'cd ' .. dir .. " && go test -v -timeout 10s -run " .. testfn_name_regexp .. " " .. import_path
  end

  if mark == 2 then
    --- go test -v -timeout 10s -run ^$ -benchmem -bench BenchmarkXxx ImportPath
    cmd = 'cd ' .. dir .. " && go test -v -timeout 10s -run ^$ -benchmem -bench " .. testfn_name_regexp .. " " .. import_path
  end

  if mark == 3 then
    --- go test -v -run ^$ -fuzztime 30s -fuzz FuzzXxx ImportPath
    cmd = 'cd ' .. dir .. " && go test -v -fuzztime 15s -run ^$ -fuzz " .. testfn_name_regexp .. " " .. import_path
  end

  return cmd
end

--- 通过 Terminal 运行 cmd ---
local function go_test_single_func()
  local cmd = go_test_cmd()
  if not cmd then
    return
  end

  _Exec(cmd)
end
-- -- }}}

--- NOTE: cannot use -fuzz flag with multiple packages.
--- go test run/bench Project ---------------------------------------------------------------------- {{{
--- opt = 'run' | 'bench'
local function go_test_proj(opt)
  --- './...' 表示当前 pwd 下的所有 packages, 即整个 Project.
  local cmd
  if opt == 'bench' then
    cmd = 'go test -v -timeout 3m -run ^$ -benchmem -bench "^Benchmark.*" ./...'
  else
    cmd = 'go test -v ./...'
  end
  _Exec(cmd)
end
-- -- }}}

--- key mapping ------------------------------------------------------------------------------------
local opt = {noremap = true, buffer = true}
local go_keymaps = {
  {'n', '<F5>', go_run, opt, "code: Run"},

  {'n', '<F6>', go_test_single_func, opt, "code: Run Test/Bench (Single)"},
  {'n', '<F18>', go_test_run_pkg, opt, "code: Run Test (Package)"},   -- <S-F6>
  {'n', '<F30>', go_test_bench_pkg, opt, "code: Run Benchmark (Package)"},  -- <C-F6>
}

Keymap_set_and_register(go_keymaps)

--- NOTE:
--- <F6> go test Run/Benchmark/Fuzz single function, No Prompt.
--- <S-F6> run test single function with options/flags
--    - go test Run Single function
--        - coverage
--        - pprof
--    - go test Benchmark Single function -benchtime (默认 1s)
--    - go test Fuzz Single function, -fuzzminimizetime, -fuzztime
--        - FuzzTime 30s
--        - FuzzTime 60s
--        - FuzzTime 3m
--        - FuzzTime 6m
--        - FuzzTime 10m
--
--- :GoTest prompt inputlist.
--    - go test Run Package
--        - coverage
--        - pprof
--    - go test Benchmark Package
--    - go test /Fuzz Package
--    - go test Run Project
--        - coverage
--        - pprof
--    - go test Benchmark Project
--    - go test /Fuzz Project

--- NOTE: cover.out 文件必须在 workspace 中, 否则无法进行分析.
--- '-coverage' 不会生成 [pkg].text 文件.

--- NOTE: pprof profile 文件生成的同时会生成一个 [pkg].text 文件, 可以在执行完成后删除 `$ rm *.test`.
--- -http=: 意思是使用默认 localhost:random_available_port, 也可以使用 -http=:18080



