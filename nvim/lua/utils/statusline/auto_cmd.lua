local stl_sec = require('utils.statusline.sections')
local stl_hl = require('utils.statusline.highlights')
local c_mode = require('utils.statusline.mode')


local gid = vim.api.nvim_create_augroup("my_statusline", {clear=true})


--- active & inactive window
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
vim.api.nvim_create_autocmd({"ModeChanged"}, {
  group = gid,
  callback = function(args)
    stl_hl.update_act_hl({})
  end
})



