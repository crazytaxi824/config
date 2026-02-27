--- coverage 可以用于 run 和 bench, 但是用于 bench 意义不大. 可直接用于 fuzz.out 文件.
--- `go test -cover -run "..." ImportPath`  屏幕上打印 coverage
---
--- `go test -coverprofile cover.out -run "..." ImportPath`  生成 cover.out 文件
--- `go tool cover -html=cover.out -o cover.html && open cover.html`  生成 cover.html 再打开 html 文件
---
--- `go too cover -html=fuzz.out`  可以直接打开 fuzz.out 文件.
---
--- NOTE: cover 可以用于 single_fn, package, project

local M = {}

--- `go tool cover` hook
---
--- @param coverage_dir string (directory)
--- @return MyTermOptsCB
function M.before_run(coverage_dir)
  return function()
    --- mkdir for coverage files
    if not vim.uv.fs_stat(coverage_dir) then
      local result = vim.system({'mkdir', '-p', coverage_dir}, { text = true }):wait()
      if result.code ~= 0 then
        error(result.stderr ~= '' and result.stderr or result.code)
      end
    end
  end
end

--- `go tool cover` hook
---
--- @param cover_out string (filepath)
--- @param cover_html string (filepath)
--- @return MyTermOptsOnExit
function M.on_exit(cover_out, cover_html)
  return function()
    --- convert cover.out -> cover.html
    local result = vim.system({'go', 'tool', 'cover', '-html', cover_out, '-o', cover_html}, {text = true,}):wait()
    if result.code ~= 0 then
      error(result.stderr ~= '' and result.stderr or result.code)
    end

    --- system open cover.html file.
    vim.ui.open(cover_html)
  end
end

return M
