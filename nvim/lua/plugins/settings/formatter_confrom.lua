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
    --- VVI: Conform will run multiple formatters sequentially
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
  log_level = vim.log.levels.DEBUG,
  --- format_on_save = {}, VVI: 不要设置, 否则会覆盖以下 autocmd conform.format({...})
})

vim.api.nvim_create_autocmd("BufWritePre", {
  pattern = {"*"},
  callback = function(params)
    --- NOTE: exclude some of the filetypes to auto format
    local exclude_auto_format_filtypes = { "markdown", "yaml", "lua" }
    if vim.tbl_contains(exclude_auto_format_filtypes, vim.bo[params.buf].filetype) then
      return
    end

    conform.format({
      bufnr = params.buf,
      timeout_ms = 3000,
      lsp_fallback = true --- VVI: try fallback to lsp format if no formatter.
    })
  end,
  desc = "Conform: format file while saving",
})

--- user command: Format
vim.api.nvim_create_user_command("Format", function() conform.format() end, { bang = true, bar = true })
