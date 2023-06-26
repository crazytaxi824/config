--- 使用 `gotests` 命令给指定 function 自动生成测试代码.
--- 操作方法: cursor 指向 function Name <cword>, 使用 Command `:GoTests`
--- <cword> under the cursor need to be a function name.
--  gotests -only [func_name] filepath, eg: `gotest -only Foo /xxx/src/foo.go`
--     -only   match regex func_name
--     -excl   exclude regex func_name
--     -exported  all exported functions
--     -all
--
--  VVI: 如果 foo.go 中的函数 func Foo() 已经在 foo_test.go 中有 func TestFoo() 的情况下, gotests 无法生成测试代码.
--       如果 func TestFoo() 在别的文件中, 例如: bar_test.go, 则可以正常生成测试代码.
--       如果 foo_test.go 中没有 func TestFoo() 则可以正常生成测试代码.

local M = {}

M.gotests_cmd_tool = function()
  local fp = vim.fn.expand('%')
  local func = vim.fn.expand('<cword>')

  --- `gotests -only Foo /xxx/src/foo.go`
  local cmd = 'gotests -only ' .. func .. ' ' .. fp

  require("user.utils.term").float.run(cmd)
end

return M
