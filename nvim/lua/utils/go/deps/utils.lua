

local test_run_fn_regexp = "^func%s+(Test[%w_]*)%s*%([%w_]*%s*%*testing%.T%)"
local test_bench_fn_regexp = "^func%s+(Benchmark[%w_]*)%s*%([%w_]*%s*%*testing%.B%)"
local test_fuzz_fn_regexp = "^func%s+(Fuzz[%w_]*)%s*%([%w_]*%s*%*testing%.F%)"

local M = {}

--- 返回完整的 'Test Function Name' and 'Mode'
--- - `TestXxx(t *testing.T)`
--- - `BenchmarkXxx(b *testing.B)`
--- - `FuzzXxx(f *testing.F)`
---
--- @return string|nil func_name (如果返回 nil 说明不是 test 函数)
--- @return 'run'|'bench'|'fuzz'|nil mode
function M.get_exact_testfn_name()
  local lcontent = vim.api.nvim_get_current_line()  -- 获取行内容

  --- NOTE: go test 函数不允许 func [T any]TestXxx(), 不允许有 type param.
  --- %w     - 单个 char [a-zA-Z0-9]
  --- [%w_]  - 单个 char [a-zA-Z0-9] && _
  --- [BFMT] - 单个 char B|F|M|T
  local testfn = lcontent:match(test_run_fn_regexp)
  if testfn then
    return testfn, 'run'
  end

  testfn = lcontent:match(test_bench_fn_regexp)
  if testfn then
    return testfn, 'bench'
  end

  testfn = lcontent:match(test_fuzz_fn_regexp)
  if testfn then
    return testfn, 'fuzz'
  end

  Notify('Please Put cursor on the line of "func Test/Benchmark/Fuzz_XXX()"', "INFO")
end

--- 返回 `^Test.*` | `^Benchmark.*`
---
--- @param mode 'run'|'bench'
--- @return string
function M.get_testfn_name_regexp(mode)
  if mode == 'run' then
    return '^Test.*'
  elseif mode == 'bench' then
    return '^Benchmark.*'
  else
    --- internal error
    error('go test mode error: "run" | "bench" only.')
  end
end

return M
