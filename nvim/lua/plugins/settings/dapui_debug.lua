local dapui_status_ok, dapui = pcall(require, "dapui")
if not dapui_status_ok then
  return
end

--- `:help dapui.setup()`
dapui.setup({
  mappings = {
    expand = {"<CR>", "<2-LeftMouse>"}, -- Use a table to apply multiple mappings
    edit = "e",
    remove = "d",
    repl = "r",

    open = "o",   -- eg: jump to breakpoints
    toggle = "T", -- eg: toggle breakpoints. 't' keymap 冲突.
  },

  layouts = {
    {
      elements = {
        --- NOTE: 顺序有影响.
        "scopes",
        "watches",
        { id = "breakpoints", size = 0.3 },  -- Elements can be strings or table with id and size keys.
        --{ id = "stacks", size = 0.25 },  -- Elements can be strings or table with id and size keys.
      },
      position = "left",
      size = 0.4, -- columns (width)
    },
    {
      elements = {
        "repl",  -- REPL / Debug console
        --"console",  -- dapui console, 在 go 中没用.
      },
      position = "bottom",
      size = 0.3, -- 25% of total lines (height)
    },
  },

  --- winbar
  controls = {
    --- NOTE: dapui controls enable 之后无法删除 [dap-repl] buffer.
    enabled = true,
    --- VVI: Display controls in this element
    element = "repl",  -- repl | watches | stacks | scopes | console
    icons = {
      play      = " (󰘶F5)",  -- ▶️ 
      step_over = " (F10)",  -- ↷ ⨠
      step_into = "󰆹 (F11)",  -- ⇩↧⊻
      step_out  = "󰆸 (󰘶F11)",   -- ⇧↥⊼
      run_last  = " (󰘴F5)",   -- ↻⟳
      terminate = " (󰘴󰘶F5)",  -- ■

      --- 不常用
      disconnect = "",
      pause = "",
      step_back = "",
      -- disconnect = "[ disconnect]"
      -- pause     = "[ Pause]",
      -- step_back = "[ Back]",  -- ↶ ↩︎
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

--- keymaps ----------------------------------------------------------------------------------------
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
local opt = { silent = true }
local debug_keymaps = {
  --- NOTE: 这里是 dapui 的方法 eval(), {enter=true}进入 float window.
  {'n', '<leader>cc', function() dapui.eval(nil, {enter=true}) end, opt, 'debug: Popup Value under cursor'},
}
require('utils.keymaps').set(debug_keymaps)



