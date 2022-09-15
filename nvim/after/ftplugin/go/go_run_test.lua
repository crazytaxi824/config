--- Go Functions -----------------------------------------------------------------------------------
--- README:
--    获取 go import path, `cd src/xxx && go list -f '{{.ImportPath}}'`
--    获取 go module, `go list -m`, 项目中的任何路径下都能获取到.
--    lua regex - string.match(), https://fhug.org.uk/kb/kb-article/understanding-lua-patterns/
--
--  Go Test 操作方法:
--    cursor 指向 Test Function Name Line, 使用 <F6> 执行 go test singleTestFunc

--- VVI: 获取 go import path, `cd src/xxx && go list -f '{{.ImportPath}}'` ------------------------- {{{
local function go_import_path(dir)
  local result = vim.fn.system("cd " .. dir .. " && go list -f '{{.ImportPath}}'")
  if vim.v.shell_error ~= 0 then
    Notify(result,"ERROR")
    return
  end

  return string.match(result, "[%S ]*")  -- return import_path WITHOUT '\n'
end
-- -- }}}

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
  local cmd = "cd " .. dir .. " && go run " .. import_path
  print(cmd)
  _Exec(cmd, true)  -- cache cmd for re-run.
end
-- -- }}}

--- `$ go help testflag` --------------------------------------------------------------------------- {{{
--- go test run        可以使用 coverage, pprof flags, eg: -cover, -coverprofile, -cpuprofile, -memprofile ...
--- go test benchmark  可以使用 coverage, pprof flags, eg: -cover, -coverprofile, -cpuprofile, -memprofile ...
--- go test fuzz       不能使用 pprof flags. eg: -cpuprofile ...; 也不能使用 -cover -coverprofile flags
--- go test xxx multiple packages  不能使用 pprof flags, 但是可以使用 -cover -coverprofile flags

--- VVI: go test flags
--- 使用 -memprofile ... flags 时会先生成一个 [pkg].test 文件, 然后 [pkg].test 会自动运行生成 profile 文件.
---     [pkg].test 文件可以在执行完成后删除 `$ rm *.test`, 不影响后续分析命令.
--- 使用 -coverprofile 生成的 cover.out 文件必须在 workspace 中, 否则无法进行分析. '-coverprofile' 不会生成 [pkg].test 文件.
--- 使用 -trace 不会生成 [pkg].test 文件, trace.out 也不需要在 workspace 中.

--- 分析 *.out 文件的方法
--- 分析 -coverprofile 生成的文件使用 `go tool cover -html=cover.out -o cover.html` 生成 html 文件, 可以用浏览器打开查看详细信息.
--- 分析 -memprofile, -cpuprofile, -mutexprofile, -blockprofile 使用 `go tool pprof -http=: mem.out`;
---     "-http=:" 意思是使用默认 localhost:random_available_port, 也可以使用 -http=:18080 指定 port.
--- 分析 -trace 生成的文件使用 `go tool trace trace.out`, trace 中的 "-http=localhost:" 必须指定 localhost

--- NOTE: 完整命令
-- local cmd = 'cd ' .. dir
--   .. ' && mkdir -p ' .. pprof_dir .. ' ' .. coverage_dir
--   .. ' && go test -v'
--
--   --- go tool cover -html=profile/cover.out -o profile/coverage.html
--   --- NOTE: cover.out 文件必须在 workspace 中, 否则无法进行分析.
--   --- '-coverage' 不会生成 [pkg].text 文件.
--   .. ' -cover -coverprofile '.. coverage_dir .. 'cover.out'
--
--   --- NOTE: pprof profile 文件生成的同时会生成一个 [pkg].text 文件, 可以在执行完成后删除.
--   --- -http=: 意思是使用默认 localhost:random_available_port, 也可以使用 -http=:18080
--   .. ' -blockprofile block.out'   -- go tool pprof -http=: profile/block.out
--   .. ' -cpuprofile cpu.out'       -- go tool pprof -http=: profile/cpu.out
--   .. ' -memprofile mem.out'       -- go tool pprof -http=: profile/mem.out
--   .. ' -mutexprofile mutex.out'   -- go tool pprof -http=: profile/mutex.out
--   .. ' -trace trace.out'          -- go tool trace profile/trace.out
--   .. ' -outputdir ' .. pprof_dir
--
--   .. ' -timeout 30s -run "^Test.*" ' .. import_path
--   .. ' && rm ./*.test'  -- remove pkg.text 可执行文件.

local pprof_dir = vim.fn.fnamemodify(vim.fn.stdpath('cache')..'/go/pprof/', ':p')
local coverage_dir = vim.fn.getcwd() .. '/coverage/'

local flag_desc_cmd = {
  none = { desc = '[No Extra Flag]', cmd = {prefix='', flag='', suffix=''} },
  cpu = {
    desc = 'CPU profile',
    cmd = {
      prefix = ' mkdir -p ' .. pprof_dir .. ' &&' ,
      flag = ' -cpuprofile ' .. pprof_dir .. 'cpu.out',
      --- NOTE: 删除 [pkg].test 文件 && 打开浏览器, 分析文件.
      suffix = ' && rm *.test && go tool pprof -http=localhost: ' .. pprof_dir .. 'cpu.out'
    }
  },
  mem = {
    desc = 'Memory profile',
    cmd = {
      prefix = ' mkdir -p ' .. pprof_dir .. ' &&' ,
      flag = ' -memprofile ' .. pprof_dir .. 'mem.out',
      suffix = ' && rm *.test && go tool pprof -http=localhost: ' .. pprof_dir .. 'mem.out'
    }
  },
  mutex = {
    desc = 'Mutex profile',
    cmd = {
      prefix = ' mkdir -p ' .. pprof_dir .. ' &&' ,
      flag = ' -mutexprofile ' .. pprof_dir .. 'mutex.out',
      suffix = ' && rm *.test && go tool pprof -http=localhost: ' .. pprof_dir .. 'mutex.out'
    }
  },
  block = {
    desc = 'Block profile',
    cmd = {
      prefix = ' mkdir -p ' .. pprof_dir .. ' &&' ,
      flag = ' -blockprofile ' .. pprof_dir .. 'block.out',
      suffix = ' && rm *.test && go tool pprof -http=localhost: ' .. pprof_dir .. 'block.out'
    }
  },
  trace = {
    desc = 'Trace',
    cmd = {
      prefix = ' mkdir -p ' .. pprof_dir .. ' &&' ,
      flag = ' -trace ' .. pprof_dir .. 'trace.out',
      suffix = ' && go tool trace -http=localhost: ' .. pprof_dir .. 'trace.out'
    }
  },
  cover = {
    desc = 'Coverage print on screen',
    cmd = {
      prefix = '' ,
      flag = ' -cover',
      suffix = ''
    }
  },
  coverprofile = {
    desc = 'Coverage profile (detail)',
    cmd = {
      prefix = ' mkdir -p ' .. coverage_dir .. ' &&' ,
      flag = ' -coverprofile ' .. coverage_dir .. 'cover.out',
      --- VVI: 这里是 ; 而不是 &&. 因为 "coverage: [no statements] FAIL" 时 os.exit() 返回不是 0, 使用 && 会导致后续无法运行.
      suffix = ' ; go tool cover -html=' .. coverage_dir .. 'cover.out -o ' .. coverage_dir .. 'cover.html'
        .. ' && open ' .. coverage_dir .. 'cover.html',
    }
  },

  --- fuzztime flags
  fuzz_default = { desc = '[Default]: fuzztime 15s', cmd = {prefix='', flag='', suffix=''} },
  fuzz30s = { desc = 'fuzztime 30s', cmd = {prefix='', flag=' -fuzztime 30s', suffix=''} },
  fuzz60s = { desc = 'fuzztime 60s', cmd = {prefix='', flag=' -fuzztime 60s', suffix=''} },
  fuzz5m = { desc = 'fuzztime 5m', cmd = {prefix='', flag=' -fuzztime 5m', suffix=''} },
  fuzz10m = { desc = 'fuzztime 10m', cmd = {prefix='', flag=' -fuzztime 10m', suffix=''} },
  fuzz_input = { desc = 'Input fuzztime: 1h2m30s (duration) | 1000x (times)', cmd = {} },  -- NOTE: 这里的 cmd 内容需要根据 input 来设置.
}

--- 统一处理 flag 特殊情况.
local function parse_flag(flag)
  if not flag then
    Notify('flag is nil', "DEBUG")
    return
  end

  --- NOTE: 根据用户 input 设置 -fuzztime cmd 内容.
  if flag == 'fuzz_input' then
    local fuzz_cmd
    vim.ui.input({prompt = 'Input -fuzztime: '}, function(input)
      fuzz_cmd = { prefix = '', flag = ' -fuzztime '..input, suffix = '' }
    end)
    return fuzz_cmd
  end

  local f = flag_desc_cmd[flag]
  if not f then
    Notify('flag: "' .. flag .. '" is not exist', "DEBUG")
    return
  end

  return f.cmd
end
-- -- }}}

