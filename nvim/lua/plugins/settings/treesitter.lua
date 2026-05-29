local nv_ts_status_ok, ts = pcall(require, "nvim-treesitter")
if not nv_ts_status_ok then
  return
end

-- `:help nvim-treesitter-api`
ts.setup({
  -- Directory to install parsers and queries. (prepended to `runtimepath`)
  -- install_dir = vim.fs.joinpath(vim.fn.stdpath('data'), 'site')
})


-- 自动安装 parser
-- `:TSInstall all` 安装所有 langs 的 parser
-- `:TSInstall stable` 安装所有 stable parser
-- local auto_install_langs = {
--   "lua", "query", "c", "vim", "vimdoc", "markdown", "markdown_inline",  -- up to data Highlight
--   "comment", "editorconfig",
--   "latex", "mermaid",  -- for `markdown`
--   "git_config", "git_rebase", "gitattributes", "gitignore", "diff",  -- `git`
--   "json", "json5", "toml", "yaml", "csv", "xml", "regex", "proto", "dockerfile",  -- common filetypes
--   "ssh_config",
--   "sql",
-- }
--
-- vim.schedule(function ()
--   -- VVI: 必须先安装 tree-sitter-cli, nvim-treesitter 才能 install languages.
--   if vim.fn.executable("tree-sitter") ~= 1 then
--     vim.notify("need to install 'tree-sitter-cli' before nvim-treesitter install languages", vim.log.levels.WARN)
--     return
--   end
--   ts.install(auto_install_langs, { max_jobs = 4 })
-- end)


-- prompt before install missing parser for languages ---------------------------------------------

---@type string[]
local available = {}

vim.api.nvim_create_autocmd("FileType", {
  callback = function(args)
    local lang = vim.treesitter.language.get_lang(args.match)
    if not lang then
      return
    end

    -- VVI: enable Highlight, `:help vim.treesitter.start()`
    local parser = vim.treesitter.get_parser(args.buf)
    if parser and parser:lang() == lang then
      vim.treesitter.start()
    end

    -- 提醒安装对应的 nvim-treesitter parser
    local installed = ts.get_installed()
    if vim.tbl_isempty(available) then available = ts.get_available() end

    if not vim.tbl_contains(installed, lang) and vim.tbl_contains(available, lang) then
      -- VVI: 必须先安装 tree-sitter-cli, nvim-treesitter 才能 install languages.
      if vim.fn.executable("tree-sitter") == 0 then
        vim.notify("need to install 'tree-sitter-cli' before nvim-treesitter install languages", vim.log.levels.WARN)
        return
      end

      vim.notify(string.format("run `:TSInstall %s` to install parser", lang), vim.log.levels.WARN)
    end
  end,
  desc = "treesitter: enable Highlight & check treesitter parser for filetypes"
})



