--- go test -v -o /path/binary -outputdir /go_pprof/dir/ -cpuprofile cpu.out -memprofile mem.out -mutexprofile mutex.out -blockprofile block.out -trace trace.out -timeout 10m -run "^TestFoo$" local/src/color
--- go test -v -o /path/binary -outputdir /go_pprof/dir/ -cpuprofile cpu.out -memprofile mem.out -mutexprofile mutex.out -blockprofile block.out -trace trace.out -timeout 10m -run ^$ -benchmem -bench "^BenchmarkFoo$" local/src/color
---
--- go tool pprof -http=localhost: xxx.out
--- go tool trace -http=localhost: xxx.out
---
--- NOTE: pprof 只能用于 single_fn, package

local utils = require("utils.go.deps.utils")


--- NOTE: 必须是绝对路径.
local pprof_dir = '/tmp/nvim/go_pprof/'

--- 缓存 job_id dict: `<term_bufnr = [job_id, ...]>`
---
--- @type table<integer, integer[]>
local cache_bg_jobs = {}

--- go test cmd
local go_test = {'go', 'test', '-count=1', '-v'}

--- `$ go help testflag`
local test_args = {
  --- go.test 可执行文件生成位置. NOTE: 必须指定位置, 否则会生成在当前文件夹下.
  --- '-o' 是 `$ go help build` 的 flag.
  '-o', vim.fs.joinpath(pprof_dir, 'go.test'),

  --- 以下所有 profile 文件生成的路径都在该路径下, 除非指定绝对路径.
  --- eg: '-cpuprofile a/b/c.out'  文件会生成在 pprof_dir/a/b/c.out
  --- eg: '-cpuprofile /a/b/c.out' 文件会生成在 /a/b/c.out
  '-outputdir', pprof_dir,

  --- 生成 profile 文件
  '-cpuprofile', 'cpu.out',
  '-memprofile', 'mem.out',
  '-mutexprofile', 'mutex.out',
  '-blockprofile', 'block.out',
  '-trace', 'trace.out',
}

--- description
local flag_desc = {
  cpu   = { desc = 'CPU profile' },
  mem   = { desc = 'Memory profile' },
  mutex = { desc = 'Mutex profile' },
  block = { desc = 'Block profile' },
  trace = { desc = 'Trace' },
}


--- 在指定 bufnr 中执行 jobstart(cmd), 但该 buffer 不显示在任何 window 中. (类似后台运行)
---
--- @param cmd string[]
--- @param term_bufnr integer
--- @param flag? string  'cpu'|'mem'|'mutex'|...
local function job_exec(cmd, term_bufnr, flag)
  --- VVI: 这里使用 scratch buffer 来执行 jobstart():
  ---   1. 为了避免创建新的一个 window.
  ---   2. 方便使用 `:ls` 来查看未关闭的 job.
  ---   3. 同时也可以通过 `:[N]buf` 来查看 bg job 的输出内容.
  local scratch_bufnr = vim.api.nvim_create_buf(false, true)
  local bg_job_id = vim.api.nvim_buf_call(scratch_bufnr, function()
    return vim.fn.jobstart(cmd, {
      term = true, -- 将 scratch_bufnr 作为 terminal buffer

      --- print http address for Serving web UI
      on_stdout = function(job_id, data)
        vim.notify("[" .. flag .. "]: " .. table.concat(data,"\n"), vim.log.levels.INFO)
      end,

      --- print error message
      on_stderr = function(job_id, data)
        vim.notify("[" .. flag .. "]: " .. table.concat(data,"\n"), vim.log.levels.ERROR)
      end,

      --- :bdelete bufnr when jobdone
      on_exit = function(job_id, exit_code)
        vim.api.nvim_buf_delete(scratch_bufnr, {force=true})
      end,
    })
  end)

  --- 缓存当前 bg_job_id
  if cache_bg_jobs[term_bufnr] then
    table.insert(cache_bg_jobs[term_bufnr], bg_job_id)
  else
    cache_bg_jobs[term_bufnr] = { bg_job_id }
  end
end

--- 选择使用哪种 pprof
---
--- @param term_bufnr integer
--- @param dir string (directory 存放 pprof files)
local function select_pprof(term_bufnr, dir)
  --- 在后台静默运行 `go tool pprof/trace ...`
  local select = vim.tbl_keys(flag_desc)
  vim.ui.select(select, {
    prompt = 'choose pprof profile to view: [coverage profile is an HTML file, open to view]',
    format_item = function(item)
      return flag_desc[item].desc
    end
  }, function(choice)
    if not choice then
      return
    end

    local pprof_filepath = vim.fs.joinpath(dir, choice .. '.out')

    local cmd = {'go', 'tool', 'pprof', '-http=localhost:', pprof_filepath}
    if choice == 'trace' then
      cmd = {'go', 'tool', 'trace', '-http=localhost:', pprof_filepath}
    end
    job_exec(cmd, term_bufnr, choice)
  end)
