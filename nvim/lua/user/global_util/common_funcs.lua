--- NOTE: 返回光标所在位置是否已经在最左侧了, 或者光标前一个字符是否为 %s, 即:\n \t \r space ...
---       目的是判断是否需要执行 backspace.
---       true - 本行前一位没有任何字符; nil - 本行前一位有字符.
function Check_backspace()
  local col = vim.fn.col(".") - 1
  return col == 0 or vim.fn.getline("."):sub(col, col):match("%s")
end

--- 去掉 string prefix suffix whitespace -----------------------------------------------------------
--- 类似 vim.fn.trim()
function Trim_string(str)
  return string.match(str, "^%s*(.-)%s*$")
end

--- escape charactor -------------------------------------------------------------------------------
function Escape_chars(string)
  return string.gsub(string, "[%(|%)|\\|%[|%]|%-|%{%}|%?|%+|%*|%^|%$|%.]", {
    ["\\"] = "\\\\",
    ["-"] = "\\-",
    ["("] = "\\(",
    [")"] = "\\)",
    ["["] = "\\[",
    ["]"] = "\\]",
    ["{"] = "\\{",
    ["}"] = "\\}",
    ["?"] = "\\?",
    ["+"] = "\\+",
    ["*"] = "\\*",
    ["^"] = "\\^",
    ["$"] = "\\$",
    ["."] = "\\.",
  })
end

--- NOTE: 以下是 test functions --------------------------------------------------------------------

--- Debug plugins lazy load ------------------------------------------------------------------------

--- autocmd FileType go map key and command :Debug
vim.api.nvim_create_autocmd("FileType", {
  pattern = {"go"},  --- NOTE: 目前只对 go 使用 debug
  callback = function()
    --- keymap <F9> to dap.toggle_breakpoint()
    vim.api.nvim_buf_set_keymap(0, 'n', '<F9>', '',
      {
        noremap=true,
        callback = function()
          --- load nvim-api-ui (requires nvim-dap)
          require('packer').loader('nvim-dap-ui')  -- VVI: 相当于 ':PackerLoad nvim-dap-ui'

          --- toggle breakpoint
          require('dap').toggle_breakpoint()
        end,
      }
    )

    --- which-key <F9> toggle_breakpoint
    local wk_status_ok, wk = pcall(require, "which-key")
    if wk_status_ok then
      wk.register({['<leader>c<F9>'] = {"Debug - Toggle Breakpoint"}}, {mode="n"})
    end

    --- set command :Debug
    vim.api.nvim_buf_create_user_command(0, 'Debug',
      function()
        --- load nvim-api-ui (requires nvim-dap)
        require('packer').loader('nvim-dap-ui')  -- VVI: 相当于 ':PackerLoad nvim-dap-ui'

        local dap = require('dap')
        --- 如果 dap 已经运行, 则不进行任何操作.
        if not dap.session() then
          dap.continue() -- start debug
        end
      end,
      {bang=true, bar=true}
    )
  end,
})



