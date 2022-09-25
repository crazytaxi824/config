local comment_status_ok, comment = pcall(require, "Comment")
if not comment_status_ok then
  return
end

--- https://github.com/numToStr/Comment.nvim
comment.setup {
  padding = true, -- Add a space between '//' and content. (boolean|fun():boolean)
  sticky = true,  -- Whether the cursor should stay at its position. (boolean)
  ignore = nil,   -- 忽略行, eg: ^func.*

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

  --- 禁用默认 key mapping
  mappings = {
    --- Operator-pending mapping
    --- Includes `gcc`, `gbc`, `gc[count]{motion}` and `gb[count]{motion}`
    --- NOTE: These mappings can be changed individually by `opleader` and `toggler` config
    basic = false,
    --- Extra mapping
    --- Includes `gco`, `gcO`, `gcA`
    extra = false,
    --- Extended mapping
    --- Includes `g>`, `g<`, `g>[count]{motion}` and `g<[count]{motion}`
    extended = false,
  },
}

--- keymaps ----------------------------------------------------------------------------------------
local c_api = require("Comment.api")

function _Comment_exclude_file(mode)
  if not vim.bo.modifiable then
    vim.notify("cannot Comment on no-modifiable file", vim.log.levels.WARN)
    return
  end

  if mode == 'current' then
    c_api.toggle.linewise.current()
  elseif mode == 'visual' then
    --- 方法拷贝自 '<Plug>(comment_toggle_linewise_visual)' 源代码
    --- https://github.com/numToStr/Comment.nvim/blob/master/plugin/Comment.lua
    c_api.locked("toggle.linewise")(vim.fn.visualmode())
  end
end

local opt = { noremap = true, silent = true }
local comment_keymaps = {
  {'n', '<C-j>', function() _Comment_exclude_file("current") end, opt, 'which_key_ignore'},
  {'v', '<C-j>', '<C-c><CMD>lua _Comment_exclude_file("visual")<CR>', opt, 'which_key_ignore'},

  -- {'n', '<leader>\\', '<Plug>(comment_toggle_linewise_current)', opt, 'toggle Comment'},
  -- {'v', '<leader>\\', '<Plug>(comment_toggle_linewise_visual)',  opt, 'toggle Comment'},
}

Keymap_set_and_register(comment_keymaps)