end

--- create :GoPprof command & <F6> keymap
---
--- @param term_bufnr integer
--- @param dir string (directory 存放 pprof files)
local function set_cmd_and_keymaps(term_bufnr, dir)
  --- user command
  vim.api.nvim_buf_create_user_command(term_bufnr, 'GoPprof', function()
    select_pprof(term_bufnr, dir)
  end, {bang=true})

  --- keymap
  vim.keymap.set('n', '<F6>', function()
    select_pprof(term_bufnr, dir)
  end,
  {
    buffer = term_bufnr,
    silent = true,
    desc = 'Fn 6: go_pprof: Go tool pprof/trace',
  })

  --- info Keymap and Command setup
  Notify("terminal <buffer> can now use '<F6>' OR ':GoPprof' to display other profiles.", "INFO")
end

--- jobstop() 所有在 bufnr 中运行的 job
---
--- @param term_bufnr integer
local function shutdown_all_jobs(term_bufnr)
  for _, j_id in ipairs(cache_bg_jobs[term_bufnr]) do
    vim.fn.jobstop(j_id)
  end

  --- 清空 cache
  cache_bg_jobs[term_bufnr] = nil
end

--- autocmd: 在 bufnr 被 wipeout 的时候 jobstop() 所有 jobs attched to bufnr.
---
--- @param term_bufnr integer
local function autocmd_shutdown_all_jobs(term_bufnr)
  --- jobstop() all jobs after this buffer removed.
  --- NOTE: 这里使用 group_id 是为了避免多次重复设置同一个 autocmd.
  --- NOTE: 这里不能用 BufDelete, 因为 terminal 本来就不在 buflist 中, 所以不会触发 BufDelete.
  local group_id = vim.api.nvim_create_augroup("my_term_bg_job_" .. term_bufnr, {clear = true})
  vim.api.nvim_create_autocmd("BufWipeout", {
    group = group_id,
    buffer = term_bufnr,
    callback = function(params)
      --- jobstop() all running jobs
      shutdown_all_jobs(term_bufnr)

      --- delete augroup
      vim.api.nvim_del_augroup_by_id(group_id)
    end,
    desc = 'go_pprof: delete all jobs when this buffer is wiped out',
  })
end

--- go tool pprof hook
---
--- @param opts GoTestOpts
--- @param dir string (directory 存放 pprof files)
--- @return MyTermOptsOnExit
local function on_exit(opts, dir)
  local pprof_filepath = vim.fs.joinpath(dir, opts.flag .. '.out')

  --- opts.flag == 'none' | 'fuzz' 时, 没有 on_exit function.
  local cmd = {'go', 'tool', 'pprof', '-http=localhost:', pprof_filepath}
  if opts.flag == 'trace' then
    cmd = {'go', 'tool', 'trace', '-http=localhost:', pprof_filepath}
  end

  --- VVI: return a callback function for jobstart(cmd, { on_exit = function(term) })
  return function(_, bufnr)
    --- :GoPprof && <F6>
    set_cmd_and_keymaps(bufnr, dir)

    --- autocmd: 在 bufnr 被 wipeout 的时候 jobstop() 所有 jobs attched to bufnr.
    autocmd_shutdown_all_jobs(bufnr)

    --- run `go tool pprof/trace ...` in background
    job_exec(cmd, bufnr, opts.flag)
  end
end


--- @type GoTestFlag
local M = {
  flags = function()
    return vim.tbl_keys(flag_desc)
  end,

  contains = function(flag)
    if flag_desc[flag] then
      return true
    end
  end,

  get_description = function (flag)
    local f = flag_desc[flag]
    if not f then
      error("flag is not defined")
    end

    return f.desc
  end,

  term_opts = function (opts)
    --- mkdir when module required, NOTE: will run only once.
    if not vim.uv.fs_stat(pprof_dir) then
      local result = vim.system({'mkdir', '-p', pprof_dir}, { text = true }):wait()
      if result.code ~= 0 then
        error(result.stderr ~= '' and result.stderr or result.code)
      end
    end

    return {
      cwd = opts.go_list.Root,
      cmd = vim.iter({go_test, test_args, utils.mode_flags(opts)}):flatten():totable(),
      on_exit = on_exit(opts, pprof_dir),
    }
  end
}

return M
