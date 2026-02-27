--- `go test -v -run/-bench "..." local/src/color`

local utils = require("utils.go.deps.utils")


--- go test cmd
local go_test = {'go', 'test', '-count=1', '-v'}


--- @type GoTestFlag
local M = {
  flags = function ()
    return { 'none' }
  end,

  contains = function(flag)
    return flag == 'none'
  end,

  get_description = function(flag)
    return '[No Extra Flag]'
  end,

  term_opts = function(opts)
    return {
      cwd = opts.go_list.Root,
      cmd = vim.iter({go_test, utils.mode_flags(opts)}):flatten():totable(),
    }
  end,
}

return M

