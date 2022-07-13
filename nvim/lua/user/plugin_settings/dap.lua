--- https://github.com/leoluz/nvim-dap-go
--- https://github.com/mfussenegger/nvim-dap/wiki/Debug-Adapter-installation#go-using-delve-directly
local dap = require "dap"

dap.adapters.go = function(callback, config)
  local stdout = vim.loop.new_pipe(false)
  local handle
  local pid_or_err
  local port = 38697
  local opts = {
    stdio = {nil, stdout},
    args = {"dap", "-l", "127.0.0.1:" .. port},
    detached = true
  }
  handle, pid_or_err = vim.loop.spawn("dlv", opts, function(code)
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
      callback({type = "server", host = "127.0.0.1", port = port})
    end,
    100)
end

--- NOTE: for 'go' ONLY.
--- https://github.com/go-delve/delve/blob/master/Documentation/usage/dlv_dap.md
dap.configurations.go = {
  {
    type = "go",
    name = "Debug",
    request = "launch",
    program = "${file}"
  },
  {
    type = "go",
    name = "Debug test", -- configuration for debugging test files
    request = "launch",
    mode = "test",
    program = "${file}"
  },
  -- works with go.mod packages and sub packages 
  {
    type = "go",
    name = "Debug test (go.mod)",
    request = "launch",
    mode = "test",
    program = "./${relativeFileDirname}"
  }
}

--- dapui 设置 -------------------------------------------------------------------------------------
local dapui = require("dapui")
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
        "repl",  -- debug console
        --"console",  -- dapui console, go 中没用.
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

dap.listeners.after.event_initialized["dapui_config"] = function()
  dapui.open()
end
dap.listeners.before.event_terminated["dapui_config"] = function()
  dapui.close()
end
dap.listeners.before.event_exited["dapui_config"] = function()
  dapui.close()
end

--- VVI: for dap-ui use ONLY, unlist 'filetype:dap-repl filename:[dap-repl]' buffer.
--- 如果没有 dap-ui 则不能 unlist dap-repl buffer, 因为没办法操作 debug.
vim.api.nvim_create_autocmd("FileType", {
  pattern = {"dap-repl"},
  command = "setlocal nobuflisted"
})



