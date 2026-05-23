--- `go test run/bench` single test function.
--- `go test run/bench=^TEST_Func_Name$ ImportPath`, test 单独的 package.

local go_none = require("utils.go.deps.go_testflag_none")
local go_fuzz = require("utils.go.deps.go_testflag_fuzz")
local go_pprof = require("utils.go.deps.go_testflag_pprof")
local go_cover = require("utils.go.deps.go_testflag_cover")

local go_list_module = require("utils.go.deps.go_list")
local test_cmds = require("utils.go.deps.test_cmds")
local utils = require("utils.go.deps.utils")


local M = {}

--- `go test run/bench=^TEST_Func_Name$ ImportPath`
---
---@param profile? 'profile' `go test pprof`
function M.go_test_single_func(profile)
  --- 判断当前文件是否 _test.go
  if not string.match(vim.fn.bufname(), "_test%.go$") then
    Notify('not "_test.go" file', "ERROR")
    return
  end

  --- 判断当前函数是否 TestXXX. 如果是, 则获取 test function name.
  local testfn_name, mode = utils.get_exact_testfn_name()
  if not testfn_name or not mode then
    return
  end

  ---@type GoTestOpts
  local opts = {
    testfn_name = '^'..testfn_name..'$',
    mode = mode,
    flag = 'none',
    go_list = go_list_module.go_list(),
  }

  --- no profile: choose [none]
  if not profile then
    local cmd, myterm_opts = go_none.flags['none'].term_opts(opts)
    test_cmds.go_test(cmd, myterm_opts)
    return
  end

  --- profile: choose [pprof]
  if mode == 'run' or mode == 'bench' then
    --- 排序
    local select = vim.iter({go_pprof.list, go_cover.list}):flatten():totable()

    ---@type table<string, GoTestFlag>
    local test_flags = vim.tbl_deep_extend('force', go_pprof.flags, go_cover.flags)

    vim.ui.select(select, {
      prompt = 'choose go test flag:',
      format_item = function(item)
        return test_flags[item].desc
      end
    }, function(choice)
      if choice then
        --- change GoTestOpts.flag
        opts.flag = choice

        --- 运行 `go test`
        local cmd, myterm_opts = test_flags[choice].term_opts(opts)
        test_cmds.go_test(cmd, myterm_opts)
      end
    end)
    return
  end

  if mode == 'fuzz' then
    local select = go_fuzz.list

    ---@type table<string, GoTestFlag>
    local test_flags = go_fuzz.flags

    vim.ui.select(select, {
      prompt = 'choose go test flag: [Fuzz test cannot use pprof & coverage flags]',
      format_item = function(item)
        return test_flags[item].desc
      end
    }, function(choice)
      if choice then
        --- change GoTestOpts.flag
        opts.flag = choice

        --- 运行 `go test`
        local cmd, myterm_opts = test_flags[choice].term_opts(opts)
        test_cmds.go_test(cmd, myterm_opts)
      end
    end)
    return
  end

  --- mode error
  Notify("go test single function {mode} should be: 'run' | 'bench' | 'fuzz'", "WARN")
end

return M
