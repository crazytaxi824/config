--- 主要用于在后台执行 go tool 命令:
-- go tool pprof -http=localhost: block.out
-- go tool pprof -http=localhost: cpu.out
-- go tool pprof -http=localhost: mem.out
-- go tool pprof -http=localhost: mutex.out
-- go tool trace -http=localhost: trace.out  -- VVI: 注意这里是 'trace' 不是 'pprof'

local M ={}

M.flag_desc = {
  cpu   = { desc = 'CPU profile' },
  mem   = { desc = 'Memory profile' },
  mutex = { desc = 'Mutex profile' },
  block = { desc = 'Block profile' },
  trace = { desc = 'Trace' },
}

local cache_bg_jobs = {}  -- 缓存 bg_job_id, map-table: [term_bufnr] = {job_id, ... }

local function job_exec(cmd, term_bufnr)
  --- VVI: 这里使用 scratch buffer 来执行 jobstart():
  ---   1. 为了避免创建新的一个 window.
  ---   2. 方便使用 `:ls` 来查看未关闭的 job.
  ---   3. 同时也可以通过 `:[N]buf` 来查看 bg job 的输出内容.
  local scratch_bufnr = vim.api.nvim_create_buf(false, true)
  local bg_job_id
  vim.api.nvim_buf_call(scratch_bufnr, function()
    bg_job_id = vim.fn.jobstart(cmd, {
      term = true,
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

local function autocmd_shutdown_all_jobs(term_bufnr)
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

local function select_pprof(term_bufnr, pprof_dir)
  --- 在后台静默运行 `go tool pprof/trace ...`
  local select = {'cpu', 'mem', 'mutex', 'block', 'trace'}
  vim.ui.select(select, {
    prompt = 'choose pprof profile to view: [coverage profile is an HTML file, open to view]',
    format_item = function(item)
      return M.flag_desc[item].desc
    end
  }, function(choice)
    if not choice then
      return
    end

    local cmd = {'go', 'tool', 'pprof', '-http=localhost:', pprof_dir..choice..'.out'}
    if choice == 'trace' then
      cmd = {'go', 'tool', 'trace', '-http=localhost:', pprof_dir..choice..'.out'}
    end
    job_exec(cmd, term_bufnr)
  end)
end

--- create :GoPprof command & <F6> keymap
local function set_cmd_and_keymaps(term_bufnr, pprof_dir)
  --- user command
  vim.api.nvim_buf_create_user_command(term_bufnr, 'GoPprof', function()
    select_pprof(term_bufnr, pprof_dir)
  end, {bang=true})

  --- keymap
  vim.keymap.set('n', '<F6>', function()
    select_pprof(term_bufnr, pprof_dir)
  end,
  {
    buffer=term_bufnr,
    silent = true,
    desc = 'Fn 6: go_pprof: Go tool pprof/trace',
  })

  --- info Keymap and Command setup
  Notify("terminal <buffer> can now use '<F6>' OR ':GoPprof' to display other profiles.", "INFO")
end

M.on_exit = function(opts, pprof_dir)
  local cmd = {'go', 'tool', 'pprof', '-http=localhost:', pprof_dir..opts.flag..'.out'}
  if opts.flag == 'trace' then
    cmd = {'go', 'tool', 'trace', '-http=localhost:', pprof_dir..opts.flag..'.out'}
  end

  --- VVI: return a callback function for jobstart(cmd, { on_exit = function(term) })
  return function(term)
    --- :GoPprof && <F6>
    set_cmd_and_keymaps(term.bufnr, pprof_dir)

    --- autocmd BufWipeout jobstop()
    autocmd_shutdown_all_jobs(term.bufnr)

    --- run `go tool pprof/trace ...` in background
    job_exec(cmd, term.bufnr)
  end
end

return M
