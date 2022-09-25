--- NOTE: <cword> under the cursor need to be a function name.
--  gotests -only [func_name] filepath, eg: `gotest -only Foo /xxx/src/foo.go`
--     -only   match regex func_name
--     -excl   exclude regex func_name
--     -exported  all exported functions
--     -all
--
--  操作方法: cursor 指向 funciton Name <cword>, 使用 Command `:GoTests`
--
--  VVI: 如果 foo.go 中的函数 func Foo() 已经在 foo_test.go 中有 func TestFoo() 的情况下, gotests 无法生成测试代码.
--       如果 func TestFoo() 在别的文件中, 例如: bar_test.go, 则可以正常生成测试代码.
--       如果 foo_test.go 中没有 func TestFoo() 则可以正常生成测试代码.

local status_ok, term = pcall(require, "toggleterm.terminal")
if not status_ok then
  Notify("toggleterm.terminal cannot be loaded", "ERROR")
  return
end

local gotests = term.Terminal:new({
  count = 2860,
  hidden = true,
  direction = "float",
  close_on_exit = false,
})

local M = {}

M.gotests_cmd_tool = function()
  local fp = vim.fn.expand('%')
  local func = vim.fn.expand('<cword>')

  --- `gotests -only Foo /xxx/src/foo.go`
  local cmd = 'gotests -only ' .. func .. ' ' .. fp

  --- 删除之前的 terminal, 同时终止 job.
  --- NOTE: 这一步放在 cmd 生成的后面, 防止 shutdown() 导致 buffer 意外改变.
  gotests:shutdown()

  --- 设置 cmd
  vim.notify(cmd)
  gotests.cmd = cmd

  --- run cmd
  gotests:open()
end

return M
