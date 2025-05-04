local status_ok, conform = pcall(require, "conform")
if not status_ok then
  return
end

local function format_by_ft()
  --- map { filetype = { formatters ... }}
  local filetype_formatter = {
    --- VVI: conform will run multiple formatters sequentially
    go = { "goimports", "goimports-reviser" },
    --- VVI: Use a sub-list to run only the first available formatter
    sql = { "sql_formatter", "sqlfmt", "sqruff", "sqlfluff", stop_after_first = true },

    sh = { "shfmt" },
    proto = { "buf" },
    lua = { "stylua" },
    --["*"] = { "codespell" }, --- all filetypes
  }

  --- https://github.com/nvimtools/none-ls.nvim/blob/main/doc/BUILTINS.md#prettier
  --- all prettier filetypes
  local prettier_ft = {
    "javascript", "javascriptreact", "typescript", "typescriptreact",
    "vue", "css", "scss", "less", "html",
    "json", "jsonc", "graphql", "handlebars",
    "yaml", "markdown", "markdown.mdx", -- NOTE: 这些最好不要自动 format.
  }
  for _, ft in ipairs(prettier_ft) do
    filetype_formatter[ft] = { "prettier" }
  end

  ---  for Godot's gdscript
  local gd_ft = { 'gd', 'gdscript', 'gdscript3' }
  for _, ft in ipairs(gd_ft) do
    filetype_formatter[ft] = { "gdformat" }
  end

  return filetype_formatter
end

conform.setup({
  --- DOCS: list of https://github.com/stevearc/conform.nvim#formatters
  formatters_by_ft = format_by_ft(),

  --- code 语法错误会被 log, 而不是 log conform 内部错误.
  log_level = vim.log.levels.OFF,

  --- code 语法错误时在 command area 打印错误内容.
  notify_on_error = false,

  --- VVI: 不要设置, 否则会覆盖以下 autocmd conform.format({...})
  -- format_on_save = {
  --   --- These options will be passed to conform.format()
  --   timeout_ms = 500,
  --   lsp_format = "fallback",
  -- },
})

--- Custome formatter ------------------------------------------------------------------------------
--- 修改 default formatter, 也可以用于定义自定义 formatter.
conform.formatters.prettier = function(bufnr)
  return {
    prepend_args = {
      "--print-width="..vim.bo.textwidth,  -- The line length where Prettier will try wrap. 默认 80.
      "--single-quote",  -- Use single quotes instead of double quotes. 默认 false.
      "--jsx-single-quote",  -- Use single quotes in JSX. 默认 false.
      "--end-of-line=lf",  -- Which end of line characters to apply. 默认 'lf'.
      -- "--tab-width=2",  -- Number of spaces per indentation level. 默认 2.
    }
  }
end

--- auto format ------------------------------------------------------------------------------------
local function auto_format()
  local g_id = vim.api.nvim_create_augroup('my_auto_format', {clear=true})
  vim.api.nvim_create_autocmd("BufWritePre", {
    group = g_id,
    pattern = {"*"},
    callback = function(params)
      --- NOTE: exclude some of the filetypes to auto format
      local exclude_auto_format_filtypes = { "markdown", "yaml", "lua", "jsonc" }
      if vim.tbl_contains(exclude_auto_format_filtypes, vim.bo[params.buf].filetype) then
        return
      end

      conform.format({
        bufnr = params.buf,
        timeout_ms = 3000,
        lsp_format = "fallback", --- VVI: try fallback to lsp format if no formatter.
      })
    end,
    desc = "conform: format file while saving",
  })
  return g_id
end

--- enable auto_format by default.
local autoformat_group_id = auto_format()

--- user command -----------------------------------------------------------------------------------
--- 手动 format file
vim.api.nvim_create_user_command("Format", function()
  conform.format({
    timeout_ms = 3000,
    lsp_format = "fallback", --- VVI: try fallback to lsp format if no formatter.
  }, function(err, did_edit)
    if err then
      Notify(err, "ERROR")
      return
    end

    if did_edit then
      vim.cmd.write()  --- save file after format
    end
  end)
end, { bang = true, bar = true })

vim.api.nvim_create_user_command("ToggleAutoFormat", function()
  if autoformat_group_id > 0 then
    vim.api.nvim_del_augroup_by_id(autoformat_group_id)
    autoformat_group_id = 0
    vim.notify("Auto Format: Disabled")
  else
    auto_format()
    vim.notify("Auto Format: Enabled")
  end
end, { bang = true, bar = true })



