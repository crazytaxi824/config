--- `go test -v -fuzztime 15s -run ^$ -fuzz "^FuzzFoo$" local/src/color`
---
--- NOTE: fuzz 只能用于 single_fn, 一次 fuzz 多个函数会报错: FAIL: testing: will not fuzz, -fuzz matches more than one fuzz test

local utils = require("utils.go.deps.utils")


--- go test cmd
local go_test = {'go', 'test', '-count=1', '-v'}

--- @param fuzztime string
--- @return fun(opts: GoTestOpts): string[], MyTermOpts
local function gen_term_opts(fuzztime)
  return function(opts)
    --- @type string[]
    local cmd = vim.iter({go_test, '-fuzztime', fuzztime, utils.mode_flags(opts)}):flatten():totable()
    return cmd, {
      cwd = opts.go_list.Root,
    }
  end
end


--- @type GoTestFlagDict
local M = {
  list = { 'fuzz30s', 'fuzz60s', 'fuzz5m', 'fuzz10m', 'fuzz1000x', 'fuzz_input' },

  flags = {
    fuzz30s = { desc = 'fuzztime 30s', term_opts = gen_term_opts('30s') },
    fuzz60s = { desc = 'fuzztime 60s', term_opts = gen_term_opts('60s') },
    fuzz5m  = { desc = 'fuzztime 5m',  term_opts = gen_term_opts('5m') },
    fuzz10m = { desc = 'fuzztime 10m', term_opts = gen_term_opts('10m') },
    fuzz1000x = { desc = 'fuzztime 1000x (times)', term_opts = gen_term_opts('1000x') },

    fuzz_input = {
      desc = 'Input fuzztime: 1h20m30s (duration) | 1000x (times)',

      term_opts = function(opts)
        local fuzz_time  -- default value
        vim.ui.input({prompt = 'Input -fuzztime (1h20m30s|1000x): '}, function(input)
          if input then
            fuzz_time = input
          end
        end)

        --- input 如果取消, 则不继续运行 go_test(cmd, term_opts)
        if not fuzz_time then
          return nil, {}
        end

        --- @type string[]
        local cmd = vim.iter({go_test, '-fuzztime', fuzz_time, utils.mode_flags(opts)}):flatten():totable()
        return cmd, {
          cwd = opts.go_list.Root,
        }
      end
    }
  }
}

return M