--- go test single function under the cursor ------------------------------------------------------- {{{
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

--- opt.mode: 'run' | 'bench' | 'fuzz'
--- return (cmd: string|nil), eg: cmd = "go test -v -run TestFoo ImportPath"
local function go_test_cmd(testfn_name, opt)
  --- 判断 flag 是否存在. Internal
  local flag_cmd = parse_flag(opt.flag)
  if not flag_cmd then
    return
  end

  --- add regexp pattern to test function name
  local testfn_name_regexp = '"^' .. testfn_name .. '$" '

  --- 获取当前文件所在文件夹路径.
  local dir = vim.fn.expand('%:h')

  --- 获取 go import path, `cd src/xxx && go list -f '{{.ImportPath}}'`
  local import_path = go_import_path(dir)
  if not import_path then
    return
  end

  local cmd = 'cd ' .. dir .. ' &&' .. flag_cmd.prefix
  if opt.mode == 'run' then
    --- go test -v -timeout 10s -run TestXxx ImportPath
    cmd = cmd .. ' go test -v' .. flag_cmd.flag .. ' -timeout 10s -run ' .. testfn_name_regexp .. import_path .. flag_cmd.suffix
  elseif opt.mode == 'bench' then
    --- go test -v -timeout 10s -run ^$ -benchmem -bench BenchmarkXxx ImportPath
    cmd = cmd .. ' go test -v' .. flag_cmd.flag .. ' -timeout 10s -run ^$ -benchmem -bench ' .. testfn_name_regexp .. import_path .. flag_cmd.suffix
  elseif opt.mode == 'fuzz' then
    --- go test -v -run ^$ -fuzztime 30s -fuzz FuzzXxx ImportPath
    cmd = cmd .. ' go test -v -fuzztime 15s' .. flag_cmd.flag .. ' -run ^$ -fuzz ' .. testfn_name_regexp .. import_path .. flag_cmd.suffix
  else
    Notify("gen go test cmd error, {opt.mode} should be: 'run' | 'bench' | 'fuzz'", "DEBUG")
    return
  end

  return cmd
end

--- 通过 Terminal 运行 cmd ---
local function go_test_single_func(prompt)
  --- 判断当前文件是否 _test.go
  if not string.match(vim.fn.expand('%:t'), "_test%.go$") then
    Notify('not "_test.go" file',"ERROR")
    return
  end

  --- 判断当前函数是否 TestXXX. 如果是则 获取 test function name.
  local testfn_name, mode = get_test_func_name()
  if not testfn_name or not mode then
    Notify('Please Put cursor on "func Test/Benchmark/Fuzz_XXX()"', "INFO")
    return
  end

  local cmd
  if not prompt then
    cmd = go_test_cmd(testfn_name, {mode=mode, flag = 'none'})
  else
    if mode == 'run' or mode == 'bench' then
      local select = {'none', 'cpu', 'mem', 'mutex', 'block', 'trace', 'cover', 'coverprofile'}
      vim.ui.select(select, {
        prompt = 'choose go test flag:',
        format_item = function(item)
          return flag_desc_cmd[item].desc
        end
      }, function (choice)
        if choice then
          cmd = go_test_cmd(testfn_name, {mode=mode, flag = choice})
        end
      end)
    elseif mode == 'fuzz' then
      local select = {'fuzz_default', 'fuzz30s', 'fuzz60s', 'fuzz5m', 'fuzz10m', 'fuzz_input'}
      vim.ui.select(select, {
        prompt = 'choose go test flag:',
        format_item = function(item)
          return flag_desc_cmd[item].desc
        end
      }, function (choice)
        if choice then
          cmd = go_test_cmd(testfn_name, {mode=mode, flag = choice})
        end
      end)
    end
  end

  if cmd then
    -- print(cmd)
    _Exec(cmd)
  end
end
-- -- }}}

