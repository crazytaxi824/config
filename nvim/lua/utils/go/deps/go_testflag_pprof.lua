--- go test -v \
---   -o /path/binary \
---   -outputdir /go_pprof/dir/ \
---   -cpuprofile cpu.out \
---   -memprofile mem.out \
---   -mutexprofile mutex.out \
---   -blockprofile block.out \
---   -trace trace.out \
---   -run ^$ -timeout 10m -benchmem -bench "^BenchmarkFoo$" local/src/color
---
--- go tool pprof -http=localhost: cpu.out
--- go tool trace -http=localhost: trace.out
---
--- NOTE: pprof 只能用于 single_fn, package

local utils = require("utils.go.deps.utils")


--- NOTE: 必须是绝对路径.
local pprof_dir = '/tmp/nvim/go_pprof/'

--- 缓存 job_id dict: `<term_bufnr = job_id>`
---
--- @type table<integer, integer>
local cache_bg_jobs = {}

--- go test cmd
local go_test = {'go', 'test', '-count=1', '-v'}

--- `$ go help testflag`
--- go test -cpuprofile cpu.out, -memprofile mem.out, -mutexprofile mutex.out, -blockprofile block.out, -trace trace.out
---
--- @param dir string  pprof_dir
--- @param flag string 'mem'|'cpu'|'mutex'|'block'|'trace'
--- @return string[]  extra_args
local function gen_extra_args(dir, flag)
  local extra_args = { '-' .. flag .. 'profile', flag .. '.out' }
  if flag == 'trace' then
    extra_args = { '-trace', 'trace.out' }
  end

  return vim.list_extend({
    --- `go help build`, [-o output] 生成 binary file 可执行文件.
    --- NOTE: 必须指定位置, 否则会生成在当前文件夹下.
    '-o', vim.fs.joinpath(dir, 'go.test'),

    --- `go help testflag`, -outputdir 只作用于 profiling output file.
    --- 以下所有 profile 文件生成的路径都在该路径下, 除非指定绝对路径.
    --- eg: '-cpuprofile a/b/c.out'  文件会生成在 pprof_dir/a/b/c.out
    --- eg: '-cpuprofile /a/b/c.out' 文件会生成在 /a/b/c.out
    '-outputdir', dir,
  }, extra_args)
end


--- 在指定 bufnr 中执行 jobstart(cmd), 但该 buffer 不显示在任何 window 中. (类似后台运行)
---
--- @param cmd string[]
--- @param term_bufnr integer  attach to this buffer
--- @param flag string  'cpu'|'mem'|'mutex'|...
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
      ---
      --- @param job_id integer
      --- @param data string[]
      on_stdout = function(job_id, data)
        vim.notify("[" .. flag .. "]: " .. table.concat(data,"\n"), vim.log.levels.INFO)
      end,

      --- print error message
      ---
      --- @param job_id integer
      --- @param data string[]
      on_stderr = function(job_id, data)
        vim.notify("[" .. flag .. "]: " .. table.concat(data,"\n"), vim.log.levels.ERROR)
      end,

      --- :bwipeout bufnr when jobdone
      ---
      --- @param job_id integer
      --- @param exit_code integer
      on_exit = function(job_id, exit_code)
        if vim.api.nvim_buf_is_valid(scratch_bufnr) then
          vim.api.nvim_buf_delete(scratch_bufnr, {force=true})  -- :bwipeout
        end
      end,
    })
  end)

  --- 缓存当前 bg_job_id
  cache_bg_jobs[term_bufnr] = bg_job_id
end

--- autocmd: 在 bufnr 被 wipeout 的时候 jobstop() 所有 jobs attched to bufnr.
---
--- @param term_bufnr integer
local function autocmd_jobstop(term_bufnr)
  --- jobstop() all jobs after this buffer removed.
  --- NOTE: 这里使用 group_id 是为了避免多次重复设置同一个 autocmd.
  --- NOTE: 这里不能用 BufDelete, 因为 terminal 本来就不在 buflist 中, 所以不会触发 BufDelete.
  local group_id = vim.api.nvim_create_augroup("my_term_bg_job_" .. term_bufnr, {clear = true})
  vim.api.nvim_create_autocmd("BufWipeout", {
    group = group_id,
    buffer = term_bufnr,
    callback = function(params)
      --- jobstop()
      local job_id = cache_bg_jobs[term_bufnr]
      if job_id then
        vim.fn.jobstop(job_id)
      end

      --- 清空 cache
      cache_bg_jobs[term_bufnr] = nil

      --- delete augroup
      vim.api.nvim_del_augroup_by_id(group_id)
    end,
    desc = 'go_pprof: delete all jobs when this buffer is wiped out',
  })
end

--- go tool pprof hook
---
--- @param opts GoTestOpts
--- @param dir string  pprof_dir
--- @return MyTermOnExit
local function on_exit(opts, dir)
  local pprof_filepath = vim.fs.joinpath(dir, opts.flag .. '.out')

  --- opts.flag == 'none' | 'fuzz' 时, 没有 on_exit function.
  local cmd = {'go', 'tool', 'pprof', '-http=localhost:', pprof_filepath}
  if opts.flag == 'trace' then
    cmd = {'go', 'tool', 'trace', '-http=localhost:', pprof_filepath}
  end

  --- VVI: return a callback function for jobstart(cmd, { on_exit = function(term) })
  return function(_, bufnr)
    --- autocmd: 在 bufnr 被 wipeout 的时候 jobstop() 所有 jobs attched to bufnr.
    autocmd_jobstop(bufnr)

    --- run `go tool pprof/trace ...` in background
    job_exec(cmd, bufnr, opts.flag)
  end
end

--- @param dir string  pprof_dir
--- @return fun(opts: GoTestOpts): MyTermOpts
local function gen_term_opts(dir)
  --- mkdir when module required, NOTE: will run only once.
  if not vim.uv.fs_stat(dir) then
    local result = vim.system({'mkdir', '-p', dir}, { text = true }):wait()
    if result.code ~= 0 then
      error(result.stderr ~= '' and result.stderr or result.code)
    end
  end

  return function(opts)
    return {
      cwd = opts.go_list.Root,
      cmd = vim.iter({go_test, gen_extra_args(dir, opts.flag), utils.mode_flags(opts)}):flatten():totable(),
      on_exit = on_exit(opts, dir),
    }
  end
end


--- @type GoTestFlagDict
local M = {
  list = { "cpu", "mem", "mutex", "block", "trace" },

  flags = {
    cpu   = { desc = 'CPU profile', term_opts = gen_term_opts(pprof_dir)},
    mem   = { desc = 'Memory profile', term_opts = gen_term_opts(pprof_dir) },
    mutex = { desc = 'Mutex profile', term_opts = gen_term_opts(pprof_dir) },
    block = { desc = 'Block profile', term_opts = gen_term_opts(pprof_dir) },
    trace = { desc = 'Trace', term_opts = gen_term_opts(pprof_dir) },
  }
}

return M
