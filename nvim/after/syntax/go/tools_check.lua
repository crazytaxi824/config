--- check tools ----------------
--- tools: goimports, gomodifytags, gotests, impl
--      go install golang.org/x/tools/cmd/goimports@latest
--      go install github.com/fatih/gomodifytags@latest
--      go install github.com/cweill/gotests/gotests@latest
--      go install github.com/josharian/impl@latest
local notify_status_ok, notify = pcall(require, "notify")
if not notify_status_ok then
  return
end

local gotools = {
  goimports = "   go install golang.org/x/tools/cmd/goimports@latest",  -- null-ls
  gomodifytags = "go install github.com/fatih/gomodifytags@latest",
  gotests = "     go install github.com/cweill/gotests/gotests@latest",
  impl = "        go install github.com/josharian/impl@latest",
  dlv = "         go install github.com/go-delve/delve/cmd/dlv@latest", -- vimspector
}

local result = {"These Tools should be in the $PATH"}
local count = 0
for tool, install in pairs(gotools) do
  vim.fn.system('which '.. tool)
  if vim.v.shell_error ~= 0 then
    table.insert(result, tool .. ": " .. install)
    count = count + 1
  end
end

if count > 0 then
  notify.notify(result, "WARN", {title = {"GoTools missing", "go_tools.lua"}, timeout = false})
end



