local status_ok, conform = pcall(require, "conform")
if not status_ok then
  return
end

local function format_ft()
  --- https://github.com/nvimtools/none-ls.nvim/blob/main/doc/BUILTINS.md#prettier
  local prettier_ft = {
    "javascript", "javascriptreact", "typescript", "typescriptreact",
    "vue", "css", "scss", "less", "html",
    "json", "jsonc", "graphql", "handlebars",
    "yaml", "markdown", "markdown.mdx", -- NOTE: 这些最好不要自动 format.
  }

  local fts = {
    --- VVI: conform will run multiple formatters sequentially
    go = { "goimports", "goimports-reviser" },
    sh = { "shfmt" },
    proto = { "buf" },
    lua = { "stylua" },

    --["*"] = { "codespell" },  -- all filetypes.
    --["_"] = { "trim_whitespace" },  -- filetypes that don't have other formatters configured.
  }

  --- all prettier filetypes
  for _, ft in ipairs(prettier_ft) do
    --- VVI: Use a sub-list to run only the first available formatter
    fts[ft] = { { "prettierd", "prettier" } }
  end

  return fts
end

conform.setup({
  --- DOCS: list of https://github.com/stevearc/conform.nvim#formatters
  formatters_by_ft = format_ft(),
  log_level = vim.log.levels.WARN,

  --- format_on_save = {}, VVI: 不要设置, 否则会覆盖以下 autocmd conform.format({...})
})

--- 修改 default formatter, 也可以用于定义自定义 formatter.
conform.formatters.prettier = {
  prepend_args = function ()
    return {
      "--print-width="..vim.bo.textwidth,  -- The line length where Prettier will try wrap. 默认 80.
      "--single-quote",  -- Use single quotes instead of double quotes. 默认 false.
      "--jsx-single-quote",  -- Use single quotes in JSX. 默认 false.
      "--end-of-line=lf",  -- Which end of line characters to apply. 默认 'lf'.
      -- "--tab-width=2",  -- Number of spaces per indentation level. 默认 2.
    }
  end
}

--- auto format ------------------------------------------------------------------------------------
local g_id
local function auto_format()
  g_id = vim.api.nvim_create_augroup('my_auto_format', {clear=true})
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
        lsp_fallback = true --- VVI: try fallback to lsp format if no formatter.
      })
    end,
    desc = "conform: format file while saving",
  })
end
--- enable auto_format by default.
auto_format()

--- user command -----------------------------------------------------------------------------------
vim.api.nvim_create_user_command("Format", function()
  conform.format(nil, function(err, did_edit)
    if err then
      Notify(err, "ERROR")
      return
    end

    if did_edit then
      vim.cmd('w')  --- save file after format
    end
  end)
end, { bang = true, bar = true })

vim.api.nvim_create_user_command("FormatEnable", function()
  if g_id then
    vim.notify("Auto Format already Enabled")
    return
  end

  auto_format()
  vim.notify("Auto Format Enabled")
end, { bang = true, bar = true })

vim.api.nvim_create_user_command("FormatDisable", function()
  if not g_id then
    vim.notify("Auto Format already Disabled")
    return
  end

  vim.api.nvim_del_augroup_by_id(g_id)
  g_id = nil
  vim.notify("Auto Format Disabled")
end, { bang = true, bar = true })



