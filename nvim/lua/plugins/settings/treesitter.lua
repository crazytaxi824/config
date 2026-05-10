local nv_ts_status_ok, ts = pcall(require, "nvim-treesitter")
if not nv_ts_status_ok then
  return
end

--- `:help nvim-treesitter-api`
ts.setup({
  -- Directory to install parsers and queries. (prepended to `runtimepath`)
  -- install_dir = vim.fn.stdpath('data') .. '/site'
})

--- DOCS: 安装 parser
--- `:TSInstall all` 安装所有 langs 的 parser
--- `:TSInstall stable` 安装所有 stable parser
local auto_install_langs = {
  "lua", "query", "c", "vim", "vimdoc", "markdown", "markdown_inline",  -- up to data Highlight
  "comment", "editorconfig",
  "latex", "mermaid",  -- for `markdown`
  "git_config", "git_rebase", "gitattributes", "gitcommit", "gitignore", "diff",  -- `git`
  "json", "json5", "toml", "yaml", "csv", "xml", "regex", "proto", "dockerfile",  -- common filetypes
  "ssh_config",
  "sql",
}

vim.schedule(function ()
  ts.install(auto_install_langs, { max_jobs = 1 })
end)


--- prompt before install missing parser for languages ---------------------------------------------
vim.api.nvim_create_autocmd("FileType", {
  pattern = {"*"},
  callback = function(params)
    local lang = vim.treesitter.language.get_lang(params.match)
    if not lang then
      return
    end

    --- buffer 已经有 parser 了
    local parser = vim.treesitter.get_parser(params.buf)
    if parser and parser:lang() == lang then
      vim.treesitter.start()  -- NOTE: enable Highlight
      return
    end

    --- buffer 没有对应 installed parser 则提醒安装
    local available_parsers = ts.get_available()
    if vim.tbl_contains(available_parsers, lang) then
      Notify("run `:TSInstall " .. lang .. "` to install parser", "INFO", {title = "treesitter install"})
    end
  end,
  desc = "treesitter: enable Highlight & check treesitter parser for filetypes"
})



