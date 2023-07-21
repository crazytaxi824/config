--- `go test run/bench` whole package or whole project
--- `go test run/bench ImportPath`, test 单独的 package.
--- 在 project root 下执行 'go test ./...', 即 test 整个 Project.

local go_utils = require("user.utils.go.utils")

local M = {}

--- go test run current Package --------------------------------------------------------------------
--- opt.mode: 'run' | 'bench'
--- NOTE: 不能同时运行多个 fuzz test. Error: will not fuzz, -fuzz matches more than one fuzz test.
local function go_test_pkg(opt)
  --- 判断当前文件是否是 _test.go
  if not string.match(vim.fn.expand('%:t'), "_test%.go$") then
    Notify('not "_test.go" file',"ERROR")
    return
  end

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
  --- NOTE: 不能同时运行多个 fuzz test. Error: will not fuzz, -fuzz matches more than one fuzz test.
  if opt.mode == 'run' then
    --- go test -v -timeout 30m -run "^Test.*" ImportPath
    cmd = cmd .. ' go test -v' .. flag_cmd.flag
      .. ' -timeout 30m -run "^Test.*" ' .. go_list.ImportPath
  elseif opt.mode == 'bench' then
    --- go test -v -timeout 30m -run ^$ -benchmem -bench "^Benchmark.*" ImportPath
    cmd = cmd .. ' go test -v' .. flag_cmd.flag
      .. ' -timeout 30m -run ^$ -benchmem -bench "^Benchmark.*" ' .. go_list.ImportPath
  else  -- error
    Notify("go test package {opt.mode} should be: 'run' | 'bench'", "DEBUG")
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

  --- toggleterm on_exit callback function
  local on_exit = function(term, job)
    --- :GoPprof command
    if vim.tbl_contains({'cpu', 'mem', 'mutex', 'block', 'trace'}, opt.flag) then
      go_utils.go_pprof.set_cmd_and_keymaps(job)
    end

    if flag_cmd.suffix and flag_cmd.suffix ~= '' then
      go_utils.go_pprof.autocmd_shutdown_all_jobs(job, term.bufnr)  -- autocmd BufWipeout jobstop()
      go_utils.go_pprof.job_exec(flag_cmd.suffix, job)  -- run `go tool pprof ...` in background jobstart()
    end
  end

  --- toggleterm 执行 command
  require("user.utils.term").bottom.run(cmd, on_exit)
end

--- go test run/bench multiple packages (Project) --------------------------------------------------
--- opt.mode = 'run' | 'bench'
local function go_test_proj(opt)
  --- 获取当前文件所在文件夹路径.
  local dir = vim.fn.expand('%:h')

  --- 获取 go list info, `cd src/xxx && go list -json`
  local go_list = go_utils.go_list(dir)
  if not go_list then
    return
  end

  --- VVI: 标记为 test 整个 project, 传递的 string 是 -coverprofile 的文件名.
  go_list.project = 'project'

  --- 获取 flag_cmd {prefix, flag, suffix}
  local flag_cmd = go_utils.parse_testflag_cmd(opt.flag, go_list)
  if not flag_cmd then
    return
  end

  --- NOTE: cannot use -fuzz flag with multiple packages.
  --- 以下意思是 pwd 在 project root 下执行 'go test ./...', 即整个 Project.
  --- './...' 表示当前 pwd 下的所有 packages
  local cmd = 'cd ' .. go_list.Root .. ' &&'
  if opt.mode == 'run' then
    cmd = cmd .. ' go test -v' .. flag_cmd.flag
      .. ' -timeout 60m ./...'
  elseif opt.mode == 'bench' then
    cmd = cmd .. ' go test -v' .. flag_cmd.flag
      .. ' -timeout 60m -run ^$ -benchmem -bench "^Benchmark.*" ./...'
  else  -- error
    Notify("go test multiple packages {opt.mode} should be: 'run' | 'bench'", "DEBUG")
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

  --- toggleterm on_exit callback function
  local on_exit = function(term, job)
    if flag_cmd.suffix and flag_cmd.suffix ~= '' then
      go_utils.go_pprof.autocmd_shutdown_all_jobs(job, term.bufnr)  -- autocmd BufWipeout jobstop()
      go_utils.go_pprof.job_exec(flag_cmd.suffix, job)  -- run `go tool pprof ...` in background jobstart()
    end
  end

  --- toggleterm 执行 command
  require("user.utils.term").bottom.run(cmd, on_exit)
end

--- export functions -------------------------------------------------------------------------------
M.go_test_run_pkg = function()
  local select = {'none', 'cpu', 'mem', 'mutex', 'block', 'trace', 'cover', 'coverprofile'}
  vim.ui.select(select, {
    prompt = 'choose go test flag:',
    format_item = function(item)
      return go_utils.get_testflag_desc(item)
    end
  }, function(choice)
    if choice then
      go_test_pkg({mode = 'run', flag = choice })
    end
  end)
end

M.go_test_bench_pkg = function()
  local select = {'none', 'cpu', 'mem', 'mutex', 'block', 'trace', 'cover', 'coverprofile'}
  vim.ui.select(select, {
    prompt = 'choose go test flag:',
    format_item = function(item)
      return go_utils.get_testflag_desc(item)
    end
  }, function(choice)
    if choice then
      go_test_pkg({mode = 'bench', flag = choice })
    end
  end)
end

M.go_test_run_proj = function()
  --- cannot use pprof flag with multiple packages
  local select = {'none', 'cover', 'coverprofile'}
  vim.ui.select(select, {
    prompt = 'choose go test flag: [go test multiple packages cannot use pprof flags]',
    format_item = function(item)
      return go_utils.get_testflag_desc(item)
    end
  }, function(choice)
    if choice then
      go_test_proj({mode = 'run', flag = choice })
    end
  end)
end

M.go_test_bench_proj = function()
  --- cannot use pprof flag with multiple packages
  local select = {'none', 'cover', 'coverprofile'}
  vim.ui.select(select, {
    prompt = 'choose go test flag: [go test multiple packages cannot use pprof flags]',
    format_item = function(item)
      return go_utils.get_testflag_desc(item)
    end
  }, function(choice)
    if choice then
      go_test_proj({mode = 'bench', flag = choice })
    end
  end)
end

return M
