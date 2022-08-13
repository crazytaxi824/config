--- https://github.com/leoluz/nvim-dap-go
--- https://github.com/mfussenegger/nvim-dap/wiki/Debug-Adapter-installation#go-using-delve-directly
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

dap.adapters.go = function(callback, config)
  local stdout = vim.loop.new_pipe(false)
  local handle
  local pid_or_err
  local host = "127.0.0.1"
  local port = 38697
  local opts = {
    stdio = {nil, stdout},
    args = {"dap", "-l", host .. ":" .. port},
    detached = true
  }
  handle, pid_or_err = vim.loop.spawn("dlv", opts, function(code)  --- NOTE: dlv command
    stdout:close()
    handle:close()
    if code ~= 0 then
      print('dlv exited with code', code)
    end
  end)
  assert(handle, 'Error running dlv: ' .. tostring(pid_or_err))
  stdout:read_start(function(err, chunk)
    assert(not err, err)
    if chunk then
      vim.schedule(function()
        require('dap.repl').append(chunk)
      end)
    end
  end)
  -- Wait for delve to start
  vim.defer_fn(
    function()
      callback({type = "server", host = host, port = port})
    end,
    100)
end

--- NOTE: for 'go' ONLY.
--- https://github.com/go-delve/delve/blob/master/Documentation/usage/dlv_dap.md
--- Some variables are supported --- {{{
--   `${file}`: Active filename
--   `${fileBasename}`: The current file's basename
--   `${fileBasenameNoExtension}`: The current file's basename without extension
--   `${fileDirname}`: The current file's dirname
--   `${fileExtname}`: The current file's extension
--   `${relativeFile}`: The current file relative to |getcwd()|
--   `${relativeFileDirname}`: The current file's dirname relative to |getcwd()|
--   `${workspaceFolder}`: The current working directory of Neovim
--   `${workspaceFolderBasename}`: The name of the folder opened in Neovim
-- -- }}}
dap.configurations.go = {
  {
    type = "go",
    name = "Debug go",
    request = "launch",
    program = "${file}"
  },
  -- go test package
  {
    type = "go",
    name = "Debug go test (package/dir)",
    request = "launch",
    mode = "test",
    program = "./${relativeFileDirname}"
  }
}

--- signs setting --- {{{
-- `DapBreakpoint` for breakpoints (default: `B`)
-- `DapBreakpointCondition` for conditional breakpoints (default: `C`)
-- `DapLogPoint` for log points (default: `L`)
-- `DapStopped` to indicate where the debugee is stopped (default: `→`)
-- `DapBreakpointRejected` to indicate breakpoints rejected by the debug adapter (default: `R`)
vim.cmd([[
  hi DapBreakpointHL ctermfg=190
  hi DapBreakpointRejectedHL ctermfg=190
  hi DapStoppedHL ctermfg=75
  hi DapStoppedLineHL ctermbg=238
]])

vim.fn.sign_define("DapBreakpoint", { text = "●", texthl = "DapBreakpointHL", numhl = "", linehl="" })
vim.fn.sign_define("DapBreakpointRejected", { text = "◌", texthl = "DapBreakpointRejectedHL", numhl = "", linehl="" })
vim.fn.sign_define("DapStopped", { text = " →", texthl = "DapStoppedHL", numhl = "", linehl="DapStoppedLineHL" })
-- -- }}}

--- repl / debug console command --- {{{
--    .exit               Closes the REPL
--    .c or .continue     Same as |dap.continue|
--    .n or .next         Same as |dap.step_over|
--    .into               Same as |dap.step_into|
--    .into_target        Same as |dap.step_into{askForTargets=true}|
--    .out                Same as |dap.step_out|
--    .up                 Same as |dap.up|
--    .down               Same as |dap.down|
--    .goto               Same as |dap.goto_|
--    .scopes             Prints the variables in the current scopes
--    .threads            Prints all threads
--    .frames             Print the stack frames
--    .capabilities       Print the capabilities of the debug adapter
--    .b or .back         Same as |dap.step_back|
--    .rc or
--    .reverse-continue   Same as |dap.reverse_continue|
-- -- }}}

