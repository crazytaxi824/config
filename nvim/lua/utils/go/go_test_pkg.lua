--- `go test run/bench` whole package or whole project
--- `go test run/bench ImportPath`, test 单独的 package.
--- 在 project root 下执行 'go test ./...', 即 test 整个 Project.

local go_utils = require("utils.go.utils")

local M = {}

--- go test run current Package --------------------------------------------------------------------
--- NOTE: 不能同时运行多个 fuzz test. Error: will not fuzz, -fuzz matches more than one fuzz test.
local function go_test_pkg(opts)
  go_utils.parse_testflag_cmd(opts)
end

--- go test run/bench multiple packages (Project) --------------------------------------------------
local function go_test_proj(opts)
  go_utils.parse_testflag_cmd(opts)
end

--- export functions -------------------------------------------------------------------------------
--- mode = 'run'|'bench'
M.go_test_pkg = function(mode)
  --- 判断当前文件是否 _test.go
  if not string.match(vim.fn.bufname(), "_test%.go$") then
    Notify('not "_test.go" file', "ERROR")
    return
  end

  --- 获取 go list info, `cd src/xxx && go list -json`
  local dir = vim.fn.expand('%:h')
  local go_list = go_utils.go_list(dir)
  if not go_list then
    return
  end

  local opts
  if mode == 'run' then
    opts = {
      testfn_name = '^Test.*',
      mode = 'run',
      go_list = go_list,
    }
  elseif mode == 'bench' then
    opts = {
      testfn_name = '^Bench.*',
      mode = 'bench',
      go_list = go_list,
    }
  else
    error('go test mode error: "run" | "bench" only.')
  end

  local select = {'none', 'cpu', 'mem', 'mutex', 'block', 'trace', 'cover', 'coverprofile'}
  vim.ui.select(select, {
    prompt = 'choose go test flag:',
    format_item = function(item)
      return go_utils.get_testflag_desc(item)
    end
  }, function(choice)
    if choice then
      opts.flag = choice
      go_test_pkg(opts)
    end
  end)
end

--- mode = 'run'|'bench'
M.go_test_proj = function(mode)
  --- 获取 go list info, `cd src/xxx && go list -json`
  local dir = vim.fn.expand('%:h')
  local go_list = go_utils.go_list(dir)
  if not go_list then
    return
  end

  local opts
  if mode == 'run' then
    opts = {
      testfn_name = '^Test.*',
      mode = 'run',
      go_list = go_list,
      project = 'project', --- VVI: 标记为 test 整个 project, 传递的 string 是 -coverprofile 的文件名.
    }
  elseif mode == 'bench' then
    opts = {
      testfn_name = '^Bench.*',
      mode = 'bench',
      go_list = go_list,
      project = 'project', --- VVI: 标记为 test 整个 project, 传递的 string 是 -coverprofile 的文件名.
    }
  else
    error('go test mode error: "run" | "bench" only.')
  end

  --- cannot use pprof flag with multiple packages
  local select = {'none', 'cover', 'coverprofile'}
  vim.ui.select(select, {
    prompt = 'choose go test flag: [go test multiple packages cannot use pprof flags]',
    format_item = function(item)
      return go_utils.get_testflag_desc(item)
    end
  }, function(choice)
    if choice then
      opts.flag = choice
      go_test_proj(opts)
    end
  end)
end

return M
