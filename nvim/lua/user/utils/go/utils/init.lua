local go_list_module = require("user.utils.go.utils.go_list")
local go_testflags   = require("user.utils.go.utils.testflags")
local my_term = require("user.utils.term")

local M = {
  go_list = go_list_module.go_list,

  parse_testflag_cmd = go_testflags.parse_testflag_cmd,
  get_testflag_desc = go_testflags.get_testflag_desc,
}

local function select_pprof(job)
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
        my_term.bg.spawn(flag_cmd.suffix, job)
      end
    end
  end)
end

--- create :GoPprof command & <F6> keymap
M.set_pprof_cmd_keymap = function(job)
  --- user command
  vim.api.nvim_buf_create_user_command(0, 'GoPprof', function() select_pprof(job) end, {bang=true})

  --- keymap
  vim.api.nvim_buf_set_keymap(0, 'n', '<F6>', '', {
    noremap = true,
    silent = true,
    callback = function() select_pprof(job) end,
    desc = 'Go tool pprof/trace',
  })

  --- info Keymap and Command setup
  Notify("terminal <buffer> can now use '<F6>' OR ':GoPprof' to display other profiles.", "INFO")
end

M.autocmd_shutdown_all_bg_terms = function(job, bufnr)
  --- delete all bg_term after this buffer removed.
  --- NOTE: 这里不能用 BufDelete, 因为 terminal 本来就不在 buflist 中, 所以不会触发 BufDelete.
  local group_id = vim.api.nvim_create_augroup("my_bg_term_job_" .. job, {clear = true})
  vim.api.nvim_create_autocmd("BufWipeout", {
    group = group_id,
    buffer = bufnr,
    callback = function(params)
      --- delete all running bg_term
      my_term.bg.shutdown_all(job)

      --- delete augroup
      vim.api.nvim_del_augroup_by_id(group_id)
    end,
    desc = 'delete all bg_term when this buffer is wiped out',
  })
end

return M
