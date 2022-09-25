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

  --- Q: 这里为什么要 `cd src/xxx` 之后再 `go run | go list`?
  --- A: 因为 cd 之后再去执行 go list / go run 可以忽略当前 pwd, 在任何 pwd 下执行其他路径中的代码.
  --- 例如: 可以在 projectA 路径下, ':e projectB/src/main.go', 然后使用 go_run() 运行 projectB 的代码.
  local cmd = "cd " .. dir .. " && go run " .. import_path  -- go run local/src
  _Exec(cmd, true)  -- cache cmd for re-run.
end

return M
