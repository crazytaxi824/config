--- 在 null-ls 中设置 golangci-lint
--- https://github.com/jose-elias-alvarez/null-ls.nvim/blob/main/doc/HELPERS.md

local log = require("null-ls.logger")
local c = require("null-ls.config")

return {
  --command = "path/to/golangci-lint",
  --filetypes = { "go" },  -- 只对 go 文件生效.

  --- golangci-lint 配置文件位置自动查找 --------------------------------------- {{{
  --- DOCS: https://golangci-lint.run/docs/configuration/file/
  --- golangci-lint 会自动寻找 '.golangci.yml', '.golangci.yaml', '.golangci.toml', '.golangci.json'.
  --- GolangCI-Lint also searches for config files in all directories from the directory of
  --- the first analyzed path up to the root.
  --- }}}
  --extra_args = { '--config', vim.uv.cwd() .. "/.golangci.yml"},

  ---  可以通过设置 setup() 中的 debug = true, 打开 `:NullLsLog` 查看命令行默认参数.
  args = function(params)
    local golangci_args = {
      "run",

      --- https://github.com/jose-elias-alvarez/null-ls.nvim/blob/main/doc/HELPERS.md#args
      --- NOTE: 不能使用 $FILENAME lint 单个文件. 会导致其他 package 中定义的 var 无法被 golangci 找到.
      --- 如果缺省该设置则会 lint 整个 project.
      "$DIRNAME",

      "--fix=false",  -- 不要自动 fix code.
      "--output.json.path=stdout",  -- 使用 json 格式输出.
      "--show-stats=false",  -- 不显示最后的 (N) issues, 否则 null-ls parse json 会报错.

      --- Path prefix to add to output.
      --- VVI: 默认情况下运行 golangci-lint run 时 output 中 filename 是一个相对 pwd/cwd 的相对文件路径.
      --- null-ls 中已经处理了 cwd 和 golangci-lint output 中 filename 的 filepath 拼接, 所以这里不要自己设置 --path-prefix.
      -- "--path-prefix", "$DIRNAME",
    }

    return golangci_args
  end,

  --- 修改 severity
  --- https://github.com/nvimtools/none-ls.nvim/blob/main/lua/null-ls/builtins/diagnostics/golangci_lint.lua
  on_output = function(params)
    local diags = {}

    --- golangci_lint 配置错误
    if params.output["Report"] and params.output["Report"]["Error"] then
      log:warn(params.output["Report"]["Error"])  -- NullLsLog 打印
      vim.notify(params.output["Report"]["Error"], vim.log.levels.WARN)
      return diags
    end

    --- parse issues
    local issues = params.output["Issues"]
    if type(issues) == "table" then
      for _, d in ipairs(issues) do
        -- prepend cwd to filename to get absolute path unless
        local filename = d.Pos.Filename  -- Pos.Filename is absolute path
        if filename:sub(1, #params.cwd) ~= params.cwd then
          filename = vim.fs.joinpath(params.cwd, d.Pos.Filename)
        end

        --- 自定义 severity 显示
        local severity_lvl = vim.diagnostic.severity.WARN
        local issues_severity = string.lower(d["Severity"])
        if issues_severity == "" then
          severity_lvl = c.get().fallback_severity
        elseif issues_severity == "hint" then
          severity_lvl = vim.diagnostic.severity.HINT
        elseif issues_severity == "info" then
          severity_lvl = vim.diagnostic.severity.INFO
        elseif issues_severity == "warn" or issues_severity == "warning" then
          severity_lvl = vim.diagnostic.severity.WARN
        else
          severity_lvl = vim.diagnostic.severity.ERROR
        end

        table.insert(diags, {
          source = string.format("golangci-lint: %s", d.FromLinter),
          row = d.Pos.Line,
          col = d.Pos.Column,
          message = d.Text,
          severity = severity_lvl,
          filename = filename,
        })
      end
    end
    return diags
  end,
}
