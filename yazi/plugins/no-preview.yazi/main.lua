local M = {}

function M:peek(job)
  -- 强制显示一段文字，看是否有反应
  ya.preview_widget(job, ui.Line(
    ui.Span(" Preview Disabled "):bg("gray"):fg("black")
  ):area(job.area))
end

function M:seek(job)
end

return M
