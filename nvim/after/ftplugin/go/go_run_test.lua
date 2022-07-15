--- Go Functions -----------------------------------------------------------------------------------
--- README:
--    获取 go import path, `cd src/xxx && go list -f '{{.ImportPath}}'`
--    获取 go module, `go list -m`, 项目中的任何路径下都能获取到.
--    lua regex - string.match(), https://fhug.org.uk/kb/kb-article/understanding-lua-patterns/
--
--  Go Test 操作方法:
--    cursor 指向 Test Function Name Line, 使用 <F6> 执行 go test singleTestFunc
--    <S-F6> go test -v -timeout 30s -run "^Test.*"
--    <C-F6> go test -v -timeout 30s -run ^$ -benchmem -bench "^Benchmark.*"

local status_ok, term = pcall(require, "toggleterm.terminal")
if not status_ok then
	return
end

local Terminal = term.Terminal

local go_term_id = 1024   -- NOTE: toggleterm count id

--- Terminal options for go only ---
local go_opts = {
  hidden = true,          -- VVI: true - 不加入到 terminal list, 无法被 `:ToggleTerm` 找到.
                          -- 用 :q 只能隐藏, 用 :q! exit job.
  close_on_exit = false,  -- 运行完成之后不要关闭 terminal.
  count = go_term_id,     -- 这里是指定 id, 类似 `:100ToggleTerm`,
                          -- 就算是 hidden 状态也可以通过 `:100ToggleTerm` 重新打开.
                          -- 如果两个 Terminal 有相同的 ID, 则会出现错误.

  --- move to previous window when job ends.
  -- on_exit = function()
  --   vim.cmd('wincmd p')
  -- end,

  --- matchadd(), highlight certain words in Current Window.
  --- use builtin highlight group 'Underlined'
  on_stdout = function(_,_,data,_)
    for _, lcontent in ipairs(data) do
      local filepath, lnum = Parse_filepath(lcontent)

      if vim.fn.filereadable(filepath) == 1 then
        if not lnum then  -- 如果没有 lnum 则
          vim.fn.matchadd('Underlined', filepath)  -- highlight filepath
        else
          vim.fn.matchadd('Underlined', filepath..':'..lnum)  -- highlight filepath && line number
        end
      end
    end
  end,
}

--- go run ----------------------------------------------------------------------------------------- {{{
local function go_run()
  -- 获取 _test.go 文件夹路径.
  local dir = vim.fn.expand('%:h')

  -- VVI: 获取 go import path, `cd src/xxx && go list -f '{{.ImportPath}}'`
  local import_path = string.match(vim.fn.system("cd " .. dir .. " && go list -f '{{.ImportPath}}'"), "[%S ]*")
  if vim.v.shell_error ~= 0 then
    Notify(import_path,"ERROR",{title={"go_run()","go_run_test.lua"}})
    return
  end

  -- VVI: 删除之前的 terminal.
  vim.cmd('silent! bw! term://*toggleterm#'..go_term_id)
  -- go run Package
  local go = Terminal:new(vim.tbl_deep_extend('force', go_opts, { cmd = "cd " .. dir .. " && go run " .. import_path }))
  go:toggle()
end
-- -- }}}

--- go test run all -------------------------------------------------------------------------------- {{{
local function go_test_all()
  -- 判断当前文件是否是 _test.go
  if string.match(vim.fn.expand('%:t'), "_test%.go$") == nil then
    Notify('not "_test.go" file',"ERROR",{title={"go_test_all()","go_run_test.lua"}})
    return
  end

  -- 获取 _test.go 文件夹路径.
  local dir = vim.fn.expand('%:h')

  -- VVI: 获取 go import path, `cd src/xxx && go list -f '{{.ImportPath}}'`
  local import_path = string.match(vim.fn.system("cd " .. dir .. " && go list -f '{{.ImportPath}}'"), "[%S ]*")
  if vim.v.shell_error ~= 0 then
    Notify(import_path,"ERROR",{title={"go_test_all()","go_run_test.lua"}})
    return
  end

  -- VVI: 删除之前的 terminal.
  vim.cmd('silent! bw! term://*toggleterm#'..go_term_id)
  -- go test -v -timeout 30s -run "^Test.*" ImportPath
  local cmd = 'cd ' .. dir .. ' && go test -v -timeout 30s -run "^Test.*" ' .. import_path
  local go = Terminal:new(vim.tbl_deep_extend('force', go_opts, { cmd = cmd }))
  go:toggle()
end
-- -- }}}

