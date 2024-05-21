--- go test -cover -coverprofile cover.out ...
--- go tool cover -html=cover.out -o cover.html && open cover.html

local M = {}

M.before_run = function(coverage_dir)
  return function()
    --- mkdir for coverage files
    if vim.fn.isdirectory(coverage_dir) == 0 then
      local result = vim.system({'mkdir', '-p', coverage_dir}, { text = true }):wait()
      if result.code ~= 0 then
        error(result.stderr ~= '' and result.stderr or result.code)
      end
    end
  end
end

M.on_exit = function(cover_out, cover_html)
  return function()
    --- convert cover.out -> cover.html
    local result = vim.system({'go', 'tool', 'cover', '-html', cover_out, '-o', cover_html,}, {text = true,}):wait()
    if result.code ~= 0 then
      error(result.stderr ~= '' and result.stderr or result.code)
    end

    --- system open cover.html file.
    vim.ui.open(cover_html)
  end
end

return M

