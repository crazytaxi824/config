local go_pprof = require("utils.go.utils.go_pprof")

local M = {}

--- NOTE: 必须是绝对路径.
local pprof_dir = '/tmp/nvim/go_pprof/'

--- mkdir when module required, NOTE: will run only once.
if vim.fn.isdirectory(pprof_dir) == 0 then
  local result = vim.system({'mkdir', '-p', pprof_dir}, { text = true }):wait()
  if result.code ~= 0 then
    error(result.stderr ~= '' and result.stderr or result.code)
  end
end

local flag_desc_cmd = {
  none = { desc = '[No Extra Flag]', cmd = {} },  -- VVI: cmd 不能为 nil.

  --- pprof 的 4 个 testflag, '-cpuprofile', '-memprofile', '-blockprofile', '-mutexprofile'
  cpu   = { desc = 'CPU profile' },
  mem   = { desc = 'Memory profile' },
  mutex = { desc = 'Mutex profile' },
  block = { desc = 'Block profile' },
  trace = { desc = 'Trace' },

  cover = { desc = 'Coverage print on screen' },
  coverprofile = { desc = 'Coverage profile (detail)' },

  --- fuzztime flags
  fuzz30s = { desc = 'fuzztime 30s' },
  fuzz60s = { desc = 'fuzztime 60s' },
  fuzz5m  = { desc = 'fuzztime 5m'  },
  fuzz10m = { desc = 'fuzztime 10m' },
  fuzz_input = { desc = 'Input fuzztime: 15s|20m|1h20m30s (duration) | 1000x (times)' }
}

local pprof_flags = {
  --- go.test 可执行文件生成位置. NOTE: 必须指定位置, 否则会生成在当前文件夹下.
  --- '-o' 是 `$ go help build` 的 flag.
  '-o', pprof_dir .. 'go.test',

  --- 以下所有 profile 文件生成的路径都在该路径下, 除非指定绝对路径.
  --- eg: '-cpuprofile a/b/c.out'  文件会生成在 pprof_dir/a/b/c.out
  --- eg: '-cpuprofile /a/b/c.out' 文件会生成在 /a/b/c.out
  '-outputdir', pprof_dir,
  '-cpuprofile', 'cpu.out',
  '-memprofile', 'mem.out',
  '-mutexprofile', 'mutex.out',
  '-blockprofile', 'block.out',
  '-trace', 'trace.out',
}

local pprof_choices = {'cpu', 'mem', 'mutex', 'block', 'trace'}
local cover_choices = {'cover', 'coverprofile'}
local fuzz_choices  = {'fuzz30s', 'fuzz60s', 'fuzz5m', 'fuzz10m', 'fuzz_input'}


--- opts = {
---   testfn_name = testfn_name,
---   mode = mode,
---   flag = 'none' | 'cpu' | 'mem' | ...,
---   go_list = {},
---   project = string|nil,
--- }
--- mode = 'run' | 'bench' | 'fuzz'
local function mode_flags(opts)
  if opts.mode == 'run' then
    return {'-run', opts.testfn_name, opts.go_list.ImportPath}
  elseif opts.mode == 'bench' then
    return {'-run', '^$', '-bench', opts.testfn_name, opts.go_list.ImportPath}
  elseif opts.mode == 'fuzz' then
    return {'-run', '^$', '-fuzz', opts.testfn_name, opts.go_list.ImportPath}
  else
    error("mode can only be 'run' | 'bench' | 'fuzz'")
  end
end

