local M = {}

--- VVI: 获取 go import path, `cd src/xxx && go list -f '{{.ImportPath}}'` -------------------------
M.get_import_path = function(dir)
  local result = vim.fn.system("cd " .. dir .. " && go list -f '{{.ImportPath}}'")
  if vim.v.shell_error ~= 0 then
    Notify(result,"ERROR")
    return
  end

  return string.match(result, "[%S ]*")  -- return import_path WITHOUT '\n'
end

--- VVI: 获取 go project root, `cd src/xxx && go list -f '{{.Root}}'` ------------------------------
M.get_project_root = function(dir)
  local result = vim.fn.system("cd " .. dir .. " && go list -f '{{.Root}}'")
  if vim.v.shell_error ~= 0 then
    Notify(result,"ERROR")
    return
  end

  return string.match(result, "[%S ]*")  -- return import_path WITHOUT '\n'
end

return M
