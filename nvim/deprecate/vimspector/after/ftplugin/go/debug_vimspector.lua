--- "puremourning/vimspector"
--- https://github.com/puremourning/vimspector#go
--- VVI:
--    adapter 定义在 lua/user/plugin_settings/vimspector.lua -> vim.g.vimspector_adapters
--    config  定义在 lua/user/plugin_settings/vimspector.lua -> vim.g.vimspector_configurations

--- Debug command ----------------------------------------------------------------------------------
local function debug_go()
  if string.match(vim.fn.expand('%'), ".*_test%.go$") then
    --- Debug Test file
    --- NOTE: debug_go_test 定义在 lua/user/plugin_settings/vimspector.lua -> vim.g.vimspector_configurations
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
    --- NOTE: debug_go 定义在 lua/user/plugin_settings/vimspector.lua -> vim.g.vimspector_configurations
    vim.cmd(':call vimspector#LaunchWithSettings({"configuration": "debug_go"})')
  end
end

--- Debug command
vim.api.nvim_buf_create_user_command(0, 'Debug', debug_go, {})

--- Debug keymapping -------------------------------------------------------------------------------
--- NOTE: Vimspector keymap 设置不是全局的. 而且 Vimspector 自己本身是 optional 加载.
local opt = { noremap = true, silent = true, buffer = true }  -- NOTE: local to buffer
local vimspector_keymaps = {
  {'n', '<leader>cs', '<cmd>call vimspector#Continue()<CR>', opt, 'Debug - Start(Continue)'},
  {'n', '<leader>ce', '<cmd>call vimspector#Stop()<CR>', opt, 'Debug - Stop(End)'},
  {'n', '<leader>cr', '<cmd>call vimspector#Restart()<CR>', opt, 'Debug - Restart'},
  {'n', '<leader>cq', '<cmd>call vimspector#Reset()<CR>', opt, 'Debug - Quit'},
  {'n', '<leader>cc', '<Plug>VimspectorBalloonEval', opt, 'Debug - Popup Value under cursor'},
  {'n', '<F9>',  '<cmd>call vimspector#ToggleBreakpoint()<CR>', opt, 'Debug - Toggle Breakpoint'},
  {'n', '<F10>', '<cmd>call vimspector#StepOver()<CR>', opt, 'Debug - Step Over'},
  {'n', '<F11>', '<cmd>call vimspector#StepInto()<CR>', opt, 'Debug - Step Into'},
  {'n', '<F23>', '<cmd>call vimspector#StepOut()<CR>', opt, 'Debug - Step Out'},  -- <S-F11>
}

Keymap_set_and_register(vimspector_keymaps, {
  key_desc = {
    c = {
      name = "Code",  -- NOTE: 这里设置必须和 lua/user/lsp/util/lsp_keymaps 一致.
      ['<F9>'] = "Debug - Toggle Breakpoint",
      ['<F10>'] = "Debug - Step Over",
      ['<F11>'] = "Debug - Step Into",
      ['<S-F11>'] = "Debug - Step Out",
    }
  },
  opts = {mode='n', prefix='<leader>', buffer=0}  -- NOTE: 针对 buffer 有效.
})