--- go test run current Package -------------------------------------------------------------------- {{{
--- opt.mode: 'run' | 'bench'
--- NOTE: 不能同时运行多个 fuzz test. Error: will not fuzz, -fuzz matches more than one fuzz test.
local function go_test_pkg(opt)
  --- 判断当前文件是否是 _test.go
  if not string.match(vim.fn.expand('%:t'), "_test%.go$") then
    Notify('not "_test.go" file',"ERROR")
    return
  end

  opt = opt or {}
  --- 判断 flag 是否存在. Internal
  local flag_cmd = parse_flag(opt.flag)
  if not flag_cmd then
    return
  end

  --- 获取当前文件所在文件夹路径.
  local dir = vim.fn.expand('%:h')

  --- 获取 go import path, `cd src/xxx && go list -f '{{.ImportPath}}'`
  local import_path = go_import_path(dir)
  if not import_path then
    return
  end

  local cmd = 'cd ' .. dir .. ' &&' .. flag_cmd.prefix
  --- NOTE: 不能同时运行多个 fuzz test. Error: will not fuzz, -fuzz matches more than one fuzz test.
  if opt.mode == 'run' then
    --- go test -v -timeout 30s -run "^Test.*" ImportPath
    cmd = cmd .. ' go test -v' .. flag_cmd.flag .. ' -timeout 30s -run "^Test.*" ' .. import_path .. flag_cmd.suffix
  elseif opt.mode == 'bench' then
    --- go test -v -timeout 30s -run ^$ -benchmem -bench "^Benchmark.*" ImportPath
    cmd = cmd .. ' go test -v' .. flag_cmd.flag .. ' -timeout 30s -run ^$ -benchmem -bench "^Benchmark.*" ' .. import_path .. flag_cmd.suffix
  else  -- error
    Notify("go test package {opt.mode} should be: 'run' | 'bench'", "DEBUG")
    return
  end

  -- print(cmd)
  _Exec(cmd)
end
-- -- }}}

