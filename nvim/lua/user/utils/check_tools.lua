--- 使用 `$ which` 查看插件所需 tools 是否存在

local M = {}

--- lsp tools:
---   {cmd="gopls", lspconfig="gopls", mason="gopls", install="go install golang.org/x/tools/gopls@latest"}
---   {cmd="vscode-json-language-server", lspconfig="jsonls", mason="json-lsp"}
---   {cmd="typescript-language-server", lspconfig="tsserver", mason="typescript-language-server"}
---   {cmd="dlv", mason="delve"}
local function check_tool(tool, notify_opt)
  if not tool.cmd or tool.cmd == '' then
    notify_opt = vim.tbl_deep_extend('force', {timeout=false}, notify_opt)
    Notify("check tool.cmd is missing", "ERROR", notify_opt)
    return
  end

  local msg = {}
  local result = vim.fn.system('which '.. tool.cmd)
  if vim.v.shell_error ~= 0 then
    table.insert(msg, " - " .. tool.cmd)
    if tool.mason then
      table.insert(msg, "   - :MasonInstall " .. tool.mason)
    end
    if tool.install then
      table.insert(msg, "   - " .. tool.install)
    end
  end

  if #msg > 0 then
    return msg
  end
end

M.check = function(tools, notify_opt)
  --- NOTE: "vim.schedule(function() ... end)" is a async function
  vim.schedule(function()
    --- check Mason 是否 loaded, 因为很多 tools 是通过 mason 安装,
    --- 所以需要在 check tools 之前保证 mason 的 runtimepath 加载成功.
    local mason_ok = pcall(require, "mason")
    if not mason_ok then
      Notify("Mason is not loaded", "INFO")
      return
    end

    local result = {"Tools should be installed:"}
    local count = 0
    if #tools > 0 then
      --- list of tools
      for _, tool in ipairs(tools) do
        local msg = check_tool(tool, notify_opt)
        if msg then
          vim.list_extend(result, msg)
          count = count + 1
        end
      end
    else
      --- single tool
      local msg = check_tool(tools, notify_opt)
      if msg then
        vim.list_extend(result, msg)
        count = count + 1
      end
    end

    if count > 0 then
      notify_opt = notify_opt or {}  -- 确保 opt 是 table, 而不是 nil. 否则无法用于 vim.tbl_deep_extend()
      notify_opt = vim.tbl_deep_extend('force', {timeout=false}, notify_opt)
      Notify(result, "WARN", notify_opt)
    end
  end)
end

return M
