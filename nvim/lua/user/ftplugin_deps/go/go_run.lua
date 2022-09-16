--- `$ go help build`, go run & go build 使用相同的 flags.
--- `go run` 相当于: 1. 生成一个临时的 go build file, 2. 然后 run.

local go_utils = require("user.ftplugin_deps.go.utils")

local M = {}

M.go_run = function()
  --- 获取当前文件所在文件夹路径.
  local dir = vim.fn.expand('%:h')

  --- 获取 go import path, `cd src/xxx && go list -f '{{.ImportPath}}'`
  local import_path = go_utils.get_import_path(dir)
  if not import_path then
    return
  end

  --- go run local/src
  local cmd = "cd " .. dir .. " && go run " .. import_path
  print(cmd)
  _Exec(cmd, true)  -- cache cmd for re-run.
end

return M
