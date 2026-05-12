-- https://yazi-rs.github.io/docs/tips/#symlink-in-status
-- https://yazi-rs.github.io/docs/plugins/types

-- quote filepath, avoid space in filepath
local function shellescape(path)
  return "'" .. path:gsub("'", "'\\''") .. "'"
end

-- Show symlink in status bar
Status:children_add(function()
  local h = cx.active.current.hovered
  if h and h.link_to then
    return " -> " .. tostring(h.link_to)
  else
    return ""
  end
end, 3300, Status.LEFT)

-- Show `mime` in status bar
Status:children_add(function()
  local h = cx.active.current.hovered
  if h then
    local handle = io.popen("file -b --mime-type " .. shellescape(tostring(h.url)))
    local result = handle:read("*l")
    handle:close()

    return ui.Line(
      ui.Span(string.format("[%s] ", result)):fg("blue")
    )
  end
end, 100, Status.RIGHT)



