--- NOTE: <cword> under the cursor need to be a interface name.
--  `impl -dir src Cat Animal`
--      - 'Cat'      是我们需要定义的 type, 也就是以下传入的 obj.
--      - 'Animal'   是 interface 的名字, 使用时需要将 cursor 放在 Animal 上.
--  `:call writefile(["foo"], "src/main.go", "a")`  -- 'a': append mode, 将数据写入文件最后.
--
--  操作方法, cursor 指向 interface Name, 使用 Command `:GoImpl Foo`
local function go_impl(arglist)
  if vim.bo.readonly then
    Notify("this is a readonly file","ERROR")
    return
  end

  if #arglist > 1 then
    Notify("only one args is allowed","ERROR")
    return
  end

  local dir = vim.fn.expand('%:h')
  local lastline = vim.fn.line('$')
  local iface = vim.fn.expand('<cword>')

  --- 执行 shell cmd
  local sh_cmd = 'impl -dir ' .. dir .. ' ' .. arglist[1] .. ' ' .. iface
  print(sh_cmd)
  local result = vim.fn.system(sh_cmd)

  --- 判断结果是否错误
  if vim.v.shell_error ~= 0 then
    Notify(result,"ERROR")
    return
  end

  --- 写入当前文件
  local msg = vim.list_extend({""}, vim.split(result, '\n'))
  vim.fn.writefile(msg, vim.fn.expand('%'), 'a')

  --- checktime          刷新 buffer 显示
  --- cursor(lnum. col)  移动 cursor
  --- zz                 移动 cursor 行到屏幕中间
  vim.cmd('checktime | call cursor('.. lastline+2 ..', 1) | normal! zz')
end

--- command! -buffer -nargs=1 GoImpl :lua _GoImpl(<f-args>)
vim.api.nvim_buf_create_user_command(
  0,
  "GoImpl",
  function(params)
    go_impl(params.fargs)
  end,
  {bang=true, nargs="+"}
)



