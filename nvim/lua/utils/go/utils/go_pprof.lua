--- 主要用于在后台执行 go tool 命令:
-- go tool pprof -http=localhost: block.out
-- go tool pprof -http=localhost: cpu.out
-- go tool pprof -http=localhost: mem.out
-- go tool pprof -http=localhost: mutex.out
-- go tool trace -http=localhost: trace.out
-- go tool cover -html=cover.out -o cover.html

local go_testflags = require("utils.go.utils.testflags")

local M ={}

local cache_jobs = {}  -- 缓存 job_id, map-table: [term_job_id] = {job_id, ... }

M.job_exec = function (cmd, term_job)
  --- 执行 cmd
  --- `:help channel-callback` for on_stdout() & on_stderr()
  local scratch_bufnr = vim.api.nvim_create_buf(false, true)

  local j_id
  --- VVI: 这里使用 nvim_buf_call() 来执行 termopen() 是为了避免创建一个 window 来执行 termopen()
  vim.api.nvim_buf_call(scratch_bufnr, function()
    j_id = vim.fn.termopen(cmd, {
      on_exit = function()
        vim.api.nvim_buf_delete(scratch_bufnr, {force=true})
      end
    })
  end)

  --- 缓存当前 job_id 到 term_job_id
  if cache_jobs[term_job] then
    table.insert(cache_jobs[term_job], j_id)
  else
    cache_jobs[term_job] = {j_id}
  end
end

local function shutdown_all_jobs(term_job)
  for _, j_id in ipairs(cache_jobs[term_job]) do
    vim.fn.jobstop(j_id)
  end

  --- 清空 cache
  cache_jobs[term_job] = {}
end

M.autocmd_shutdown_all_jobs = function(job, bufnr)
  --- jobstop() all jobs after this buffer removed.
  --- NOTE: 这里使用 group_id 是为了避免多次重复设置同一个 autocmd.
  --- NOTE: 这里不能用 BufDelete, 因为 terminal 本来就不在 buflist 中, 所以不会触发 BufDelete.
  local group_id = vim.api.nvim_create_augroup("my_term_job_" .. job, {clear = true})
  vim.api.nvim_create_autocmd("BufWipeout", {
    group = group_id,
    buffer = bufnr,
    callback = function(params)
      --- delete all running jobs
      shutdown_all_jobs(job)

      --- delete augroup
      vim.api.nvim_del_augroup_by_id(group_id)
    end,
    desc = 'go_pprof: delete all jobs when this buffer is wiped out',
  })
end

local function select_pprof(job)
  --- 使用 jobstart() 在后台静默运行 `go tool pprof/trace ...`
  local select = {'cpu', 'mem', 'mutex', 'block', 'trace'}
  vim.ui.select(select, {
    prompt = 'choose pprof profile to view: [coverage profile is an HTML, open to view]',
    format_item = function(item)
      return go_testflags.get_testflag_desc(item)
    end
  }, function(choice)
    if choice then
      local flag_cmd = go_testflags.parse_testflag_cmd(choice)
      if flag_cmd and flag_cmd.suffix and flag_cmd.suffix ~= '' then
        M.job_exec(flag_cmd.suffix, job)
      end
    end
  end)
end

--- create :GoPprof command & <F6> keymap
M.set_cmd_and_keymaps = function(job, term_bufnr)
  --- user command
  vim.api.nvim_buf_create_user_command(term_bufnr, 'GoPprof', function() select_pprof(job) end, {bang=true})

  --- keymap
  vim.api.nvim_buf_set_keymap(term_bufnr, 'n', '<F6>', '', {
    noremap = true,
    silent = true,
    callback = function() select_pprof(job) end,
    desc = 'go_pprof: Go tool pprof/trace',
  })

  --- info Keymap and Command setup
  Notify("terminal <buffer> can now use '<F6>' OR ':GoPprof' to display other profiles.", "INFO")
end

return M
