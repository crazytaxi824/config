--- dapui 设置 -------------------------------------------------------------------------------------
local dap, dapui = require("dap"), require("dapui")

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
        "repl",  -- REPL / Debug-console
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
vim.cmd([[au FileType dap-repl setlocal nobuflisted]])



