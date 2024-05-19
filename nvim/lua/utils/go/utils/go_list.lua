--- go list -json 用于获取 ImportPath, Root, (pkg)Name, Imports, Deps ... 等数据.

local M = {}

M.go_list = function(dir)
  local result = vim.system({'go', 'list', '-json'}, {
    cwd = dir,  -- 可以是 relative path 或者是 absolute path.
    text = true,
  }):wait()
  if result.code ~= 0 then
    error(result.stderr ~= '' and result.stderr or result.code)
  end

  return vim.fn.json_decode(result.stdout)
end

return M
