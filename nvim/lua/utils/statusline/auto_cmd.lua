local stl_sec = require('utils.statusline.sections')
local c_mode = require('utils.statusline.mode')

--- active & inactive window
local gid = vim.api.nvim_create_augroup("my_statusline", {clear=true})
vim.api.nvim_create_autocmd({"WinEnter", "WinLeave"}, {
  group = gid,
  callback = function(args)
    if args.event == "WinEnter" then
      stl_sec.update_act_stl({a = c_mode.mode(), x="%f"})
    elseif args.event == "WinLeave" then
      stl_sec.update_inact_stl({x="%t"})
    end
  end
})

--- change color
-- vim.api.nvim_create_autocmd({"ModeChanged"}, {
--   group = gid,
--   callback = function(args)
--     -- stl.update_hl()
--   end
-- })


