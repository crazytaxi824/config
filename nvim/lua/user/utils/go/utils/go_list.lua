--- go list -json 用于获取 ImportPath, Root, (pkg)Name, Imports, Deps ... 等数据.

local M = {}

M.go_list = function(dir)
  local result = vim.fn.system("cd " .. dir .. " && go list -json")
  if vim.v.shell_error ~= 0 then
    Notify(vim.trim(result),"ERROR")
    return
  end

  return vim.fn.json_decode(result)
end

return M
