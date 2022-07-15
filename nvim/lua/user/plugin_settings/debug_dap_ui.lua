--- dapui 设置 -------------------------------------------------------------------------------------
local dap_status_ok, dap = pcall(require, "dap")
if not dap_status_ok then
  return
end

local dapui_status_ok, dapui = pcall(require, "dapui")
if not dapui_status_ok then
  return
end

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
      -- Elements can be strings or table with id and size keys.
        { id = "scopes", size = 0.25 },
        "breakpoints",
        "stacks",
        "watches",
      },
      size = 60, -- columns (width)
      position = "left",
    },
    {
      elements = {
        "repl",  -- REPL / Debug console
        --"console",  -- dapui console, 在 go 中没用.
      },
      size = 0.25, -- 25% of total lines (height)
      position = "bottom",
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

--- debug functions --------------------------------------------------------------------------------
--- open a new tab for debug
local function open_new_tab_for_debug()
  --- if debug tab exists, jump to debug tab.
  for _, tab_info in pairs(vim.fn.gettabinfo()) do
    if vim.fn.gettabvar(tab_info.tabnr, "debug").dap_tab then
      vim.cmd('normal! '.. tab_info.tabnr .. 'gt')  -- 1gt | 2gt jump to tab
      return
    end
  end

  -- VVI: open a new tab for debug.
  vim.cmd('tabnew '..vim.fn.bufname())

  --- 标记该 tab 为 'debug.dap_tab = true'
  vim.fn.settabvar(vim.fn.tabpagenr(), "debug", {dap_tab = true})
end

--- terminate debug && close debug tab/buffers
local function close_debug_tab_and_buffers()
  --- stop debug
  dap.terminate({},{terminateDebugee = true}, function()
    --- VVI: callback function, 在 session 结束后执行, 如果 session 不存在则立即执行.
    --- close dap related buffers
    --- NOTE: 如果在 dap.repl.close() 之后再执行 dap.terminal() 会重新打开 dap-repl buffer.
    dap.repl.close()  -- close dap-repl console window && delete dap-repl buffer.
    dapui.close()  -- close all dap-ui windows

    --- VVI: close 'debug.dap_tab = true' tab
    for _, tab_info in pairs(vim.fn.gettabinfo()) do
      if vim.fn.gettabvar(tab_info.tabnr, "debug").dap_tab then
        vim.cmd(tab_info.tabnr .. 'tabclose')
      end
    end
  end)  -- terminate the debug adapter and disconnect debug session
end

--- keymaps ----------------------------------------------------------------------------------------
local opt = { noremap = true, silent = true }
local debug_keymaps = {
  {'n', '<leader>cs', dap.continue,  opt, 'Debug - Start(Continue)'},
  {'n', '<leader>ce', dap.terminate, opt, 'Debug - Stop(End)'},
  {'n', '<leader>cr', dap.run_last,  opt, 'Debug - Restart'},
  {'n', '<leader>cc', dapui.eval,    opt, 'Debug - Popup Value under cursor'},  --- NOTE: 这里是 dapui, 运行两次进入 float window.
  {'n', '<leader>cq', close_debug_tab_and_buffers, opt, 'Debug - Quit'},

  -- {'n', '<F9>',  '<cmd>call vimspector#ToggleBreakpoint()<CR>', opt},
  {'n', '<F10>', dap.step_over, opt},
  {'n', '<F11>', dap.step_into, opt},
  {'n', '<F23>', dap.step_out,  opt},  -- <S-F11>
}

Keymap_set_and_register(debug_keymaps, {
  key_desc = {
    c = {
      name = "Code",  -- NOTE: 这里设置必须和 lua/user/lsp/util/lsp_keymaps 一致.
      -- ['<F9>'] = "Debug - Toggle Breakpoint",
      ['<F10>'] = "Debug - Step Over",
      ['<F11>'] = "Debug - Step Into",
      ['<S-F11>'] = "Debug - Step Out",
    }
  },
  opts = {mode='n', prefix='<leader>'}  -- NOTE: 针对 buffer 有效.
})

--- 开启 new tab 进行 debug ------------------------------------------------------------------------
--- 启动 debug 之前先打开 new tab
dap.listeners.before.event_initialized["dapui_config"] = function()
  open_new_tab_for_debug()
end

--- 启动 debug 之后, 打开 dap-ui windows
dap.listeners.after.event_initialized["dapui_config"] = function()
  dapui.open()  -- will open dap-ui layouts in new tab.
end

--- debug job done 之前 close debug tab, dap-repl, dap-ui windows
--- NOTE: 不需要自动关闭, 可以手动关闭.
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



