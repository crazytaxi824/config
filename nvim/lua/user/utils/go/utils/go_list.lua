local M = {}

M.go_list = function(dir)
  local result = vim.fn.system("cd " .. dir .. " && go list -json")
  if vim.v.shell_error ~= 0 then
    Notify(result,"ERROR")
    return
  end

  return vim.fn.json_decode(result)
end

return M
