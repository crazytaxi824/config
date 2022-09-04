--- require vim.health. `:help health-dev`
local health = require("health")

local M = {}

M.check = function()
  health.report_start("start title")
  health.report_info("this is a INFO test message.\n second line.")    -- no highlight
  health.report_ok("this is a OK test message.")        -- green
  -- health.report_warn("warn")    -- orange
  -- health.report_error("error")  -- red
end

return M
