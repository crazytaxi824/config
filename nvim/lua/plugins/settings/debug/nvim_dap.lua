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
if __Debug_Neovim.dap_debug then
  dap.set_log_level("DEBUG")
else
  dap.set_log_level("ERROR")
end

--- load adapter configs
require("plugins.settings.debug.adapters.go")
require("plugins.settings.debug.adapters.py")

--- custom command for repl ------------------------------------------------------------------------
local repl = require('dap.repl')
repl.commands = vim.tbl_extend('force', repl.commands, {
  -- Add a new alias for the existing .exit command
  exit = {'.exit', '.q', '.quit'},
})

--- functions -------------------------------------------------------------------------------------- {{{
--- NOTE: 通过 set/get tab var 来确定 debug_tab 是否存在.
local tabvar_dap = "my_debug_tab_main_winid"

--- open a new tab for debug
local function open_new_tab_for_debug()
  --- if debug tab exists, jump to debug tab.
  for _, tab_id in pairs(vim.api.nvim_list_tabpages()) do
    if vim.t[tab_id][tabvar_dap] then
      vim.api.nvim_set_current_tabpage(tab_id)
      return
    end
  end

  --- if debug tab NOT exist, open a new tab for debug.
  local bufnr = vim.api.nvim_get_current_buf()
  vim.cmd.tabnew(vim.api.nvim_buf_get_name(bufnr))

  --- 标记该 tab.
  vim.t[tabvar_dap] = vim.api.nvim_get_current_win()
end

local function close_debug_tab()
  --- NOTE: 不太需要 wipeout repl buffer.
  --dap.repl.close()  -- close dap-repl console window && wipeout [dap-repl] buffer.

  local dapui_status_ok, dapui = pcall(require, "dapui")
  if dapui_status_ok then
    --- NOTE: 如果在 dap.repl.close() 之后再执行 dapui.close() 会重新打开 [dap-repl] buffer.
    dapui.close() -- close all dap-ui windows
  end

  --- 如果自己是 last tab 则不删除 main window, 但是删除 tabvar.
  local tab_list = vim.api.nvim_list_tabpages()
  if #tab_list < 2 then
    --- 删除 tabvar
    vim.t[tabvar_dap] = nil
    return
  end

  --- close debug tab
  for _, tab_id in pairs(tab_list) do
    if vim.t[tab_id][tabvar_dap] then
      --- NOTE: `:tabclose tabnr` NOT tab_id
      vim.cmd.tabclose(vim.api.nvim_tabpage_get_number(tab_id))
    end
  end
end

local function del_debug_keymaps()
  local keys = { "<F29>", "<F17>", "<F10>", "<F11>", "<F23>", "<S-D-F5>" }

  local buf_keymaps = vim.api.nvim_get_keymap("n")
  for _, key in ipairs(keys) do
    for _, buf_keymap in ipairs(buf_keymaps) do
      if buf_keymap["lhs"] == key then
        vim.api.nvim_del_keymap("n", key)
      end
    end
  end
end

--- terminate debug && close debug tab/buffers
local function quit_debug()
  --- 判断 session 是否已经结束
  --- session 结束后无法触发 dap.terminate() 函数
  if not dap.session() then
    close_debug_tab()
    del_debug_keymaps()
    return
  end

  --- dap.terminate({terminate_opt}, {disconnect_opts}, Callback), terminates the debug adapter and disconnect debug session.
  --- terminate opt:  https://microsoft.github.io/debug-adapter-protocol/specification#Requests_Terminate
  --- disconnect opt: https://microsoft.github.io/debug-adapter-protocol/specification#Requests_Disconnect
  dap.terminate({}, { terminateDebugee = true }, function()
    --- NOTE: Callback 异步函数中执行
    close_debug_tab()
    del_debug_keymaps()
  end)
end

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
local function set_debug_keymaps()
  local opt = { silent = true }
  local debug_keymaps = {
    --- <C-F5>
    {
      "n",
      "<F29>",
      function()
        if dap.session() then
          dap.continue() -- continue to finish the program
        else
          if vim.fn.win_gotoid(vim.t[tabvar_dap]) == 1 then
            dap.continue() -- start new debug
          end
        end
      end,
      opt,
      "Fn 5: debug: Start(Continue)",
    },

    --- <S-F5>
    {
      "n",
      "<F17>",
      function()
        dap.terminate()
      end,
      opt,
      "Fn 5: debug: Stop(End)",
    },

    {
      "n",
      "<S-D-F5>",
      function()
        if vim.fn.win_gotoid(vim.t[tabvar_dap]) == 1 then
          dap.run_last()
        end
      end,
      opt,
      "Fn 5: debug: Restart",
    },

    --- 已在 nvim/lua/plugins/init.lua 的 load 条件 init=function() 中设置.
    --{'n', '<F9>', function() dap.toggle_breakpoint() end, opt, "Fn 9: debug: Toggle Breakpoint"},

    {
      "n",
      "<F10>",
      function()
        if vim.fn.win_gotoid(vim.t[tabvar_dap]) == 1 then
          dap.step_over()
        end
      end,
      opt,
      "Fn10: debug: Step Over",
    },

    {
      "n",
      "<F11>",
      function()
        if vim.fn.win_gotoid(vim.t[tabvar_dap]) == 1 then
          dap.step_into()
        end
      end,
      opt,
      "Fn11: debug: Step Into",
    },

    --- <S-F11>
    {
      "n",
      "<F23>",
      function()
        if vim.fn.win_gotoid(vim.t[tabvar_dap]) == 1 then
          dap.step_out()
        end
      end,
      opt,
      "Fn11: debug: Step Out",
    },

    {
      "n",
      "<leader>cb",
      function()
        dap.clear_breakpoints()
      end,
      opt,
      "debug: Clear Breakpoints",
    },
    {
      "n",
      "<leader>cq",
      function()
        quit_debug()
      end,
      opt,
      "debug: Quit",
    },
  }

  require("utils.keymaps").set(debug_keymaps)
end
-- -- }}}