--- VVI: TODO:
--- my_term_opts = {
---   cwd = dir,
---   cmd = {cmd_list},
---   before_run = function(term),
---   on_exit = function(term, job_id, exit_code, event)
--- }
M.my_term_opts = function(opts)
  local go_test = {'go', 'test', '-v'}

  --- 'cpu', 'mem', 'mutex', 'block', 'trace'
  if vim.tbl_contains(pprof_choices, opts.flag) then
    return {
      cwd = opts.go_list.Root,
      cmd = vim.iter({go_test, pprof_flags, mode_flags(opts)}):flatten():totable(),
      on_exit = function(term)
        --- :GoPprof command
        if vim.tbl_contains({'cpu', 'mem', 'mutex', 'block', 'trace'}, opts.flag) then
          go_pprof.set_cmd_and_keymaps(term.bufnr)
        end

        --- autocmd BufWipeout jobstop()
        go_pprof.autocmd_shutdown_all_jobs(term.bufnr)
        --- run `go tool pprof ...` in background
        go_pprof.job_exec({'go', 'tool', 'pprof', '-http=localhost:',pprof_dir..opts.flag..'.out'}, term.bufnr)
      end,
    }
  elseif opts.flag == 'cover' then
    return {
      cwd = opts.go_list.Root,
      cmd = vim.iter({go_test, '-cover', mode_flags(opts)}):flatten():totable(),
    }
  elseif opts.flag == 'coverprofile' then
    --- NOTE: 使用 '-coverprofile' 生成的 'cover.out' 文件必须在 go workspace 中, 否则无法进行分析.
    --- '-coverprofile /xxx/cover.out' 最好是是绝对路径, 避免和 '-outputdir' 冲突.
    local coverage_dir = opts.go_list.Root .. '/coverage/'

    --- NOTE: 如果是 `go test -coverprofile ./...` , go_list 中需要传递 project 属性, 用于指定文件名.
    --- 后半部分是将 filepath 中的 / 替换成 %.
    local cover_filename = opts.go_list.project or string.gsub(opts.go_list.ImportPath, '/', '%%')
    local cover_out = coverage_dir .. cover_filename .. '_cover.out'
    local cover_html = coverage_dir .. cover_filename .. '_cover.html'

    return {
      cwd = opts.go_list.Root,
      cmd = vim.iter({go_test, '-coverprofile', cover_out, mode_flags(opts)}):flatten():totable(),
      before_run = function()
        --- mkdir for coverage files
        if vim.fn.isdirectory(coverage_dir) == 0 then
          local result = vim.system({'mkdir', '-p', coverage_dir}, { text = true }):wait()
          if result.code ~= 0 then
            error(result.stderr ~= '' and result.stderr or result.code)
          end
        end
      end,
      on_exit = function()
        --- convert cover.out -> cover.html
        local result = vim.system({'go', 'tool', 'cover', '-html', cover_out, '-o', cover_html,}, {text = true,}):wait()
        if result.code ~= 0 then
          error(result.stderr ~= '' and result.stderr or result.code)
        end

        --- system open cover.html file.
        vim.ui.open(cover_html)
      end,
    }
  elseif opts.flag == 'fuzz30s' then
    return {
      cwd = opts.go_list.Root,
      cmd = vim.iter({go_test, '-fuzztime', '30s', mode_flags(opts)}):flatten():totable(),
    }
  elseif opts.flag == 'fuzz60s' then
    return {
      cwd = opts.go_list.Root,
      cmd = vim.iter({go_test, '-fuzztime', '60s', mode_flags(opts)}):flatten():totable(),
    }
  elseif opts.flag == 'fuzz5m' then
    return {
      cwd = opts.go_list.Root,
      cmd = vim.iter({go_test, '-fuzztime', '5m', mode_flags(opts)}):flatten():totable(),
    }
  elseif opts.flag == 'fuzz10m' then
    return {
      cwd = opts.go_list.Root,
      cmd = vim.iter({go_test, '-fuzztime', '10m', mode_flags(opts)}):flatten():totable(),
    }
  elseif opts.flag == 'fuzz_input' then
    local fuzz_time
    vim.ui.input({prompt = 'Input -fuzztime: '}, function(input)
      if input then
        fuzz_time = input
      end
    end)

    return {
      cwd = opts.go_list.Root,
      cmd = vim.iter({go_test, '-fuzztime', fuzz_time, mode_flags(opts)}):flatten():totable(),
    }
  else
    --- flag='none'
    return {
      cwd = opts.go_list.Root,
      cmd = vim.iter({go_test, mode_flags(opts)}):flatten():totable(),
    }
  end

end

--- 返回 description
M.get_testflag_desc = function(flag)
  local f = flag_desc_cmd[flag]
  if not f then
    return '[flag: "' .. flag .. '" is NOT in "testflags.lua" table]'
  end
  if not f.desc then
    return '[flag: "' .. flag .. '.desc" is MISSING from "testflags.lua" table]'
  end

  return f.desc
end

M.parse_testflag_cmd = function(opts)
  local term_opts = M.my_term_opts(opts)
  if not term_opts then
    return
  end

  --- my_term 执行 command
  local t = require('utils.my_term.instances').exec_term
  t.cmd = term_opts.cmd
  t.cwd = term_opts.cwd
  t.before_run = term_opts.before_run
  t.on_exit = term_opts.on_exit
  t:stop()
  t:run()
end

return M

