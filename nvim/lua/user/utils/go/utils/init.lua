local go_list_module = require("user.utils.go.utils.go_list")
local go_testflags   = require("user.utils.go.utils.testflags")
local my_term = require("user.utils.term")

local M = {
  go_list = go_list_module.go_list,

  parse_testflag_cmd = go_testflags.parse_testflag_cmd,
  get_testflag_desc = go_testflags.get_testflag_desc,
}

local function select_pprof()
  --- 使用 toggleterm:spawn() 在 background 运行 `go tool pprof/trace ...`
  local select = {'cpu', 'mem', 'mutex', 'block', 'trace'}
  vim.ui.select(select, {
    prompt = 'choose pprof profile to view: [coverage profile is an HTML, open to view]',
    format_item = function(item)
      return M.get_testflag_desc(item)
    end
  }, function(choice)
    if choice then
      local flag_cmd = M.parse_testflag_cmd(choice)
      if flag_cmd and flag_cmd.suffix and flag_cmd.suffix ~= '' then
        my_term.bg.spawn(flag_cmd.suffix)
      end
    end
  end)
end

--- create :GoPprof command & <F6> keymap
M.set_pprof_cmd_keymap = function()
  --- user command
  vim.api.nvim_buf_create_user_command(0, 'GoPprof', function() select_pprof() end, {bang=true})

  --- keymap
  vim.api.nvim_buf_set_keymap(0, 'n', '<F6>', '', {
    noremap = true,
    silent = true,
    desc = 'Go tool pprof/trace',
    callback = select_pprof,
  })

  --- info Keymap and Command setup
  Notify("terminal <buffer> can now use '<F6>' OR ':GoPprof' to display other profiles.", "INFO")
end

M.auto_shutdown_all_bg_terms = function()
  --- delete all bg_term after this buffer removed.
  --- NOTE: 这里不能用 BufDelete, 因为 terminal 本来就不在 buflist 中, 所以不会触发 BufDelete.
  vim.api.nvim_create_autocmd("BufWipeout", {
    buffer = 0,
    callback = function(params)
      --- delete all running bg_term
      my_term.bg.shutdown_all()
    end,
    desc = 'delete all bg_term when this buffer is deleted',
  })
end

return M
