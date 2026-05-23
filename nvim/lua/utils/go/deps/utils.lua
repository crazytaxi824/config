local M = {}


local test_patterns = {
  run   = { regexp = "^func%s+(Test[%w_]*)%s*%([%w_]*%s*%*testing%.T%)",      mode = 'run' },
  bench = { regexp = "^func%s+(Benchmark[%w_]*)%s*%([%w_]*%s*%*testing%.B%)", mode = 'bench' },
  fuzz  = { regexp = "^func%s+(Fuzz[%w_]*)%s*%([%w_]*%s*%*testing%.F%)",      mode = 'fuzz' },
}

-- 返回完整的 'Test Function Name' and 'Mode'
-- - `TestXxx(t *testing.T)`
-- - `BenchmarkXxx(b *testing.B)`
-- - `FuzzXxx(f *testing.F)`
--
---@return string|nil func_name
---@return 'run'|'bench'|'fuzz'|nil mode
function M.get_exact_testfn_name()
  local lcontent = vim.api.nvim_get_current_line()
  -- NOTE: go test 函数不允许 func [T any]TestXxx(), 不允许有 type param.
  -- %w     - 单个 char [a-zA-Z0-9]
  -- [%w_]  - 单个 char [a-zA-Z0-9_]
  for _, p in pairs(test_patterns) do
    local testfn = lcontent:match(p.regexp)
    if testfn then
      return testfn, p.mode
    end
  end
  Notify('Please put cursor on the line of "func Test/Benchmark/FuzzXxx()"', "INFO")
  return nil, nil  -- 显式返回
end


-- 返回 go test -run 使用的 regexp
--
---@param mode 'run'|'bench'
---@return string
function M.get_testfn_name_regexp(mode)
  local map = {
    run   = '^Test.*',
    bench = '^Benchmark.*',
    -- fuzz 函数只能单个测试
  }
  local result = map[mode]
  if not result then
    error('go test multi-function mode error: "run" | "bench" only.')
  end
  return result
end

-- 根据 flags 返回 {cmd} args
--
---@param opts GoTestOpts
---@return string[] cmd_args
function M.mode_flags(opts)
  local scope = opts.go_list.ImportPath
  if opts.project then
    scope = './...'  -- NOTE: './...' 意思是整个项目.
  end

  if opts.mode == 'run' then
    return {'-run', opts.testfn_name, scope}
  elseif opts.mode == 'bench' then
    return {'-run', '^$', '-benchmem', '-bench', opts.testfn_name, scope}
  elseif opts.mode == 'fuzz' then
    return {'-run', '^$', '-fuzz', opts.testfn_name, scope}
  else
    error("mode can only be 'run' | 'bench' | 'fuzz'")
  end
end

return M