--- go test run/bench multiple packages (Project) -------------------------------------------------- {{{
--- opt.mode = 'run' | 'bench'
local function go_test_proj(opt)
  opt = opt or {}
  --- 判断 flag 是否存在. Internal
  local flag_cmd = parse_flag(opt.flag)
  if not flag_cmd then
    return
  end

  --- './...' 表示当前 pwd 下的所有 packages, 即整个 Project.
  local cmd

  --- NOTE: cannot use -fuzz flag with multiple packages.
  if opt.mode == 'run' then
    cmd = flag_cmd.prefix .. ' go test -v' .. flag_cmd.flag .. ' -timeout 3m ./...' .. flag_cmd.suffix
  elseif opt.mode == 'bench' then
    cmd = flag_cmd.prefix .. ' go test -v' .. flag_cmd.flag .. ' -timeout 5m -run ^$ -benchmem -bench "^Benchmark.*" ./...' .. flag_cmd.suffix
  else  -- error
    Notify("go test multiple packages {opt.mode} should be: 'run' | 'bench'", "DEBUG")
    return
  end

  -- print(cmd)
  _Exec(cmd)
end
-- -- }}}

--- key mapping ------------------------------------------------------------------------------------ {{{
--- <F6> go test Run/Benchmark/Fuzz single function, No Prompt.
--- <S-F6> run test single function with options/flags
--   - go test Run Single function
--      - pprof
--      - trace
--      - coverage
--   - go test Benchmark Single function -benchtime (默认 1s)
--      - pprof
--      - trace
--      - coverage
--   - go test Fuzz Single function, -fuzztime
--      - FuzzTime 30s
--      - FuzzTime 60s
--      - FuzzTime 3m
--      - FuzzTime 6m
--      - FuzzTime 10m
--      - FuzzTime ?
local opt = {noremap = true, buffer = true}
local go_keymaps = {
  {'n', '<F5>', go_run, opt, "code: Run"},

  {'n', '<F6>', go_test_single_func, opt, "code: Run Test/Bench (Single)"},
  {'n', '<F18>', function() go_test_single_func(true) end, opt, "code: Run Test (Package)"},   -- <S-F6>
}

Keymap_set_and_register(go_keymaps)

-- -- }}}