--- go test bench all ------------------------------------------------------------------------------ {{{
local function go_bench_all()
  -- 判断当前文件是否是 _test.go
  if string.match(vim.fn.expand('%:t'), "_test%.go$") == nil then
    Notify('not "_test.go" file',"ERROR",{title={"go_bench_all()","go_run_test.lua"}})
    return
  end

  -- 获取 _test.go 文件夹路径.
  local dir = vim.fn.expand('%:h')

  -- VVI: 获取 go import path, `cd src/xxx && go list -f '{{.ImportPath}}'`
  local import_path = string.match(vim.fn.system("cd " .. dir .. " && go list -f '{{.ImportPath}}'"), "[%S ]*")
  if vim.v.shell_error ~= 0 then
    Notify(import_path,"ERROR",{title={"go_bench_all()","go_run_test.lua"}})
    return
  end

  -- VVI: 删除之前的 terminal.
  vim.cmd('silent! bw! term://*toggleterm#'..go_term_id)
  -- go test -v -timeout 30s -run ^$ -benchmem -bench "^Benchmark.*" ImportPath
  local cmd = 'cd ' .. dir .. ' && go test -v -timeout 30s -run ^$ -benchmem -bench "^Benchmark.*" ' .. import_path
  local go = Terminal:new(vim.tbl_deep_extend('force', go_opts, { cmd = cmd }))
  go:toggle()
end
-- -- }}}

--- go test fuzz all ------------------------------------------------------------------------------- {{{
local function go_fuzz_all()
  -- 判断当前文件是否是 _test.go
  if string.match(vim.fn.expand('%:t'), "_test%.go$") == nil then
    Notify('not "_test.go" file',"ERROR",{title={"go_fuzz_all()","go_run_test.lua"}})
    return
  end

  -- 获取 _test.go 文件夹路径.
  local dir = vim.fn.expand('%:h')

  -- VVI: 获取 go import path, `cd src/xxx && go list -f '{{.ImportPath}}'`
  local import_path = string.match(vim.fn.system("cd " .. dir .. " && go list -f '{{.ImportPath}}'"), "[%S ]*")
  if vim.v.shell_error ~= 0 then
    Notify(import_path,"ERROR",{title={"go_fuzz_all()","go_run_test.lua"}})
    return
  end

  -- VVI: 删除之前的 terminal.
  vim.cmd('silent! bw! term://*toggleterm#'..go_term_id)
  -- go test -v -run ^$ -fuzztime 30s -fuzz "^Fuzz.*" ImportPath
  local cmd = 'cd ' .. dir .. ' && go test -v -fuzztime 30s -run ^$ -fuzz "^Fuzz.*" ' .. import_path
  local go = Terminal:new(vim.tbl_deep_extend('force', go_opts, { cmd = cmd }))
  go:toggle()
end
-- -- }}}

