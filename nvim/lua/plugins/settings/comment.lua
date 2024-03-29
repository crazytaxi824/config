local comment_status_ok, comment = pcall(require, "Comment")
if not comment_status_ok then
  return
end

--- `:help comment-nvim`
--- https://github.com/numToStr/Comment.nvim
comment.setup {
  padding = true, -- Add a space between '//' and content. (boolean|fun():boolean)
  sticky = true,  -- Whether the cursor should stay at its position. (boolean), NOTE: 设置为 false 也没什么效果.
  ignore = nil,   -- 忽略行, eg: ignore = "^func.*"

  --- NOTE: pre_hook 配合 "JoosepAlviste/nvim-ts-context-commentstring" 设置.
  --- https://github.com/JoosepAlviste/nvim-ts-context-commentstring#commentnvim
  pre_hook = require('ts_context_commentstring.integrations.comment_nvim').create_pre_hook(),
  --- 手动设置 ts_context_commentstring prehook() ------------------------------ {{{
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

  --- VVI: 禁用 Comment 默认提供的 key mapping
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

--- NOTE: keymaps 在 plugins loader 的时候设置了.