--- 开启 new tab 进行 debug ------------------------------------------------------------------------
--- https://github.com/rcarriga/nvim-dap-ui#usage & `:help dap-extensions`
--- 启动 debug 之前先打开 new tab
dap.listeners.before.event_initialized["foo"] = function()
  open_new_tab_for_debug()
  set_debug_keymaps()
end

--- 启动 debug 之后, 打开 dap-ui windows
dap.listeners.after.event_initialized["foo"] = function()
  local dapui_status_ok, dapui = pcall(require, "dapui")
  if dapui_status_ok then
    dapui.open() -- will open dap-ui layouts in new tab.
  end
end

--- other hook events ---------------------------------------------------------- {{{
--- debug job done 之前 close debug tab, dap-repl, dap-ui windows
--- NOTE: 不要自动关闭, 使用自定义函数手动关闭.
-- dap.listeners.before.event_terminated["foo"] = function()
--   print('event terminated')
--   vim.cmd.stopinsert()
--   close_debug_tab_and_buffers()
-- end

--- NOTE: Not working right now.
-- dap.listeners.before.event_exited["foo"] = function()
--   print('event exited')
--   vim.cmd.stopinsert()
--   close_debug_tab_and_buffers()
-- end
-- -- }}}

--- keymaps: jump_to_file in dap-repl window -------------------------------------------------------
local fp = require("utils.filepath")
vim.api.nvim_create_autocmd("FileType", {
  pattern = { "dap-repl" },
  callback = function(params)
    fp.setup(params.buf)
  end,
  desc = "dap: keymap for jump_to_file",
})

--- user command
vim.api.nvim_create_user_command("Debug", "DapContinue", { bang = true, bar = true })

--- highlight && sign setting ---------------------------------------------------------------------- {{{
--- `:help dap.txt`, search:
--- `DapBreakpoint` for breakpoints (default: `B`)
--- `DapBreakpointCondition` for conditional breakpoints (default: `C`)
--- `DapLogPoint` for log points (default: `L`)
--- `DapStopped` to indicate where the debugee is stopped (default: `→`)
--- `DapBreakpointRejected` to indicate breakpoints rejected by the debug adapter (default: `R`)
vim.api.nvim_set_hl(0, "DapBreakpointHL", { ctermfg = Colors.yellow.c, fg = Colors.yellow.g })
vim.api.nvim_set_hl(0, "DapBreakpointRejectedHL", { ctermfg = Colors.yellow.c, fg = Colors.yellow.g })
vim.api.nvim_set_hl(0, "DapStoppedHL", { ctermfg = Colors.blue.c, fg = Colors.blue.g })
vim.api.nvim_set_hl(0, "DapStoppedLineHL", { ctermbg = 24, bg = "#264f78" })

vim.fn.sign_define("DapBreakpoint", { text = "●", texthl = "DapBreakpointHL", numhl = "", linehl = "" })
vim.fn.sign_define(
  "DapBreakpointRejected",
  { text = "○", texthl = "DapBreakpointRejectedHL", numhl = "", linehl = "" }
)
vim.fn.sign_define("DapStopped", { text = "", texthl = "DapStoppedHL", numhl = "", linehl = "DapStoppedLineHL" })
-- -- }}}



