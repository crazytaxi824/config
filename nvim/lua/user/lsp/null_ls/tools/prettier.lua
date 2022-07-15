return {
  --command = "/path/to/prettier",

  --env = { PRETTIERD_DEFAULT_CONFIG = vim.fn.expand("~/xxx/.prettierrc.json") }  -- 环境变量

  --- NOTE: prettier 默认支持 .editorconfig 文件.
  extra_args = { "--single-quote", "--jsx-single-quote",
    "--print-width=" .. vim.bo.textwidth,  -- 和 vim textwidth 相同.
    "--end-of-line=lf", "--tab-width=2" },

  disabled_filetypes = { "yaml" },  -- 不需要使用 prettier 格式化.
}
