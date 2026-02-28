--- `go test -v -fuzztime 15s -run ^$ -fuzz "^FuzzFoo$" local/src/color`
---
--- NOTE: fuzz 只能用于 single_fn, 一次 fuzz 多个函数会报错: FAIL: testing: will not fuzz, -fuzz matches more than one fuzz test

local utils = require("utils.go.deps.utils")


--- go test cmd
local go_test = {'go', 'test', '-count=1', '-v'}


--- @type GoTestFlag
local M = {
  flag_desc = {
    fuzz30s = { desc = 'fuzztime 30s', fuzztime = '30s' },
    fuzz60s = { desc = 'fuzztime 60s', fuzztime = '60s' },
    fuzz5m  = { desc = 'fuzztime 5m',  fuzztime = '5m'  },
    fuzz10m = { desc = 'fuzztime 10m', fuzztime = '10m' },
    fuzz1000x = { desc = 'fuzztime 1000x (times)', fuzztime = '1000x' },
    fuzz_input = { desc = 'Input fuzztime: 15s|20m|1h20m30s (duration) | 1000x (times)' }
  },

  term_opts = function(self, opts)
    if opts.flag == 'fuzz_input' then
      local fuzz_time = '30s'  -- default value
      vim.ui.input({prompt = 'Input -fuzztime: '}, function(input)
        if input then
          fuzz_time = input
        end
      end)

      return {
        cwd = opts.go_list.Root,
        cmd = vim.iter({go_test, '-fuzztime', fuzz_time, utils.mode_flags(opts)}):flatten():totable(),
      }
    else
      local f = self.flag_desc[opts.flag]
      if not f then
        error("flag is not defined")
      end

      return {
        cwd = opts.go_list.Root,
        cmd = vim.iter({go_test, '-fuzztime', f.fuzztime, utils.mode_flags(opts)}):flatten():totable(),
      }
    end
  end
}

return M
