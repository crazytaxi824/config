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
--   --- 指定可执行文件 [pkg].test 的位置. 这里 -o 是 `$ go help build` 的 flag.
--   --- 默认在 pwd 下, 名字为 package 的名字, 例如: go test ... local/src/foo 执行后名字为 foo.test
--   .. ' -o pkg.test'
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

--- NOTE: 这两个路径必须是绝对路径.
local pprof_dir = vim.fn.fnamemodify(vim.fn.stdpath('cache')..'/go/pprof/', ':p')  -- mkdir 用到必须是绝对路径.
local coverage_dir = vim.fn.fnamemodify(vim.fn.getcwd() .. '/coverage/', ':p')  -- '-coverprofile' 用到, 必须是绝对路径.

local pprof_flags = ' -o ' .. pprof_dir .. 'pkg.test'  -- [pkg].test 可执行文件生成位置, 这个是 `$ go help build` 的 flag.
  .. ' -outputdir ' .. pprof_dir  -- 以下所有 profile 文件生成的路径都在该路径下, 除非指定绝对路径.
                                 -- eg: '-cpuprofile a/b/c.out'  文件会生成在 pprof_dir/a/b/c.out
                                 -- eg: '-cpuprofile /a/b/c.out' 文件会生成在 /a/b/c.out
  .. ' -cpuprofile cpu.out'
  .. ' -memprofile mem.out'
  .. ' -mutexprofile mutex.out'
  .. ' -blockprofile block.out'
  .. ' -trace trace.out'

  --- 使用 -coverprofile 生成的 cover.out 文件必须在 workspace 中, 否则无法进行分析.
  --- 这里的 cover.out 就会生成在另外的文件夹内, 因为 coverage_dir 是绝对路径.
  -- .. ' -coverprofile ' .. coverage_dir .. 'cover.out'  -- NOTE: 单独使用 -coverprofile, 不在这里统一生成报告.

local flag_desc_cmd = {
  none = { desc = '[No Extra Flag]', cmd = {prefix='', flag='', suffix=''} },
  cpu = {
    desc = 'CPU profile',
    cmd = {
      prefix = ' mkdir -p ' .. pprof_dir .. ' &&' ,
      flag = pprof_flags,
      --- NOTE: 删除 [pkg].test 文件 && 打开浏览器, 分析文件.
      suffix = 'go tool pprof -http=localhost: ' .. pprof_dir .. 'cpu.out'
    }
  },
  mem = {
    desc = 'Memory profile',
    cmd = {
      prefix = ' mkdir -p ' .. pprof_dir .. ' &&' ,
      flag = pprof_flags,
      suffix = 'go tool pprof -http=localhost: ' .. pprof_dir .. 'mem.out'
    }
  },
  mutex = {
    desc = 'Mutex profile',
    cmd = {
      prefix = ' mkdir -p ' .. pprof_dir .. ' &&' ,
      flag = pprof_flags,
      suffix = 'go tool pprof -http=localhost: ' .. pprof_dir .. 'mutex.out'
    }
  },
  block = {
    desc = 'Block profile',
    cmd = {
      prefix = ' mkdir -p ' .. pprof_dir .. ' &&' ,
      flag = pprof_flags,
      suffix = 'go tool pprof -http=localhost: ' .. pprof_dir .. 'block.out'
    }
  },
  trace = {
    desc = 'Trace',
    cmd = {
      prefix = ' mkdir -p ' .. pprof_dir .. ' &&' ,
      flag = pprof_flags,
      suffix = 'go tool trace -http=localhost: ' .. pprof_dir .. 'trace.out'
    }
  },

  --- '-cover' flag 只在 terminal 中显示覆盖率, 不会生成任何文件.
  cover = {
    desc = 'Coverage print on screen',
    cmd = {
      prefix = '' ,
      flag = ' -cover',
      suffix = ''
    }
  },

  --- NOTE: 使用 '-coverprofile' 生成的 'cover.out' 文件必须在 go workspace 中, 否则无法进行分析.
  --- '-coverprofile /xxx/cover.out' 最好是是绝对路径, 避免和 '-outputdir' 冲突.
  coverprofile = {
    desc = 'Coverage profile (detail)',
    cmd = {
      prefix = ' mkdir -p ' .. coverage_dir .. ' &&' ,
      flag = ' -coverprofile ' .. coverage_dir .. 'cover.out',
      suffix = 'go tool cover -html=' .. coverage_dir .. 'cover.out -o ' .. coverage_dir .. 'cover.html'
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

--- :GoPprof command
M.set_pprof_cmd_keymap = function()
  local go_utils = require("user.ftplugin_deps.go.utils")

  --- 使用 toggleterm:spawn() 在 background 运行 `go tool pprof/trace ...`
  vim.api.nvim_buf_create_user_command(0, 'GoPprof', function()
    local select = {'cpu', 'mem', 'mutex', 'block', 'trace'}
    vim.ui.select(select, {
      prompt = 'choose go test flag:',
      format_item = function(item)
        return M.get_testflag_desc(item)
      end
    }, function (choice)
      if choice then
        go_utils.bg_term_spawn(M.parse_testflag_cmd(choice).suffix)
      end
    end)
  end, {bang=true})

  vim.api.nvim_buf_set_keymap(0, 'n', '<F6>', '<cmd>GoPprof<CR>', {
    noremap = true,
    silent = true,
    desc = 'Go tool pprof/trace',
  })

  --- info Keymap and Command setup
  Notify("terminal <buffer> can now use '<F6>' OR ':GoPprof' to display other profiles.", "INFO")

  --- delete all bg_term after this buffer removed.
  --- NOTE: 这里不能用 BufDelete, 因为 terminal 本来就不在 buflist 中, 所以不会触发 BufDelete.
  vim.api.nvim_create_autocmd("BufWipeout", {
    buffer = 0,
    callback = function(params)
      --- delete all running bg_term
      go_utils.bg_term_shutdown_all()
    end,
    desc = 'delete all bg_term when this buffer is deleted',
  })
end

return M
