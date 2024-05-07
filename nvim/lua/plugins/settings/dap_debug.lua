--- https://github.com/mfussenegger/nvim-dap
--- DOCS: repl / debug console command ------------------------------------------------------------- {{{
---    .exit               Closes the REPL
---    .clear              clear dap-repl buffer 内容
---    .c or .continue     Same as |dap.continue|
---    .n or .next         Same as |dap.step_over|
---    .into               Same as |dap.step_into|
---    .into_target        Same as |dap.step_into{askForTargets=true}|
---    .out                Same as |dap.step_out|
---    .up                 Same as |dap.up|
---    .down               Same as |dap.down|
---    .goto               Same as |dap.goto_|
---    .scopes             Prints the variables in the current scopes
---    .threads            Prints all threads
---    .frames             Print the stack frames
---    .capabilities       Print the capabilities of the debug adapter
---    .b or .back         Same as |dap.step_back|
---    .rc or
---    .reverse-continue   Same as |dap.reverse_continue|
-- -- }}}
--- `:help dap.txt`
local dap_status_ok, dap = pcall(require, "dap")
if not dap_status_ok then
  return
end

--- Defaults to `INFO`, 打印到 'stdpath('cache') .. dap.log'
dap.set_log_level('WARN')

--- NOTE: Debug adapters & configurations settings -------------------------------------------------
--- Some variables are supported ----------------------------------------------- {{{
---   "${port}": nvim-dap resolves a free port.
---   "${file}": Active filename
---   "${fileBasename}": The current file's basename
---   "${fileBasenameNoExtension}": The current file's basename without extension
---   "${fileDirname}": The current file's dirname
---   "${fileExtname}": The current file's extension
---   "${relativeFile}": The current file relative to |getcwd()|
---   "${relativeFileDirname}": The current file's dirname relative to |getcwd()|
---   "${workspaceFolder}": The current working directory of Neovim
---   "${workspaceFolderBasename}": The name of the folder opened in Neovim
-- -- }}}
--- https://github.com/mfussenegger/nvim-dap/wiki/Debug-Adapter-installation#go-using-delve-directly
--- golang debug settings ------------------------------------------------------ {{{
dap.adapters.delve = {
  type = 'server',
  port = '${port}',
  executable = {
    command = 'dlv',
    args = {'dap', '-l', '127.0.0.1:${port}'},
  }
}

dap.configurations.go = {
  {
    type = "delve",  -- VVI: 这里的名字和需要上面 dap.adapters.xxx 的名字一样.
    name = "Debug go",
    request = "launch",
    program = "${file}"
  },
  --- go test package
  {
    type = "delve",  -- VVI: 这里的名字和需要上面 dap.adapters.xxx 的名字一样.
    name = "Debug go test (package/dir)",
    request = "launch",
    mode = "test",
    program = "./${relativeFileDirname}"
  }
}
-- -- }}}

--- highlight && sign setting ---------------------------------------------------------------------- {{{
--- `:help dap.txt`, search:
--- `DapBreakpoint` for breakpoints (default: `B`)
--- `DapBreakpointCondition` for conditional breakpoints (default: `C`)
--- `DapLogPoint` for log points (default: `L`)
--- `DapStopped` to indicate where the debugee is stopped (default: `→`)
--- `DapBreakpointRejected` to indicate breakpoints rejected by the debug adapter (default: `R`)
vim.api.nvim_set_hl(0, 'DapBreakpointHL', { ctermfg=Color.yellow, fg=Color_gui.yellow })
vim.api.nvim_set_hl(0, 'DapBreakpointRejectedHL', { ctermfg=Color.yellow, fg=Color_gui.yellow })
vim.api.nvim_set_hl(0, 'DapStoppedHL', { ctermfg=Color.blue, fg=Color_gui.blue })
vim.api.nvim_set_hl(0, 'DapStoppedLineHL', { ctermbg=24, bg='#264f78' })

vim.fn.sign_define("DapBreakpoint", { text = "●", texthl = "DapBreakpointHL", numhl = "", linehl="" })
vim.fn.sign_define("DapBreakpointRejected", { text = "○", texthl = "DapBreakpointRejectedHL", numhl = "", linehl="" })
vim.fn.sign_define("DapStopped", { text = "", texthl = "DapStoppedHL", numhl = "", linehl="DapStoppedLineHL" })
-- -- }}}

