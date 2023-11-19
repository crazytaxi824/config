local nv_ts_status_ok, ts_configs = pcall(require, "nvim-treesitter.configs")
if not nv_ts_status_ok then
  return
end

local nvim_ts_ok, nvim_ts_parsers = pcall(require, "nvim-treesitter.parsers")
if not nvim_ts_ok then
  return
end

--- path to store parsers. VVI: directory must be writeable and must be explicitly added to the runtimepath.
--- 需要在 setup() 中设置 parser_install_dir, 同时将 path 添加到 vim 的 runtimepath 中.
--local treesitter_parsers_path = vim.fn.stdpath('data') .. '/treesitter_parser'
--vim.opt.runtimepath:append(treesitter_parsers_path)

ts_configs.setup {
  --- supported langs, https://github.com/nvim-treesitter/nvim-treesitter#supported-languages
  --- 白名单, ts 启动时自动安装, "all" OR a list of languages.
  --- NOTE: 推荐使用黑名单 (ignore_install), 因为某些语言有多个 parsers, 使用白名单时可能导致遗漏.
  ensure_installed = "all",
  --- ensure_installed = {  ---------------------------------------------------- {{{
  ---   "vim", "vimdoc", "query", "lua",  -- for neovim itself
  ---   "javascript", "typescript", "tsx", "html", "css", "scss",
  ---   "python", "go",
  ---   "markdown", "markdown_inline", "latex",
  ---   "toml", "yaml", "json", "jsonc",
  --- },
  -- -- }}}

  --- 黑名单, ts 启动时不安装. list 中的 lang 在 :TSUpdate & :TSInstall 时安装速度太慢.
  --- ignore 的 lang 可以手动更新 `:TSUpdate rust`, 但是不能使用 `:TSUpdate` 自动更新.
  ignore_install = {"d", "scala", "rust"},  -- compile too slow.

  --- install languages synchronously (only applied to `ensure_installed`)
  sync_install = false,

  --- VVI: opt 加载 nvim-treesitter 时最好使用默认路径. 否则 run=":TSUpdate" 会在本 config 文件加载之前进行安装,
  --- 这时候 nvim-treesitter 并没有读取到 parser_install_dir 导致 parser 被安装在默认位置.
  --- nvim-treesitter 加载 config 后会在多个文件夹中读取到重复的 parser 造成冲突而报错.
  --parser_install_dir = treesitter_parsers_path,  -- path to store parsers.

  --- `:TSModuleInfo` 可以查看 module 设置.
  --- treesitter 自带 modules 设置 -----------------------------------------------------------------
  highlight = {
    --- VVI: 如果使用 lazy 方式启动 highlight, 需要设置为 false,
    --- 提前加载会严重拖慢 nvim 启动/文件打开速度.
    enable = true,

    --- list of language that will be disabled.
    disable = function(lang, buf)
      local disabled_langs = {}  --- vimdoc 即 :help 文档.
      if vim.tbl_contains(disabled_langs, lang) then
        return true
      end

      local max_filesize = 300 * 1024 -- 300 KB
      local ok, stats = pcall(vim.loop.fs_stat, vim.api.nvim_buf_get_name(buf))  -- 获取 filesize
      if ok and stats and stats.size > max_filesize then
        return true
      end
    end,

    --- NOTE: `:help :syn-manual`. nvim-treesitter 会强制将 syntax 设置为 `syntax manual`.
    ---        This will enable the syntax highlighting, but not switch it on automatically.
    ---        `echo g:syntax_on` = 1, 说明 syntax 是开启状态;
    ---        `set syntax?` 返回 'ON', 而不是 'go', 'lua' ..., 说明是 `syntax manual` 设置.
    --- true  - 同时使用 treesitter 和 vim 自带 syntax 颜色, 这时 vim syntax 和 treesitter 的颜色效果叠加.
    ---         eg: syntax 是 bold, 而 treesitter 是 blue, 则最终颜色效果为 blue + bold.
    ---         使用 vim 自带 syntax, 所以 `set syntax?` 返回 'ON'.
    --- false - 只使用 treesitter 颜色, 默认值.
    ---         不使用 vim 自带 syntax, 所以 `set syntax?` 返回 ''.
    additional_vim_regex_highlighting = false,
  },

  --- 作用不大.
  --- incremental_selection = {
  ---   enable = true,
  ---   keymaps = {
  ---     init_selection = "gnn",
  ---     node_incremental = "grn",
  ---     scope_incremental = "grc",
  ---     node_decremental = "grm",
  ---   },
  --- },

  --- NOTE: This is an experimental feature. 使用 'indent_blankline' 代替.
  --- indent = {
  ---   enable = true,
  ---   disable = { "yaml" },  -- 不要自动给 yaml 进行 indent.
  --- },

  --- 启用第三方插件 modules 设置 ------------------------------------------------------------------
  --- "windwp/nvim-ts-autotag", auto close tag <div></div>
  autotag = {
    enable = true,
    filetypes = {
      'html', 'javascript', 'typescript',
      'javascriptreact', 'typescriptreact',
      'svelte', 'vue', 'tsx', 'jsx',
      'rescript', 'xml', 'markdown',
    },
  },
}

--- prompt before install missing parser for languages ---------------------------------------------
vim.api.nvim_create_autocmd("FileType", {
  pattern = {"*"},
  callback = function(params)
    -- local lang = vim.treesitter.language.get_lang(params.match) or ''  -- Don't assign nil to lang
    local lang = nvim_ts_parsers.get_buf_lang(params.buf)

    --- Checks if treesitter parser for language is installed.
    if vim.tbl_contains(nvim_ts_parsers.available_parsers(), lang)  --- 如果 nvim-treesitter 中有该 parser
      and not nvim_ts_parsers.has_parser(lang)  --- 但是该 parser 没有被安装
    then
      --- treesitter lang is not installed.
      Notify("run `:TSInstall " .. lang .. "` to install parser", "INFO", {title = "treesitter install"})
    end
  end,
  desc = "treesitter: Check treesitter parser for filetypes"
})



