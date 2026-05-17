--- coverage 可以用于 run 和 bench, 但是用于 bench 意义不大. 可直接用于 fuzz.out 文件.
--- `go test -cover -run "..." ImportPath`  屏幕上打印 coverage
---
--- `go test -coverprofile cover.out -run "..." ImportPath`  生成 cover.out 文件
--- `go tool cover -html=cover.out -o cover.html && open cover.html`  生成 cover.html 再打开 html 文件
---
--- `go too cover -html=fuzz.out`  可以直接打开 fuzz.out 文件.
---
--- NOTE: cover 可以用于 single_fn, package, project

local utils = require("utils.go.deps.utils")


--- go test cmd
local go_test = {'go', 'test', '-count=1', '-v'}


--- `go tool cover` hook
---
--- @param cover_out string (filepath)
--- @param cover_html string (filepath)
--- @return MyTermOnExit
local function on_exit(cover_out, cover_html)
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


--- @type GoTestFlagDict
local M = {
  list = {"cover", "coverprofile"},

  flags = {
    cover = {
      desc = 'Coverage print on screen',

      term_opts = function(opts)
        --- @type string[]
        local cmd = vim.iter({go_test, '-cover', utils.mode_flags(opts)}):flatten():totable()
        return cmd, {
          cwd = opts.go_list.Root,
        }
      end
    },

    coverprofile = {
      desc = 'Coverage profile (detail)',

      term_opts = function(opts)
        --- NOTE: 使用 '-coverprofile' 生成的 'cover.out' 文件必须在 go workspace 中, 否则无法进行分析.
        --- '-coverprofile /xxx/cover.out' 最好是是绝对路径, 避免和 '-outputdir' 冲突.
        local coverage_dir = opts.go_list.Root .. '/coverage/'
        --- mkdir for coverage files
        if not vim.uv.fs_stat(coverage_dir) then
          local result = vim.system({'mkdir', '-p', coverage_dir}, { text = true }):wait()
          if result.code ~= 0 then
            error(result.stderr ~= '' and result.stderr or result.code)
          end
        end

        --- NOTE: 如果是 `go test -coverprofile ./...` , go_list 中需要传递 project 属性, 用于指定文件名.
        --- 后半部分是将 filepath 中的 / 替换成 %.
        local cover_filename = opts.project or string.gsub(opts.go_list.ImportPath, '/', '%%')
        local cover_out = coverage_dir .. cover_filename .. '_cover.out'
        local cover_html = coverage_dir .. cover_filename .. '_cover.html'

        --- @type string[]
        local cmd = vim.iter({go_test, '-coverprofile', cover_out, utils.mode_flags(opts)}):flatten():totable()
        return cmd, {
          cwd = opts.go_list.Root,
          on_exit = on_exit(cover_out, cover_html),
        }
      end
    },
  }
}

return M
