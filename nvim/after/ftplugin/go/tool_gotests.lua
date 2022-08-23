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
    return
end
local Terminal = term.Terminal

local function gotests_cmd_tool()
  local fp = vim.fn.expand('%')
  local func = vim.fn.expand('<cword>')
  local cmd = 'gotests -only ' .. func .. ' ' .. fp

  --- `gotest -only Foo /xxx/src/foo.go`
  print(cmd)

  local gotests = Terminal:new({ cmd = cmd, hidden = true, direction = "float", close_on_exit = false })
  gotests:toggle()
end

-- command! -buffer -nargs=0 GoTests :lua _GoTests()
vim.api.nvim_buf_create_user_command(
  0,          -- bufnr = 0 表示 current buffer.
  "GoTests",  -- command name
  gotests_cmd_tool,    -- 使用 vim.api 方法的好处是可以使用 local lua function
  {bang = true}  -- options: {bang = true, nargs = "+"}
)