--- functions -------------------------------------------------------------------------------------- {{{
--- NOTE: 通过 set/get tab var 来确定 debug_tab 是否存在.
local tabvar_debug = "my_debug_dap"

--- open a new tab for debug
local function open_new_tab_for_debug()
  --- if debug tab exists, jump to debug tab.
  for _, tab_id in pairs(vim.api.nvim_list_tabpages()) do
    if vim.t[tab_id][tabvar_debug] then
      vim.cmd('normal! '.. vim.api.nvim_tabpage_get_number(tab_id) .. 'gt')  -- 1gt | 2gt jump to tab, NOTE: tabnr NOT tab_id
      return
    end
  end

  --- if debug tab NOT exist, open a new tab for debug.
  vim.cmd('tabnew '..vim.fn.bufname())

  --- 标记该 tab.
  local curr_tab_id = vim.api.nvim_get_current_tabpage()
  vim.t[curr_tab_id][tabvar_debug] = true

  --- 返回 win id
  return vim.api.nvim_get_current_win()
end

--- terminate debug && close debug tab/buffers
local function close_debug_tab_and_buffers()
  --- dap.terminate({terminate_opt}, {disconnect_opts}, Callback), terminates the debug adapter and disconnect debug session.
  --- terminate opt:  https://microsoft.github.io/debug-adapter-protocol/specification#Requests_Terminate
  --- disconnect opt: https://microsoft.github.io/debug-adapter-protocol/specification#Requests_Disconnect
  --- Callback function 在 session 结束后执行, 如果 session 不存在则立即执行.
  dap.terminate({},{terminateDebugee = true}, function()
    local dapui_status_ok, dapui = pcall(require, "dapui")
    if dapui_status_ok then
      --- NOTE: 如果在 dap.repl.close() 之后再执行 dapui.close() 会重新打开 [dap-repl] buffer.
      dapui.close()  -- close all dap-ui windows
    end

    --- NOTE: 不太需要 wipeout repl buffer.
    --dap.repl.close()  -- close dap-repl console window && wipeout [dap-repl] buffer.

    --- 如果自己是 last tab 则不执行 tabclose, 但是删除 tabvar.
    local tab_list = vim.api.nvim_list_tabpages()
    if #tab_list < 2 then
      --- 删除 tabvar
      local curr_tab_id = vim.api.nvim_get_current_tabpage()
      vim.t[curr_tab_id][tabvar_debug] = nil
      return
    end

    --- close debug tab
    for _, tab_id in pairs(tab_list) do
      if vim.t[tab_id][tabvar_debug] then
        vim.cmd('tabclose ' .. vim.api.nvim_tabpage_get_number(tab_id)) -- NOTE: `:tabclose tabnr` NOT tab_id
      end
    end
  end)
end
-- -- }}}

--- 开启 new tab 进行 debug ------------------------------------------------------------------------
--- https://github.com/rcarriga/nvim-dap-ui#usage & `:help dap-extensions`
--- 启动 debug 之前先打开 new tab
dap.listeners.before.event_initialized["foo"] = function()
  open_new_tab_for_debug()
end

--- 启动 debug 之后, 打开 dap-ui windows
dap.listeners.after.event_initialized["foo"] = function()
  local dapui_status_ok, dapui = pcall(require, "dapui")
  if dapui_status_ok then
    dapui.open()  -- will open dap-ui layouts in new tab.
  end
end

--- other hook events ---------------------------------------------------------- {{{
--- debug job done 之前 close debug tab, dap-repl, dap-ui windows
--- NOTE: 不要自动关闭, 使用自定义函数手动关闭.
-- dap.listeners.before.event_terminated["foo"] = function()
--   print('event terminated')
--   vim.cmd('stopinsert')
--   close_debug_tab_and_buffers()
-- end

--- NOTE: Not working right now.
-- dap.listeners.before.event_exited["foo"] = function()
--   print('event exited')
--   vim.cmd('stopinsert')
--   close_debug_tab_and_buffers()
-- end
-- -- }}}

--- keymaps ----------------------------------------------------------------------------------------
--- dap 可用方法, `:help dap-api` ---------------------------------------------- {{{
---   dap.run({config})
---   dap.run_last()  -- NOTE: run_last() 时, 当前 ('%') buffer 必须是之前运行 debug 时的 buffer.
---   dap.launch({adapter}, {config})
---   dap.terminate(terminate_opts, disconnect_opts, callback)
---
---   dap.set_breakpoint({condition}, {hit_condition}, {log_message})
---   dap.toggle_breakpoint({condition}, {hit_condition}, {log_message})
---   dap.clear_breakpoints()
---
---   dap.step_over([{opts}])
---   dap.step_into([{opts}])
---   dap.step_out([{opts}])
---   dap.pause({thread_id})
---   dap.run_to_cursor()
---
---   dap.session()
---   dap.status()
-- -- }}}
--- TODO: 在进入 debug 模式时设置 keymaps, 退出 debug 模式时删除 keymaps.
local opt = { noremap = true, silent = true }
local debug_keymaps = {
  {'n', '<leader>cs', function() dap.continue() end,  opt, 'debug: Start(Continue)'},
  {'n', '<leader>ce', function() dap.terminate() end, opt, 'debug: Stop(End)'},
  {'n', '<leader>cr', function() dap.run_last() end,  opt, 'debug: Restart'},
  {'n', '<leader>cq', function() close_debug_tab_and_buffers() end, opt, 'debug: Quit'},

  --{'n', '<F9>', function() dap.toggle_breakpoint() end, opt, "debug: Toggle Breakpoint"},  -- 在 after/ftplugin/go/debug_cmd.lua 中设置.
  {'n', '<F21>', function() dap.clear_breakpoints() end, opt, "debug: Clear Breakpoints"},  -- <S-f9>
  {'n', '<F10>', function() dap.step_over() end, opt, "debug: Step Over"},
  {'n', '<F11>', function() dap.step_into() end, opt, "debug: Step Into"},
  {'n', '<F23>', function() dap.step_out() end,  opt, "debug: Step Out"},  -- <S-F11>
}

require('utils.keymaps').set(debug_keymaps)

--- keymaps: jump_to_file in dap-repl window -------------------------------------------------------
local fp = require('utils.filepath')
vim.api.nvim_create_autocmd("FileType", {
  pattern = {"dap-repl"},
  callback = function(params)
    fp.setup(params.buf)
  end,
  desc = "dap: keymap for jump_to_file",
})



