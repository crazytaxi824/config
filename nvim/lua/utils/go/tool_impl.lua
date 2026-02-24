--- 使用 `impl` 命令给指定 interface 生成代码, 实现该 interface 的所有方法.
--- <cword> under the cursor need to be a interface name.
--  `impl -dir src Cat IAnimal`
--      - 'Cat'      是我们需要定义的 type, 也就是以下传入的 obj.
--      - 'IAnimal'   是 interface 的名字, NOTE: 使用时需要将 cursor 放在 IAnimal 上 <cword>.
--  `:call writefile(["foo"], "src/main.go", "a")`  -- 'a': append mode, 将数据写入文件最后.
--
--  操作方法, cursor 指向 interface Name <cword>, 使用 Command `:GoImpl Foo`


--- 从 type IFoo[K string, V int, R any, T interface{ int | int64 }, N Bar[M], M int] interface {}
--- 中获取 IFoo[K,V,R,T,N,M]
---
--- @param line string
--- @return string|nil iface_name
--- @return string iface_type
local function get_iface_name_type(line)
  -- 核心模式串说明：
  -- [%w_]+   匹配字母或数字 IFoo
  local name, rest = line:match("^type%s+([%w_]+)%s*(.*)%s+interface")
  if not name then
    return nil, ""
  end

  -- %b[]  匹配对称的方括号及其内部内容 [K string, V int, R any, T interface{ int | int64 }]
  local generics = rest:match("(%b[])")
  if not generics then
    return name, ""
  end

  local params = {}

  -- 去掉首尾的 [ 和 ]
  local inner = generics:sub(2, -2)

  -- 匹配每一个参数对. 逻辑: 匹配非逗号的内容, 并取其中的第一个单词
  for var in inner:gmatch("%s*([%w_]+)[^,]*") do
    if var then table.insert(params, var) end
  end

  if #params > 0 then
    return name, "[" .. table.concat(params, ",") .. "]"
  end

  return name, ""
end

local M = {}

--- `impl -dir src Cat IAnimal`
--- 实现 interface, 需要获取 `<cword>` (光标在 interface 名上)
---
--- @param params string
function M.go_impl(params)
  if vim.bo.readonly then
    Notify("this is a readonly file","ERROR")
    return
  end

  local dir = vim.fs.dirname(vim.api.nvim_buf_get_name(0))
  local iface_line = vim.api.nvim_get_current_line()

  --- 检查 interface name 是否正确
  if not iface_line then
    Notify("not a interface", "WARN")
    return
  end

  --- 获取 IFoo[T any] 中的 IFoo[T]
  local iface_name, iface_type = get_iface_name_type(iface_line)
  if not iface_name then
    Notify("not a interface", "WARN")
    return
  end

  --- 打印 cmd
  local sh_cmd_print = {'impl', '-dir', dir,'"'..params..iface_type..'"', '"'..iface_name..iface_type..'"'}
  vim.notify(table.concat(sh_cmd_print, ' '), vim.log.levels.INFO)

  --- 执行 shell cmd
  local sh_cmd = {'impl', '-dir', dir, params..iface_type, iface_name..iface_type}
  local result = vim.system(sh_cmd, { text = true }):wait()
  if result.code ~= 0 then
    error(result.stderr ~= '' and result.stderr or result.code)
  end

  --- 删除 result 最后的空行.
  local content = vim.split(result.stdout, '\n', {trimempty=true})
  table.insert(content, 1, "")  -- 最前面插入一个空行

  --- append 写入当前文件
  vim.api.nvim_buf_set_lines(0, -1, -1, false, content)

  --- ':normal! G'
  vim.cmd.normal({ args = {'G'}, bang=true })
end

return M
