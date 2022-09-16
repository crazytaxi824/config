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
-- -- }}}

local M = {}

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

--- 返回 description
M.get_testflag_desc = function(flag)
  return flag_desc_cmd[flag].desc
end

--- 统一处理 flag 特殊情况
M.parse_testflag_cmd = function(flag)
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

return M
