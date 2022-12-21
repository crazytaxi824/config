local comment_status_ok, comment = pcall(require, "Comment")
if not comment_status_ok then
  return
end

--- `:help comment-nvim`
--- https://github.com/numToStr/Comment.nvim
comment.setup {
  padding = true, -- Add a space between '//' and content. (boolean|fun():boolean)
  sticky = true,  -- Whether the cursor should stay at its position. (boolean)
  ignore = nil,   -- 忽略行, eg: ignore = "^func.*"

  --- NOTE: pre_hook 配合 "JoosepAlviste/nvim-ts-context-commentstring" 设置.
  --- https://github.com/JoosepAlviste/nvim-ts-context-commentstring#commentnvim
  pre_hook = require('ts_context_commentstring.integrations.comment_nvim').create_pre_hook(),
  --- 手动设置 ts_context_commentstring prehook() --- {{{
  --- https://github.com/numToStr/Comment.nvim#-hooks
  -- pre_hook = function(ctx)
  --   local U = require("Comment.utils")
  --
  --   local location = nil
  --   if ctx.ctype == U.ctype.blockwise then
  --     location = require("ts_context_commentstring.utils").get_cursor_location()
  --   elseif ctx.cmotion == U.cmotion.v or ctx.cmotion == U.cmotion.V then
  --     location = require("ts_context_commentstring.utils").get_visual_start_location()
  --   end
  --
  --   return require("ts_context_commentstring.internal").calculate_commentstring {
  --     --- NOTE: Determine whether to use linewise or blockwise commentstring
  --     key = ctx.ctype == U.ctype.linewise and "__default" or "__multiline",
  --     location = location,
  --   }
  -- end,
  -- -- }}}

  --post_hook = function(ctx)

  --- 禁用默认 key mapping
  mappings = {
    --- Operator-pending mapping
    --- Includes `gcc`, `gbc`, `gc[count]{motion}` and `gb[count]{motion}`
    --- NOTE: These mappings can be changed individually by `opleader` and `toggler` config
    basic = false,
    --- Extra mapping
    --- Includes `gco`, `gcO`, `gcA`
    extra = false,
  },
}

--- keymaps ----------------------------------------------------------------------------------------
local opt = { noremap = true, silent = true }
local comment_keymaps = {
  -- {'n', '<C-j>', require("Comment.api").toggle.linewise.current, opt, 'which_key_ignore'},
  -- {'i', '<C-j>', '<C-o><CMD>lua require("Comment.api").toggle.linewise.current()<CR>', opt, 'which_key_ignore'},
  -- {'v', '<C-j>', '<C-c><CMD>lua require("Comment.api").locked("toggle.linewise")(vim.fn.visualmode())<CR>', opt, 'which_key_ignore'},

  {'n', '<C-j>', '<Plug>(comment_toggle_linewise_current)', opt, 'which_key_ignore'},
  {'i', '<C-j>', '<C-o><Plug>(comment_toggle_linewise_current)', opt, 'which_key_ignore'},
  {'v', '<C-j>', '<Plug>(comment_toggle_linewise_visual)', opt, 'which_key_ignore'},
}

Keymap_set_and_register(comment_keymaps)