--- nvim-dap-ui settings ---------------------------------------------------------------------------
dapui.setup({
  mappings = {
    expand = {"<CR>", "<2-LeftMouse>"}, -- Use a table to apply multiple mappings
    edit = "e",
    remove = "d",
    repl = "r",
    open = "o",
    toggle = "t",
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

  floating = {
    max_height = nil, -- These can be integers or a float between 0 and 1.
    max_width = nil, -- Floats will be treated as percentage of your screen.
    border = "single", -- "single", "double", "rounded" NOTE: 这里的 boarder 颜色是 Normal, 而不是 FloatBorder
    mappings = {
      close = { "q", "<Esc>" },
    },
  },
})

--- dap && dap-ui debug functions ------------------------------------------------------------------ {{{
--- NOTE: 通过 settabvar() && gettabvar() 来确定 debug_tab 是否存在.

--- open a new tab for debug
local function open_new_tab_for_debug()
  --- if debug tab exists, jump to debug tab.
  for _, tab_info in pairs(vim.fn.gettabinfo()) do
    if vim.fn.gettabvar(tab_info.tabnr, "debug").dap_tab then
      vim.cmd('normal! '.. tab_info.tabnr .. 'gt')  -- 1gt | 2gt jump to tab
      return
    end
  end

  -- VVI: if debug tab NOT exist, open a new tab for debug.
  vim.cmd('tabnew '..vim.fn.bufname())

  --- 标记该 tab 为 'debug.dap_tab = true'
  vim.fn.settabvar(vim.fn.tabpagenr(), "debug", {dap_tab = true})
end

--- terminate debug && close debug tab/buffers
local function close_debug_tab_and_buffers()
  --- dap.terminate({terminate_opt}, {disconnect_opts}, Callback), terminates the debug adapter and disconnect debug session.
  --- terminate opt:  https://microsoft.github.io/debug-adapter-protocol/specification#Requests_Terminate
  --- disconnect opt: https://microsoft.github.io/debug-adapter-protocol/specification#Requests_Disconnect
  --- Callback function 在 session 结束后执行, 如果 session 不存在则立即执行.
  dap.terminate({},{terminateDebugee = true}, function()
    --- NOTE: 如果在 dap.repl.close() 之后再执行 dap.terminal() 会重新打开 dap-repl buffer.
    dap.repl.close()  -- close dap-repl console window && delete dap-repl buffer.
    dapui.close()  -- close all dap-ui windows

    --- VVI: close 'debug.dap_tab = true' tab
    for _, tab_info in pairs(vim.fn.gettabinfo()) do
      if vim.fn.gettabvar(tab_info.tabnr, "debug").dap_tab then
        vim.cmd(tab_info.tabnr .. 'tabclose')
      end
    end
  end)
end

-- -- }}}

--- 开启 new tab 进行 debug ------------------------------------------------------------------------
--- 启动 debug 之前先打开 new tab
dap.listeners.before.event_initialized["dapui_config"] = function()
  open_new_tab_for_debug()
end

--- 启动 debug 之后, 打开 dap-ui windows
dap.listeners.after.event_initialized["dapui_config"] = function()
  dapui.open()  -- will open dap-ui layouts in new tab.
end

--- other hook events --- {{{
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
--- dap 可用方法 --- {{{
--   dap.run({config})
--   dap.launch({adapter}, {config})
--   dap.terminate(terminate_opts, disconnect_opts, callback)
--
--   dap.set_breakpoint({condition}, {hit_condition}, {log_message})
--   dap.toggle_breakpoint({condition}, {hit_condition}, {log_message})
--   dap.clear_breakpoints()
--
--   dap.step_over([{opts}])
--   dap.step_into([{opts}])
--   dap.step_out([{opts}])
--   dap.pause({thread_id})
--   dap.run_to_cursor()
--
--   dap.session()
--   dap.status()
-- -- }}}
--- dap-ui 可用方法 --- {{{
--   dapui.open()
--   dapui.close()
--   dapui.toggle()
--   dapui.eval()  -- 获取 var value under cursor
-- -- }}}
local opt = { noremap = true, silent = true }
local debug_keymaps = {
  {'n', '<leader>cs', dap.continue,  opt, 'Debug - Start(Continue)'},
  {'n', '<leader>ce', dap.terminate, opt, 'Debug - Stop(End)'},
  {'n', '<leader>cr', dap.run_last,  opt, 'Debug - Restart'},
  {'n', '<leader>cq', close_debug_tab_and_buffers, opt, 'Debug - Quit'},

  --- NOTE: 这里是 dapui 的方法 eval(), 运行两次进入 float window.
  {'n', '<leader>cc', function() dapui.eval() dapui.eval() end, opt, 'Debug - Popup Value under cursor'},

  --{'n', '<F9>',  dap.toggle_breakpoint, opt},  -- breakpoint 设置应该只针对源代码启用.
  {'n', '<F21>', dap.clear_breakpoints, opt},  -- <S-f9>
  {'n', '<F10>', dap.step_over, opt},
  {'n', '<F11>', dap.step_into, opt},
  {'n', '<F23>', dap.step_out,  opt},  -- <S-F11>
}

--- 这里是 global keymaps 设置
Keymap_set_and_register(debug_keymaps, {
  key_desc = {
    c = {
      name = "Code",  -- NOTE: 这里设置必须和 lua/user/lsp/util/lsp_keymaps 一致.
      -- ['<F9>'] = "Debug - Toggle Breakpoint",  -- NOTE: 已经在 debug_trigger.lua 中设置.
      ['<S-F9>']  = "Debug - Clear Breakpoints",
      ['<F10>']   = "Debug - Step Over",
      ['<F11>']   = "Debug - Step Into",
      ['<S-F11>'] = "Debug - Step Out",
    }
  },
  opts = {mode='n', prefix='<leader>'}  -- 全局有效
})