--- commands --------------------------------------------------------------------------------------- {{{
-- - go test Run current Package
--     - pprof
--     - trace
--     - coverage
-- - go test Benchmark current Package
--     - pprof
--     - trace
--     - coverage
-- - go test Run multiple packages (Project)
--     - coverage
-- - go test Benchmark multiple packages (Project)
--     - coverage
vim.api.nvim_buf_create_user_command(0, "GoTestRunPackage", function()
  local select = {'none', 'cpu', 'mem', 'mutex', 'block', 'trace', 'cover', 'coverprofile'}
  vim.ui.select(select, {
    prompt = 'choose go test flag:',
    format_item = function(item)
      return flag_desc_cmd[item].desc
    end
  }, function (choice)
    if choice then
      go_test_pkg({mode = 'run', flag = choice })
    end
  end)
end, {bang=true})

vim.api.nvim_buf_create_user_command(0, "GoTestRunPoject", function()
  -- cannot use pprof flag with multiple packages
  local select = {'none', 'cover', 'coverprofile'}
  vim.ui.select(select, {
    prompt = 'choose go test flag:',
    format_item = function(item)
      return flag_desc_cmd[item].desc
    end
  }, function (choice)
    if choice then
      go_test_proj({mode = 'run', flag = choice })
    end
  end)
end, {bang=true})

vim.api.nvim_buf_create_user_command(0, "GoTestBenchmarkPackage", function()
  local select = {'none', 'cpu', 'mem', 'mutex', 'block', 'trace', 'cover', 'coverprofile'}
  vim.ui.select(select, {
    prompt = 'choose go test flag:',
    format_item = function(item)
      return flag_desc_cmd[item].desc
    end
  }, function (choice)
    if choice then
      go_test_pkg({mode = 'bench', flag = choice })
    end
  end)
end, {bang=true})

vim.api.nvim_buf_create_user_command(0, "GoTestBenchmarkPoject", function()
  -- cannot use pprof flag with multiple packages
  local select = {'none', 'cover', 'coverprofile'}
  vim.ui.select(select, {
    prompt = 'choose go test flag:',
    format_item = function(item)
      return flag_desc_cmd[item].desc
    end
  }, function (choice)
    if choice then
      go_test_proj({mode = 'bench', flag = choice })
    end
  end)
end, {bang=true})
-- -- }}}



