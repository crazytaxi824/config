--- `$ go help testflag` --------------------------------------------------------------------------- {{{
--- go test run        能使用 pprof & cover & trace flags.
--- go test benchmark  能使用 pprof & cover & trace flags.
--- go test fuzz       NOTE: 不能使用 pprof & cover & trace flags. 每次只能执行一个 fuzz test,
---                    eg: 如果 package 中有多个 Fuzz test 函数 `go test -fuzz "^Fuzz.*"` 会报错.
--- go test xxx multiple packages  无法使用 pprof flags, 但是可以使用 -cover -coverprofile flags

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
--   --- 指定可执行文件 [pkg].test 的位置. 这里 -o 是 `$ go help build` 的 flag.
--   --- 默认在 pwd 下, 名字为 package 的名字, 例如: go test ... local/src/foo 执行后名字为 foo.test
--   .. ' -o pkg.test'
--
--   --- NOTE: 以下所有分析报告文件生成的路径都在该路径下, 除非指定绝对路径.
--   --- eg: '-cpuprofile a/b/c.out'  文件会生成在 pprof_dir/a/b/c.out#region
--   --- eg: '-cpuprofile /a/b/c.out' 文件会生成在 /a/b/c.out
--   .. ' -outputdir ' .. pprof_dir
--
--   --- NOTE: cover.out 文件必须在 workspace 中, 否则无法进行分析.
--   --- '-coverage' 不会生成 [pkg].text 文件.
--   .. ' -cover -coverprofile '.. coverage_dir .. 'cover.out'  -- go tool cover -html=cover.out -o cover.html
--
--   --- NOTE: pprof profile 文件生成的同时会生成一个 [pkg].text 文件, 可以在执行完成后删除.
--   --- -http=: 意思是使用默认 localhost:random_available_port, 也可以使用 -http=:18080
--   .. ' -blockprofile block.out'   -- go tool pprof -http=localhost: block.out
--   .. ' -cpuprofile cpu.out'       -- go tool pprof -http=localhost: cpu.out
--   .. ' -memprofile mem.out'       -- go tool pprof -http=localhost: mem.out
--   .. ' -mutexprofile mutex.out'   -- go tool pprof -http=localhost: mutex.out
--   .. ' -trace trace.out'          -- go tool trace -http=localhost: trace.out
--
--   .. ' -timeout 30s -run "^Test.*" ' .. ImportPath
--   .. ' && rm ./*.test'  -- remove pkg.text 可执行文件.
-- -- }}}

local M = {}

--- NOTE: 必须是绝对路径.
local pprof_dir = '/tmp/nvim/go_pprof/'

--- mkdir when module required, NOTE: will run only once.
local result = vim.system({'mkdir', '-p', pprof_dir}, { text = true }):wait()
if result.code ~= 0 then
  error(result.stderr ~= '' and result.stderr or result.code)
end

local pprof_flags = ' -o ' .. pprof_dir .. 'pkg.test'  -- [pkg].test 可执行文件生成位置,
                                                       -- 这个是 `$ go help build` 的 flag.
  .. ' -outputdir ' .. pprof_dir  -- 以下所有 profile 文件生成的路径都在该路径下, 除非指定绝对路径.
                                  -- eg: '-cpuprofile a/b/c.out'  文件会生成在 pprof_dir/a/b/c.out
                                  -- eg: '-cpuprofile /a/b/c.out' 文件会生成在 /a/b/c.out
  .. ' -cpuprofile cpu.out'
  .. ' -memprofile mem.out'
  .. ' -mutexprofile mutex.out'
  .. ' -blockprofile block.out'
  .. ' -trace trace.out'
  --- 使用 -coverprofile 生成的 cover.out 文件必须在 workspace 中, 否则无法进行分析.
  --- 这里的 cover.out 不会生成在 -outputdir 指定的文件夹内, 因为 coverage_dir 是绝对路径.
  -- .. ' -coverprofile ' .. coverage_dir .. 'cover.out'  -- NOTE: 单独使用 -coverprofile,
                                                          -- 不在这里统一生成报告.

