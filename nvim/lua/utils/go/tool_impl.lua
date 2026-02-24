--- 使用 `impl` 命令给指定 interface 生成代码, 实现该 interface 的所有方法.
--- <cword> under the cursor need to be a interface name.
--  `impl -dir src Cat IAnimal`
--      - 'Cat'      是我们需要定义的 type, 也就是以下传入的 obj.
--      - 'IAnimal'   是 interface 的名字, NOTE: 使用时需要将 cursor 放在 IAnimal 上 <cword>.
--  `:call writefile(["foo"], "src/main.go", "a")`  -- 'a': append mode, 将数据写入文件最后.
--
--  操作方法, cursor 指向 interface Name <cword>, 使用 Command `:GoImpl Foo`

local M = {}

--- `impl -dir src Cat IAnimal`
--- 实现 interface, 需要获取 `<cword>` (光标在 interface 名上)
---
--- @param arglist string[]
function M.go_impl(arglist)
  if vim.bo.readonly then
    Notify("this is a readonly file","ERROR")
    return
  end

  if #arglist > 1 then
    Notify({"only one args is allowed", "  :GoImpl Foo"},"ERROR")
    return
  end

  local dir = vim.fs.dirname(vim.api.nvim_buf_get_name(0))
  local iface_name = vim.fn.expand('<cword>')

  --- 打印 cmd
  local sh_cmd = {'impl', '-dir', dir, arglist[1], iface_name}
  vim.notify(table.concat(sh_cmd, ' '), vim.log.levels.INFO)

  --- 执行 shell cmd
  local result = vim.system(sh_cmd, { text = true }):wait()
  if result.code ~= 0 then
    error(result.stderr ~= '' and result.stderr or result.code)
  end

  --- 删除 result 最后的空行.
  local content = vim.split(result.stdout, '\n', {trimempty=true})

  --- add 'type Foo struct{}'
  local msg = vim.list_extend({"", "type " .. arglist[1] .. " struct{}", ""}, content)

  --- append 写入当前文件
  vim.api.nvim_buf_set_lines(0, -1, -1, false, msg)

  --- ':normal! G'
  vim.cmd.normal({ args = {'G'}, bang=true })
end

return M
