--- "puremourning/vimspector"
--- https://github.com/puremourning/vimspector#go
--- VVI:
--    adapter 定义在 lua/user/plugin-settings/vimspector.lua -> vim.g.vimspector_adapters
--    config  定义在 lua/user/plugin-settings/vimspector.lua -> vim.g.vimspector_configurations

local function debug()
  if string.match(vim.fn.expand('%'), ".*_test%.go$") then
    --- Debug Test file
    --- NOTE: debug_go_test 定义在 lua/user/plugin-settings/vimspector.lua -> vim.g.vimspector_configurations
    vim.cmd(':call vimspector#LaunchWithSettings({"configuration": "debug_go_test"})')
  else
    --- 判断是否在 main package
    --- 获取文件夹路径.
    local dir = vim.fn.expand('%:h')

    --- 获取 package name, `cd src/xxx && go list -f '{{.Name}}'`
    local pkg_name = string.match(vim.fn.system("cd " .. dir .. " && go list -f '{{.Name}}'"), "[%S ]*")
    if vim.v.shell_error ~= 0 then
      Notify(pkg_name,"ERROR",{title={"debug()","debug_vimspector.lua"}})
      return
    end

    --- 如果不在 main package, 不运行 Debug
    if pkg_name ~= 'main' then
      Notify('file is not in "main" package',"WARN",{title={"debug()","debug_vimspector.lua"}})
      return
    end

    --- Debug Main
    --- NOTE: debug_go 定义在 lua/user/plugin-settings/vimspector.lua -> vim.g.vimspector_configurations
    vim.cmd(':call vimspector#LaunchWithSettings({"configuration": "debug_go"})')
  end
end

--- Debug command
vim.api.nvim_buf_create_user_command(0, 'Debug', debug, {})

--- Debug keymapping -------------------------------------------------------------------------------
_Vimspector_keymaps() -- 针对 go buffer 设置 keymap. 设置在 'lua/user/keymaps.lua'
