local go_utils = require("user.ftplugin_deps.go.utils")

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

  opt = opt or {}
  --- 判断 flag 是否存在. Internal
  local flag_cmd = go_utils.parse_testflag_cmd(opt.flag)
  if not flag_cmd then
    return
  end

  --- 获取当前文件所在文件夹路径.
  local dir = vim.fn.expand('%:h')

  --- 获取 go import path, `cd src/xxx && go list -f '{{.ImportPath}}'`
  local import_path = go_utils.get_import_path(dir)
  if not import_path then
    return
  end

  local cmd = 'cd ' .. dir .. ' &&' .. flag_cmd.prefix
  --- NOTE: 不能同时运行多个 fuzz test. Error: will not fuzz, -fuzz matches more than one fuzz test.
  if opt.mode == 'run' then
    --- go test -v -timeout 30s -run "^Test.*" ImportPath
    cmd = cmd .. ' go test -v' .. flag_cmd.flag .. ' -timeout 30s -run "^Test.*" ' .. import_path
  elseif opt.mode == 'bench' then
    --- go test -v -timeout 30s -run ^$ -benchmem -bench "^Benchmark.*" ImportPath
    cmd = cmd .. ' go test -v' .. flag_cmd.flag .. ' -timeout 30s -run ^$ -benchmem -bench "^Benchmark.*" ' .. import_path
  else  -- error
    Notify("go test package {opt.mode} should be: 'run' | 'bench'", "DEBUG")
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

--- go test run/bench multiple packages (Project) --------------------------------------------------
--- opt.mode = 'run' | 'bench'
local function go_test_proj(opt)
  opt = opt or {}
  --- 判断 flag 是否存在. Internal
  local flag_cmd = go_utils.parse_testflag_cmd(opt.flag)
  if not flag_cmd then
    return
  end

  --- './...' 表示当前 pwd 下的所有 packages, 即整个 Project.
  local cmd

  --- NOTE: cannot use -fuzz flag with multiple packages.
  if opt.mode == 'run' then
    cmd = flag_cmd.prefix .. ' go test -v' .. flag_cmd.flag .. ' -timeout 3m ./...'
  elseif opt.mode == 'bench' then
    cmd = flag_cmd.prefix .. ' go test -v' .. flag_cmd.flag .. ' -timeout 5m -run ^$ -benchmem -bench "^Benchmark.*" ./...'
  else  -- error
    Notify("go test multiple packages {opt.mode} should be: 'run' | 'bench'", "DEBUG")
    return
  end

  -- print(cmd)
  _Exec(cmd, false, function()
    --- NOTE: cannot use pprof flag with multiple packages
    if flag_cmd.suffix and flag_cmd.suffix ~= '' then
      go_utils.bg_term_spawn(flag_cmd.suffix)
    end
  end)
end

--- export functions -------------------------------------------------------------------------------
M.go_test_run_pkg = function()
  local select = {'none', 'cpu', 'mem', 'mutex', 'block', 'trace', 'cover', 'coverprofile'}
  vim.ui.select(select, {
    prompt = 'choose go test flag:',
    format_item = function(item)
      return go_utils.get_testflag_desc(item)
    end
  }, function (choice)
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
  }, function (choice)
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
  }, function (choice)
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
  }, function (choice)
    if choice then
      go_test_proj({mode = 'bench', flag = choice })
    end
  end)
end

return M