--- go test single function ------------------------------------------------------------------------ {{{
--- 从 cursor 所在行向上查找, 返回函数定义行 "func Foo(param type) {"
local function find_func_line()  -- return (func_name: string|nil)
  local lcontent = vim.fn.getline('.')  -- 获取行内容

  -- 如果找到 ^func.* 则返回整行内容.
  if string.match(lcontent, "^func .*") ~= nil then
    return lcontent
  end

  return nil  -- 如果都没找到则返回 nil
end

--- 返回 Test Function Name, "TestXxx(t *testing.T)", "BenchmarkXxx(b *testing.B)", "FuzzXxx(f *testing.F)"
--- NOTE: mark - 0: error | 1: TestXxx | 2: BenchmarkXxx | 3: FuzzXxx
local function go_test_func_name()  -- return {funcname: string|nil, mark :number}
  local func_line = find_func_line()
  if func_line == nil then
    return nil, 0
  end

  -- %w     - 单个 char [a-zA-Z0-9]
  -- [%w_]  - 单个 char [a-zA-Z0-9] && _
  -- [BFMT] - 单个 char B|F|M|T
  -- go test 函数不允许 func [T any]TestXxx(), 不允许有 type param.

  local testfn = string.match(func_line, "func Test[%w_]*%([%w_]* %*testing%.T%)")
  if testfn ~=nil then
    return string.match(testfn, "Test[%w_]*"), 1
  end

  testfn = string.match(func_line, "func Benchmark[%w_]*%([%w_]* %*testing%.B%)")
  if testfn ~=nil then
    return string.match(testfn, "Benchmark[%w_]*"), 2
  end

  testfn = string.match(func_line, "func Fuzz[%w_]*%([%w_]* %*testing%.F%)")
  if testfn ~=nil then
    return string.match(testfn, "Fuzz[%w_]*"), 3
  end

  return nil, 0
end

--- 返回 "go test -v -run TestFoo ImportPath"
local function go_test_cmd()   -- return (cmd: string|nil)
  -- 判断当前文件是否 _test.go
  if string.match(vim.fn.expand('%:t'), "_test%.go$") == nil then
    Notify('not "_test.go" file',"ERROR",{title={"go_test_cmd()","go_run_test.lua"}})
    return nil
  end

  -- 判断当前函数是否 TestXXX. 如果是则 获取 test function name.
  local testfn, mark = go_test_func_name()
  if mark == 0 then
    Notify('not a Test funciton',"ERROR",{title={"go_test_cmd()","go_run_test.lua"}})
    return nil
  end

  -- 获取 _test.go 文件夹路径.
  local dir = vim.fn.expand('%:h')

  -- VVI: 获取 go import path, `cd src/xxx && go list -f '{{.ImportPath}}'`
  local import_path = string.match(vim.fn.system("cd " .. dir .. " && go list -f '{{.ImportPath}}'"), "[%S ]*")
  if vim.v.shell_error ~= 0 then
    Notify(import_path,"ERROR",{title={"go_test_cmd()","go_run_test.lua"}})
    return nil
  end

  -- cmd
  local cmd = ""

  if mark == 1 then
    -- go test -v -timeout 10s -run TestXxx ImportPath
    cmd = 'cd ' .. dir .. " && go test -v -timeout 10s -run " .. testfn .. " " .. import_path
  end

  if mark == 2 then
    -- go test -v -timeout 10s -run ^$ -benchmem -bench BenchmarkXxx ImportPath
    cmd = 'cd ' .. dir .. " && go test -v -timeout 10s -run ^$ -benchmem -bench " .. testfn .. " " .. import_path
  end

  if mark == 3 then
    -- go test -v -run ^$ -fuzztime 10s -fuzz FuzzXxx ImportPath
    cmd = 'cd ' .. dir .. " && go test -v -fuzztime 10s -run ^$ -fuzz " .. testfn .. " " .. import_path
  end

  return cmd
end

--- 通过 Terminal 运行 cmd ---
local function go_test_single_func()
  local cmd = go_test_cmd()
  if cmd == nil then
    return
  end

  -- VVI: 删除之前的 terminal.
  vim.cmd('silent! bw! term://*toggleterm#'..go_term_id)
  local gotest = Terminal:new(vim.tbl_deep_extend('force', go_opts, { cmd = cmd }))
  gotest:toggle()
end
-- -- }}}

--- key mapping ------------------------------------------------------------------------------------
local opt = {noremap = true, buffer = true}

vim.keymap.set('n', '<F5>', go_run, opt)

vim.keymap.set('n', '<F6>', go_test_single_func, opt)
vim.keymap.set('n', '<F18>', go_test_all, opt)  -- <S-F6>
vim.keymap.set('n', '<F30>', go_bench_all, opt)  -- <C-F6>



