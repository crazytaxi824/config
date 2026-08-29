local M = {}

function M:peek(job)
  -- 显示文字
  ya.preview_widget(job, ui.Line(
    ui.Span(" Preview Disabled "):bg("gray"):fg("black")
  ):area(job.area))
end

function M:seek(job)
end

return M
