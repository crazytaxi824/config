--- 主要用于在后台执行 go tool 命令:
-- go tool pprof -http=localhost: block.out
-- go tool pprof -http=localhost: cpu.out
-- go tool pprof -http=localhost: mem.out
-- go tool pprof -http=localhost: mutex.out
-- go tool trace -http=localhost: trace.out
-- go tool cover -html=cover.out -o cover.html && open cover.html

local go_testflags = require("utils.go.utils.testflags")

local M ={}

local cache_bg_jobs = {}  -- 缓存 bg_job_id, map-table: [term_bufnr] = {job_id, ... }

M.job_exec = function (cmd, term_bufnr)
  --- 执行 cmd
  --- NOTE: 这里选择使用 termopen() 而不是 jobstart() 来执行 background job 是:
  --- 1. 为了方便使用 `:ls` 来查看未关闭的 job.
  --- 2. 同时也可以通过 `:[N]buf` 来查看 bg job 的输出内容.

  --- 创建一个 scratch buffer 用于执行 background job.
  local scratch_bufnr = vim.api.nvim_create_buf(false, true)

  local bg_job_id
  --- VVI: 这里使用 nvim_buf_call() 来执行 termopen() 是为了避免创建一个 window 来执行 termopen()
  vim.api.nvim_buf_call(scratch_bufnr, function()
    bg_job_id = vim.fn.termopen(cmd, {
      on_exit = function()
        vim.api.nvim_buf_delete(scratch_bufnr, {force=true})
      end
    })
  end)

  --- 缓存当前 bg_job_id
  if cache_bg_jobs[term_bufnr] then
    table.insert(cache_bg_jobs[term_bufnr], bg_job_id)
  else
    cache_bg_jobs[term_bufnr] = {bg_job_id}
  end
end

local function shutdown_all_jobs(term_bufnr)
  for _, j_id in ipairs(cache_bg_jobs[term_bufnr]) do
    vim.fn.jobstop(j_id)
  end

  --- 清空 cache
  cache_bg_jobs[term_bufnr] = nil
end

M.autocmd_shutdown_all_jobs = function(term_bufnr)
  --- jobstop() all jobs after this buffer removed.
  --- NOTE: 这里使用 group_id 是为了避免多次重复设置同一个 autocmd.
  --- NOTE: 这里不能用 BufDelete, 因为 terminal 本来就不在 buflist 中, 所以不会触发 BufDelete.
  local group_id = vim.api.nvim_create_augroup("my_term_bg_job_" .. term_bufnr, {clear = true})
  vim.api.nvim_create_autocmd("BufWipeout", {
    group = group_id,
    buffer = term_bufnr,
    callback = function(params)
      --- delete all running jobs
      shutdown_all_jobs(term_bufnr)

      --- delete augroup
      vim.api.nvim_del_augroup_by_id(group_id)
    end,
    desc = 'go_pprof: delete all jobs when this buffer is wiped out',
  })
end

local function select_pprof(term_bufnr)
  --- 使用 jobstart() 在后台静默运行 `go tool pprof/trace ...`
  local select = {'cpu', 'mem', 'mutex', 'block', 'trace'}
  vim.ui.select(select, {
    prompt = 'choose pprof profile to view: [coverage profile is an HTML file, open to view]',
    format_item = function(item)
      return go_testflags.get_testflag_desc(item)
    end
  }, function(choice)
    if choice then
      local flag_cmd = go_testflags.parse_testflag_cmd(choice)
      if flag_cmd and flag_cmd.suffix and flag_cmd.suffix ~= '' then
        M.job_exec(flag_cmd.suffix, term_bufnr)
      end
    end
  end)
end

--- create :GoPprof command & <F6> keymap
M.set_cmd_and_keymaps = function(term_bufnr)
  --- user command
  vim.api.nvim_buf_create_user_command(term_bufnr, 'GoPprof', function() select_pprof(term_bufnr) end, {bang=true})

  --- keymap
  vim.api.nvim_buf_set_keymap(term_bufnr, 'n', '<F6>', '', {
    noremap = true,
    silent = true,
    callback = function() select_pprof(term_bufnr) end,
    desc = 'go_pprof: Go tool pprof/trace',
  })

  --- info Keymap and Command setup
  Notify("terminal <buffer> can now use '<F6>' OR ':GoPprof' to display other profiles.", "INFO")
end

return M