--- VVI:
--- cmd - table|function, 不能为 nil, 包含 {prefix, flag, suffix} 三个 shell command/flag.
--- prefix/suffix/flag 可以为 string | nil.
local flag_desc_cmd = {
  --- 没有任何 testflag 的情况.
  none = { desc = '[No Extra Flag]', cmd = {} },  -- VVI: cmd 不能为 nil.

  --- pprof 的 4 个 testflag, '-cpuprofile', '-memprofile', '-blockprofile', '-mutexprofile'
  cpu = {
    desc = 'CPU profile',
    cmd = {
      -- prefix = 'mkdir -p ' .. pprof_dir,  -- mkdir when module required, only run once
      flag = pprof_flags,
      suffix = 'go tool pprof -http=localhost: ' .. pprof_dir .. 'cpu.out'
    }
  },
  mem = {
    desc = 'Memory profile',
    cmd = {
      -- prefix = 'mkdir -p ' .. pprof_dir,
      flag = pprof_flags,
      suffix = 'go tool pprof -http=localhost: ' .. pprof_dir .. 'mem.out'
    }
  },
  mutex = {
    desc = 'Mutex profile',
    cmd = {
      -- prefix = 'mkdir -p ' .. pprof_dir,
      flag = pprof_flags,
      suffix = 'go tool pprof -http=localhost: ' .. pprof_dir .. 'mutex.out'
    }
  },
  block = {
    desc = 'Block profile',
    cmd = {
      -- prefix = 'mkdir -p ' .. pprof_dir,
      flag = pprof_flags,
      suffix = 'go tool pprof -http=localhost: ' .. pprof_dir .. 'block.out'
    }
  },

  --- '-trace' testflag
  trace = {
    desc = 'Trace',
    cmd = {
      -- prefix = 'mkdir -p ' .. pprof_dir,
      flag = pprof_flags,
      suffix = 'go tool trace -http=localhost: ' .. pprof_dir .. 'trace.out'
    }
  },

  --- '-cover' flag 只在 terminal 中显示覆盖率, 不会生成任何文件.
  cover = {
    desc = 'Coverage print on screen',
    cmd = { flag = ' -cover' },
  },

  --- NOTE: 使用 '-coverprofile' 生成的 'cover.out' 文件必须在 go workspace 中, 否则无法进行分析.
  --- '-coverprofile /xxx/cover.out' 最好是是绝对路径, 避免和 '-outputdir' 冲突.
  coverprofile = {
    desc = 'Coverage profile (detail)',
    cmd = function(go_list)
      if not go_list then
        Notify("{go_list} is nil", "ERROR")
        return
      end

      --- NOTE: 如果是 `go test -coverprofile ./...` , go_list 中需要传递 project 属性, 用于指定文件名.
      local cover_filename = go_list.project or string.gsub(go_list.ImportPath, '/', '%%')

      local coverage_dir = go_list.Root .. '/coverage/'
      return {
        prefix = 'mkdir -p ' .. coverage_dir,

        --- NOTE: 这里推荐使用绝对路径, 不受 pwd 影响.
        flag = ' -coverprofile ' .. coverage_dir .. cover_filename .. '_cover.out',

        --- go tool cover -html=cover.out -o cover.html
        --- NOTE: 执行 `go tool cover` 时 pwd 必须在 project 中.
        suffix = 'cd ' .. coverage_dir .. ' && go tool cover -html=' .. cover_filename
          .. '_cover.out -o ' .. cover_filename .. '_cover.html'
          .. ' && open ' .. cover_filename .. '_cover.html',  -- 使用操作系统打开 cover.html 文件
      }
    end
  },

  --- fuzztime flags
  fuzz30s = { desc = 'fuzztime 30s', cmd = {flag = ' -fuzztime 30s'} },
  fuzz60s = { desc = 'fuzztime 60s', cmd = {flag = ' -fuzztime 60s'} },
  fuzz5m  = { desc = 'fuzztime 5m',  cmd = {flag = ' -fuzztime 5m' } },
  fuzz10m = { desc = 'fuzztime 10m', cmd = {flag = ' -fuzztime 10m'} },

  --- NOTE: 这里的 cmd 内容需要根据 input 来设置.
  fuzz_input = {
    desc = 'Input fuzztime: 15s|20m|1h20m30s (duration) | 1000x (times)',
    cmd = function()
      local fuzz_cmd
      vim.ui.input({prompt = 'Input -fuzztime: '}, function(input)
        if input then
          fuzz_cmd = { flag = ' -fuzztime '..input}
        end
      end)
      return fuzz_cmd
    end
  },
}

--- 返回 description
M.get_testflag_desc = function(flag)
  local f = flag_desc_cmd[flag]
  if not f then
    return '[flag: "' .. flag .. '" is NOT in "testflags.lua" table]'
  end
  if not f.desc then
    return '[flag: "' .. flag .. '.desc" is MISSING from "testflags.lua" table]'
  end

  return f.desc
end

--- 统一处理 flag 特殊情况
M.parse_testflag_cmd = function(flag, go_list)
  if not flag then
    Notify('flag is nil', "DEBUG")
    return
  end

  local f = flag_desc_cmd[flag]
  if not f then
    Notify('flag: "' .. flag .. '" is NOT in "testflags.lua" table', "DEBUG")
    return
  end
  if not f.cmd then
    --- 这里是提醒 flag.cmd 未设置.
    Notify('flag: "' .. flag .. '.cmd" is MISSING from "testflags.lua" table', "DEBUG")
    return
  end

  --- VVI: 这里不能直接使用 f.cmd = f.cmd(), 因为第一次执行的时候 f.cmd 是一个 function,
  --- 而第二次执行的时候 f.cmd 已经变成一个 table 了.
  local flag_cmd
  local typ = type(f.cmd)
  if typ == 'function' then
    flag_cmd = f.cmd(go_list)
  elseif typ == 'table' then
    flag_cmd = f.cmd
  else
    Notify('flag: "' .. flag .. '.cmd" type error', "DEBUG")
    return
  end

  if flag_cmd then
    --- 确保 cmd.flag 不是 nil.
    flag_cmd.flag = flag_cmd.flag or ''
    return flag_cmd
  end
end

return M
