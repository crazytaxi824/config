--- go list -json 用于获取 ImportPath, Root, (pkg)Name, Imports, Deps ... 等数据.

local M = {}

M.go_list = function(dir)
  local result = vim.system({'go', 'list', '-json'}, {
    --- cwd 可以是 relative path 或者是 absolute path.
    cwd = dir or vim.fs.dirname(vim.api.nvim_buf_get_name(0)),
    text = true,
  }):wait()
  if result.code ~= 0 then
    error(result.stderr ~= '' and result.stderr or result.code)
  end

  return vim.fn.json_decode(result.stdout)
end

return M
