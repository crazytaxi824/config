--- 使用 `gotests` 命令给指定 function 自动生成测试代码.
--- 操作方法: cursor 指向 function Name <cword>, 使用 Command `:GoTests`
--- <cword> under the cursor need to be a function name.
--  gotests -only [func_name] filepath, eg: `gotest -only Foo /xxx/src/foo.go`
--     -only   match regex func_name
--     -excl   exclude regex func_name
--     -exported  all exported functions
--     -all
--     -w  不需要指定 output filepath, 自动生成文件 [file]_test.go
--
--  VVI: 如果 foo.go 中的函数 func Foo() 已经在 foo_test.go 中有 func TestFoo() 的情况下, gotests 无法生成测试代码.
--       如果 func TestFoo() 在别的文件中, 例如: bar_test.go, 则可以正常生成测试代码.
--       如果 foo_test.go 中没有 func TestFoo() 则可以正常生成测试代码.

local M = {}

M.gotests_cmd_tool = function()
  local fp = vim.fn.bufname()  -- current filepath
  local func = vim.fn.expand('<cword>')

  --- `gotests -w -only Foo /xxx/src/foo.go`
  --- `-w` 会将写入 <filename>_test.go 文件. 如果该文件不存在则会自动创建; 如果该文件存在则将内容 append 到文件中.
  local cmd = {'gotests', '-w', '-only', func, fp}
  local result = vim.system(cmd, { text = true }):wait()
  if result.code ~= 0 then
    error(result.stderr ~= '' and result.stderr or result.code)
  end

  --- 显示 `gotests` 返回的内容.
  vim.notify(result.stdout)

  --- NOTE: 成功后会在 stdout 中返回 "Generated Test_XXX".
  --- 无法生成会在 stdout 中返回 "No tests generated for xxx".
  if not string.match(result.stdout, "Generated Test_") then
    return
  end

  --- 执行完成后打开 <filepath>_test.go file.
  local test_fp = vim.fn.fnamemodify(fp, ':r') .. '_test.go'
  if vim.fn.filereadable(test_fp) == 1 then
    vim.cmd.edit(test_fp)
  end
end

return M
