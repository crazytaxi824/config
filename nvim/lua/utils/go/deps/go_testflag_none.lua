--- `go test -v -run/-bench "..." local/src/color`

local utils = require("utils.go.deps.utils")


--- go test cmd
local go_test = {'go', 'test', '-count=1', '-v'}


--- @type GoTestFlagDict
local M = {
  list = { 'none' },

  flags = {
    none = {
      desc = '[No Extra Flag]',

      term_opts = function(opts)
        return {
          cwd = opts.go_list.Root,
          cmd = vim.iter({go_test, utils.mode_flags(opts)}):flatten():totable(),
        }
      end,
    }
  }
}

return M

