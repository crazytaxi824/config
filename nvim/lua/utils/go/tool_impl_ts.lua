-- impl -dir ./src "foo" "IFoo[K,V,R,T,N,M]"

---@return string|nil  interface_name
---@return string[]|nil  type_params
local function ts_get_iface_name_type()
  local node = vim.treesitter.get_node() -- has to be 'type_identifier'
  if not node or node:type() ~= 'type_identifier' then
    return
  end

  local bufnr = vim.api.nvim_get_current_buf()
  local iface_name = vim.treesitter.get_node_text(node, bufnr)
  local typ_params = {}  ---@type string[]

  local next = node:next_sibling()  -- could be 'type_parameter_list' | 'interface_type'
  if not next then
    return
  end

  if next:type() == 'interface_type' then
    return iface_name, typ_params
  end

  if next:type() == 'type_parameter_list' then
    local interface_typ = next:next_sibling()  -- has to be 'interface_type'
    if not interface_typ or interface_typ:type() ~= 'interface_type' then
      return
    end

    local type_param_declar = next:named_children()  -- 'type_parameter_declaration'
    for _, declar in ipairs(type_param_declar) do
      local children = declar:named_children()  -- list [ 'identifier', 'type_constraint' ]
      for _, child in ipairs(children) do
        if child:type() == 'identifier' then
          local id_name = vim.treesitter.get_node_text(child, bufnr)
          table.insert(typ_params, id_name)
        end
      end
    end
  end

  return iface_name, typ_params
end

-- 向 buffer 的最后写入内容
--
---@param data string
---@param bufnr? integer
---@return boolean|nil  write_succeed
local function append_data(data, bufnr)
  if vim.trim(data) == "" then
    return
  end

  -- split string
  local lines = vim.split(data, "\n", { trimempty=false })

  -- 删除 data 最后的空行
  while #lines > 0 and lines[#lines] == '' do
    table.remove(lines, #lines)
  end

  -- 最前面插入一个空行
  table.insert(lines, 1, "")

  -- 从 -1 ~ -1 行, append lines
  vim.api.nvim_buf_set_lines(bufnr or 0, -1, -1, false, lines)
  return true
end


local M = {}

-- `impl -dir src Cat IAnimal`
-- 实现 interface, 需要获取 `<cword>` (光标在 interface 名上)
--
---@param params string
function M.go_impl(params)
  if vim.bo.readonly then
    Notify("this is a readonly file","ERROR")
    return
  end

  local dir = vim.fs.dirname(vim.api.nvim_buf_get_name(0))

  -- 获取 IFoo[T any] 中的 IFoo[T]
  local iface_name, iface_type_params = ts_get_iface_name_type()
  if not iface_name then
    Notify("not a interface", "WARN")
    return
  end

  local iface_type = ""
  if iface_type_params and not vim.tbl_isempty(iface_type_params) then
    iface_type = '[' .. table.concat(iface_type_params, ',') .. ']'
  end

  -- 打印 cmd
  local sh_cmd_print = string.format('impl -dir %s "%s" "%s"', dir, params, iface_name..iface_type)
  vim.notify(sh_cmd_print, vim.log.levels.INFO)

  -- 执行 shell cmd
  local sh_cmd = {'impl', '-dir', dir, params, iface_name..iface_type}
  local result = vim.system(sh_cmd, { text = true }):wait()
  if result.code ~= 0 then
    error(result.stderr ~= '' and result.stderr or result.code)
  end

  -- 写入 data
  if append_data(result.stdout) then
    -- ':normal! G'
    local last_line = vim.api.nvim_buf_line_count(0)
    local curr_win = vim.api.nvim_get_current_win()
    vim.api.nvim_win_set_cursor(curr_win, {last_line, 0})
  end
end

return M
