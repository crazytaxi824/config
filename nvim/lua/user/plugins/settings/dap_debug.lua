--- https://github.com/mfussenegger/nvim-dap
--- README: repl / debug console command --------------------------------------- {{{
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

local dapui_status_ok, dapui = pcall(require, "dapui")
if not dapui_status_ok then
  return
end

--- nvim-dap settings ------------------------------------------------------------------------------
--- Defaults to `INFO`, 打印到 'stdpath('cache') .. dap.log'
dap.set_log_level('WARN')

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
--- golang debug settings --------------------------------------------------------------------------
--- https://github.com/mfussenegger/nvim-dap/wiki/Debug-Adapter-installation#go-using-delve-directly
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
  -- go test package
  {
    type = "delve",  -- VVI: 这里的名字和需要上面 dap.adapters.xxx 的名字一样.
    name = "Debug go test (package/dir)",
    request = "launch",
    mode = "test",
    program = "./${relativeFileDirname}"
  }
}

--- NOTE: put Other Debug adapters & configurations settings here ---

--- highlight && sign setting ---------------------------------------------------------------------- {{{
--- `DapBreakpoint` for breakpoints (default: `B`)
--- `DapBreakpointCondition` for conditional breakpoints (default: `C`)
--- `DapLogPoint` for log points (default: `L`)
--- `DapStopped` to indicate where the debugee is stopped (default: `→`)
--- `DapBreakpointRejected` to indicate breakpoints rejected by the debug adapter (default: `R`)
--- vim.cmd([[
---   hi DapBreakpointHL ctermfg=191
---   hi DapBreakpointRejectedHL ctermfg=191
---   hi DapStoppedHL ctermfg=75
---   hi DapStoppedLineHL ctermbg=238
-- ]])
vim.api.nvim_set_hl(0, 'DapBreakpointHL', { ctermfg = Color.yellow })
vim.api.nvim_set_hl(0, 'DapBreakpointRejectedHL', { ctermfg = Color.yellow })
vim.api.nvim_set_hl(0, 'DapStoppedHL', { ctermfg = Color.blue })
vim.api.nvim_set_hl(0, 'DapStoppedLineHL', { ctermbg = 24 })

vim.fn.sign_define("DapBreakpoint", { text = "●", texthl = "DapBreakpointHL", numhl = "", linehl="" })
vim.fn.sign_define("DapBreakpointRejected", { text = "◌", texthl = "DapBreakpointRejectedHL", numhl = "", linehl="" })
vim.fn.sign_define("DapStopped", { text = "→", texthl = "DapStoppedHL", numhl = "", linehl="DapStoppedLineHL" })

--vim.api.nvim_set_hl(0, 'DapUINormal', { ctermfg = 191 })  -- dapui 中的文字颜色.
-- -- }}}

--- nvim-dap-ui settings --------------------------------------------------------------------------- {{{
--- `:help dapui.setup()`
local config = {
  mappings = {
    expand = {"<CR>", "<2-LeftMouse>"}, -- Use a table to apply multiple mappings
    edit = "e",
    remove = "d",
    repl = "r",
    open = "o",
    toggle = "T",  -- 't' keymap 冲突.
  },

  layouts = {
    {
      elements = {
        --- NOTE: 顺序有影响.
        --{ id = "scopes", size = 0.25 },  -- Elements can be strings or table with id and size keys.
        "scopes",
        "watches",
        "breakpoints",
        "stacks",
      },
      position = "left",
      size = 0.32, -- columns (width)
    },
    {
      elements = {
        "repl",  -- REPL / Debug console
        --"console",  -- dapui console, 在 go 中没用.
      },
      position = "bottom",
      size = 0.25, -- 25% of total lines (height)
    },
  },

  --- winbar
  controls = {
    enabled = true,
    -- Display controls in this element
    element = "repl",
    icons = {
      pause = "[Pause]",
      play = "[▶️ Play]",
      step_into = "[⊻ Into <F11>]",  -- ⇩↧⊻
      step_over = "[⨠ Over <F10>]",  -- ↷⨠
      step_out = "[⊼ Out <S-F11>]",   -- ⇧↥⊼
      step_back = "[↩︎ Back]",  -- ↶↩︎
      run_last = "[⟳  Restart]",   -- ↻⟳
      disconnect = "[✕ disconnect]",  -- ✕✖︎✗✘⛌
      terminate = "[■ Stop]",
    },
  },

  floating = {
    max_height = nil, -- These can be integers or a float between 0 and 1.
    max_width = nil, -- Floats will be treated as percentage of your screen.
    border = "single", -- "single", "double", "rounded" NOTE: 这里的 boarder 颜色是 Normal, 而不是 FloatBorder
    mappings = {
      close = { "q", "<Esc>" },
    },
  },
}
dapui.setup(config)
-- -- }}}

--- dap && dap-ui debug functions ------------------------------------------------------------------ {{{
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
end

--- terminate debug && close debug tab/buffers
local function close_debug_tab_and_buffers()
  --- dap.terminate({terminate_opt}, {disconnect_opts}, Callback), terminates the debug adapter and disconnect debug session.
  --- terminate opt:  https://microsoft.github.io/debug-adapter-protocol/specification#Requests_Terminate
  --- disconnect opt: https://microsoft.github.io/debug-adapter-protocol/specification#Requests_Disconnect
  --- Callback function 在 session 结束后执行, 如果 session 不存在则立即执行.
  dap.terminate({},{terminateDebugee = true}, function()
    --- NOTE: 如果在 dap.repl.close() 之后再执行 dapui.close() 会重新打开 [dap-repl] buffer.
    dapui.close()  -- close all dap-ui windows

    --- NOTE: dapui controls enable 之后无法删除 [dap-repl] buffer.
    --- bwipeout [dap-repl] buffer 之后又会被重新加载. 所以在该状态下不需要执行 dap.repl.close()
    if not config.controls.enabled then
      dap.repl.close()  -- close dap-repl console window && wipeout [dap-repl] buffer.
    end

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
dap.listeners.before.event_initialized["dapui_config"] = function()
  open_new_tab_for_debug()
end

--- 启动 debug 之后, 打开 dap-ui windows
dap.listeners.after.event_initialized["dapui_config"] = function()
  dapui.open()  -- will open dap-ui layouts in new tab.
end

--- other hook events ---------------------------------------------------------- {{{
--- debug job done 之前 close debug tab, dap-repl, dap-ui windows
--- NOTE: 不要自动关闭, 使用自定义函数手动关闭.
-- dap.listeners.before.event_terminated["dapui_config"] = function()
--   print('event terminated')
--   vim.cmd('stopinsert')
--   close_debug_tab_and_buffers()
-- end

--- NOTE: Not working right now.
-- dap.listeners.before.event_exited["dapui_config"] = function()
--   print('event exited')
--   vim.cmd('stopinsert')
--   close_debug_tab_and_buffers()
-- end
-- --}}}

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
--- dap-ui 可用方法, `:help nvim-dap-ui` --------------------------------------- {{{
--- debug window 控制.
---   dapui.open()
---   dapui.close()
---   dapui.toggle()
--- 在 float window 中显示 element. eg: scopes, watches, breakpoints, stacks, repl
---   dapui.float_element({elem_name}, {settings})
--- 获取 var value under cursor. {expr} = nil 时, 使用 <cword>.
---   dapui.eval({expr}, {settings})
-- -- }}}
local opt = { noremap = true, silent = true }
local debug_keymaps = {
  {'n', '<leader>cs', function() dap.continue() end,  opt, 'debug: Start(Continue)'},
  {'n', '<leader>ce', function() dap.terminate() end, opt, 'debug: Stop(End)'},
  {'n', '<leader>cr', function() dap.run_last() end,  opt, 'debug: Restart'},
  {'n', '<leader>cq', function() close_debug_tab_and_buffers() end, opt, 'debug: Quit'},

  --- NOTE: 这里是 dapui 的方法 eval(), {enter=true}进入 float window.
  {'n', '<leader>cc', function() dapui.eval(nil, {enter=true}) end, opt, 'debug: Popup Value under cursor'},

  --{'n', '<F9>', function() dap.toggle_breakpoint() end, opt, "debug: Toggle Breakpoint"},  -- 在 after/ftplugin/go/debug_cmd.lua 中设置.
  {'n', '<F21>', function() dap.clear_breakpoints() end, opt, "debug: Clear Breakpoints"},  -- <S-f9>
  {'n', '<F10>', function() dap.step_over() end, opt, "debug: Step Over"},
  {'n', '<F11>', function() dap.step_into() end, opt, "debug: Step Into"},
  {'n', '<F23>', function() dap.step_out() end,  opt, "debug: Step Out"},  -- <S-F11>
}
require('user.utils.keymaps').set(debug_keymaps)

--- keymaps: jump_to_file in dap-repl window -------------------------------------------------------
local fp = require('user.utils.filepath')
vim.api.nvim_create_autocmd("FileType", {
  pattern = {"dap-repl"},
  callback = function(params)
    fp.setup(params.buf)
  end,
  desc = "dap: keymap for jump_to_file",
})



