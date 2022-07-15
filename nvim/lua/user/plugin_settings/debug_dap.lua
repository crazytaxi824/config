--- https://github.com/leoluz/nvim-dap-go
--- https://github.com/mfussenegger/nvim-dap/wiki/Debug-Adapter-installation#go-using-delve-directly
local dap_status_ok, dap = pcall(require, "dap")
if not dap_status_ok then
  return
end

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
--- Some variables are supported:
--   `${file}`: Active filename
--   `${fileBasename}`: The current file's basename
--   `${fileBasenameNoExtension}`: The current file's basename without extension
--   `${fileDirname}`: The current file's dirname
--   `${fileExtname}`: The current file's extension
--   `${relativeFile}`: The current file relative to |getcwd()|
--   `${relativeFileDirname}`: The current file's dirname relative to |getcwd()|
--   `${workspaceFolder}`: The current working directory of Neovim
--   `${workspaceFolderBasename}`: The name of the folder opened in Neovim
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

--- sign
-- `DapBreakpoint` for breakpoints (default: `B`)
-- `DapBreakpointCondition` for conditional breakpoints (default: `C`)
-- `DapLogPoint` for log points (default: `L`)
-- `DapStopped` to indicate where the debugee is stopped (default: `→`)
-- `DapBreakpointRejected` to indicate breakpoints rejected by the debug adapter (default: `R`)
vim.cmd([[
  hi DapBreakpoint ctermfg=190
  hi DapStopped ctermfg=75
  hi DapStoppedLine ctermbg=238
]])

vim.fn.sign_define("DapBreakpoint", { text = "●", texthl = "DapBreakpoint", numhl = "", linehl="" })
vim.fn.sign_define("DapStopped", { text = " →", texthl = "DapStopped", numhl = "", linehl="DapStoppedLine" })

--- repl / debug console command
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



