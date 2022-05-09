--- "puremourning/vimspector"
--- https://github.com/puremourning/vimspector#go
--- VVI:
--    adapter 定义在 vim.g.vimspector_adapters
--    config  定义在 vim.g.vimspector_configurations

local function debug()
  if string.match(vim.fn.expand('%'), ".*_test%.go$") then
    vim.cmd(':call vimspector#LaunchWithSettings({"configuration": "debug_go_test"})')
  else
    -- 判断是否在 main package
    -- 获取文件夹路径.
    local dir = vim.fn.expand('%:h')

    -- VVI: 获取 package name, `cd src/xxx && go list -f '{{.Name}}'`
    local pkg_name = string.match(vim.fn.system("cd " .. dir .. " && go list -f '{{.Name}}'"), "[%S ]*")
    if vim.v.shell_error ~= 0 then
      vim.api.nvim_echo({{pkg_name, "ErrorMsg"}}, false, {})
      return
    end

    if pkg_name ~= 'main' then
      vim.api.nvim_echo({{' file is not in "main" package ', "WarningMsg"}}, false, {})
      return
    end

    vim.cmd(':call vimspector#LaunchWithSettings({"configuration": "debug_go"})')
  end
end

vim.api.nvim_buf_create_user_command(0, 'Debug', debug, {})



