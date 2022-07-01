--- NOTE: <cword> under the cursor need to be a function name.
--  gotests -only [funcname] filepath
--     -only   match regex funcname
--     -excl   exclude regex funcname
--     -exported  all exported functions
--     -all
--
--  操作方法: cursor 指向 funciton Name, 使用 Command `:GoTests`
local status_ok, term = pcall(require, "toggleterm.terminal")
if not status_ok then
    return
end
local Terminal = term.Terminal

local function goTests()
  local fp = vim.fn.expand('%')
  local func = vim.fn.expand('<cword>')
  local cmd = 'gotests -only ' .. func .. ' ' .. fp

  local gotests = Terminal:new({ cmd = cmd, hidden = true, direction = "float", close_on_exit = false })
  gotests:toggle()
end

-- command! -buffer -nargs=0 GoTests :lua _GoTests()
vim.api.nvim_buf_create_user_command(
  0,          -- bufnr = 0 表示 current buffer.
  "GoTests",  -- command name
  goTests,    -- 使用 vim.api 方法的好处是可以使用 local lua function
  {bang = true}  -- options: {bang = true, nargs = "+"}
)
