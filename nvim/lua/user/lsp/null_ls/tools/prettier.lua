return {
  --command = "/path/to/prettier",

  --env = { PRETTIERD_DEFAULT_CONFIG = vim.fn.expand("~/xxx/.prettierrc.json") }  -- 环境变量

  --- 常用 args:
  --  --no-editorconfig 不使用 .editorconfig 配置. NOTE: prettier 默认支持 .editorconfig 文件.
  --  --config <path>   Path to a Prettier configuration file (.prettierrc, package.json, prettier.config.js).
  --  --no-config       Do not look for a configuration file.
  extra_args = {
    "--single-quote",      -- Use single quotes instead of double quotes. 默认 false.
    "--jsx-single-quote",  -- Use single quotes in JSX. 默认 false.
    "--print-width=" .. vim.bo.textwidth,  -- The line length where Prettier will try wrap. 默认 80.
    "--end-of-line=lf",  -- Which end of line characters to apply. 默认 'lf'.
    "--tab-width=2",     -- Number of spaces per indentation level. 默认 2.
  },

  disabled_filetypes = { "yaml" },  -- 不需要使用 prettier 格式化.
}
