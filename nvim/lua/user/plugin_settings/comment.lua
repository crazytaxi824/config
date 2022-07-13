local comment_status_ok, comment = pcall(require, "Comment")
if not comment_status_ok then
  return
end

-- https://github.com/numToStr/Comment.nvim#-hooks
comment.setup {
  padding = true, -- Add a space between '//' and content. (boolean|fun():boolean)
  sticky = true,  -- Whether the cursor should stay at its position. (boolean)
  ignore = nil,   -- 忽略行, eg: ^func.*

  --- NOTE: pre_hook 配合 "JoosepAlviste/nvim-ts-context-commentstring" 设置.
  pre_hook = function(ctx)
    local U = require("Comment.utils")

    local location = nil
    if ctx.ctype == U.ctype.block then
      location = require("ts_context_commentstring.utils").get_cursor_location()
    elseif ctx.cmotion == U.cmotion.v or ctx.cmotion == U.cmotion.V then
      location = require("ts_context_commentstring.utils").get_visual_start_location()
    end

    return require("ts_context_commentstring.internal").calculate_commentstring {
      key = ctx.ctype == U.ctype.line and "__default" or "__multiline",
      location = location,
    }
  end,

  -- 禁用默认 key mapping
  mappings = {
    ---Operator-pending mapping
    ---Includes `gcc`, `gbc`, `gc[count]{motion}` and `gb[count]{motion}`
    ---NOTE: These mappings can be changed individually by `opleader` and `toggler` config
    basic = false,
    ---Extra mapping
    ---Includes `gco`, `gcO`, `gcA`
    extra = false,
    ---Extended mapping
    ---Includes `g>`, `g<`, `g>[count]{motion}` and `g<[count]{motion}`
    extended = false,
  },
}

--- keymaps ----------------------------------------------------------------------------------------
local opt = { noremap = true, silent = true }
local comment_keymaps = {
  {'n', '<leader>\\', '<Plug>(comment_toggle_current_linewise)', opt, 'Comment toggle'},
  {'v', '<leader>\\', '<Plug>(comment_toggle_linewise_visual)',  opt, 'Comment toggle'},
}

Keymap_set_and_register(comment_keymaps)



