--- 使用 `impl` 命令给指定 interface 生成代码, 实现该 interface 的所有方法.
--- <cword> under the cursor need to be a interface name.
--  `impl -dir src Cat IAnimal`
--      - 'Cat'      是我们需要定义的 type, 也就是以下传入的 obj.
--      - 'Animal'   是 interface 的名字, 使用时需要将 cursor 放在 Animal 上.
--  `:call writefile(["foo"], "src/main.go", "a")`  -- 'a': append mode, 将数据写入文件最后.
--
--  操作方法, cursor 指向 interface Name <cword>, 使用 Command `:GoImpl Foo`

local M = {}

M.go_impl = function(arglist)
  if vim.bo.readonly then
    Notify("this is a readonly file","ERROR")
    return
  end

  if #arglist > 1 then
    Notify({"only one args is allowed", "  :GoImpl Foo"},"ERROR")
    return
  end

  local dir = vim.fn.expand('%:h')
  local lastline = vim.fn.line('$')
  local iface_name = vim.fn.expand('<cword>')

  --- 执行 shell cmd
  local sh_cmd = {'impl', '-dir', dir, arglist[1], iface_name}
  local result = vim.system(sh_cmd, { text = true }):wait()
  if result.code ~= 0 then
    error(result.stderr ~= '' and result.stderr or result.code)
  end

  --- 删除 result 最后的空行.
  local content = vim.split(result.stdout, '\n', {trimempty=true})

  --- add 'type Foo struct{}'
  local msg = vim.list_extend({"", "type " .. arglist[1] .. " struct{}", ""}, content)

  --- 写入当前文件
  vim.fn.writefile(msg, vim.fn.bufname(), 'a')  -- 'a' append mode

  --- checktime          刷新 buffer 显示
  --- cursor(lnum. col)  移动 cursor
  --- zz                 移动 cursor 行到屏幕中间
  vim.cmd('checktime | call cursor('.. lastline+2 ..', 1) | normal! zz')
end

return M
