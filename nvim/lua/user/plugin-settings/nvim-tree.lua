local status_ok, nvim_tree = pcall(require, "nvim-tree")
if not status_ok then
  return
end

nvim_tree.setup {
  auto_reload_on_write = true,  -- VVI: `:w` 时刷新 nvim-tree.
  disable_netrw = false,   -- completely disable netrw
  hijack_cursor = false,   -- keeps the cursor on the first letter of the filename
  hijack_netrw = true,     -- hijack netrw windows (overriden if |disable_netrw| is `true`)
  hijack_directories = {   -- hijacks new directory buffers when they are opened (`:e dir`)
    enable = true,
    auto_open = true,
  },
  hijack_unnamed_buffer_when_opening = false,
  ignore_buffer_on_setup = false,
  open_on_setup = false,      -- 打开 dir 时自动开启 nvimtree
  open_on_setup_file = false, -- 打开 file 时自动开启 nvimtree
  open_on_tab = false,
  sort_by = "name",
  update_cwd = false,
  view = {
    width = 30,
    height = 30,
    side = "left",
    preserve_window_proportions = false,
    number = false,          -- 显示 line number
    relativenumber = false,  -- 显示 relative number
    signcolumn = "yes",      -- 显示 signcolumn
    mappings = {
      custom_only = true,  -- 只使用 custom key mapping
      list = {   -- user mappings go here
        { key = {"<CR>", "e"},   action = "edit" },
        { key = "<C-v>",         action = "vsplit" },  -- vsplit edit
        { key = "<C-x>",         action = "split" },
        { key = "<C-o>",         action = "system_open" },
        { key = "a",             action = "create" },
        { key = "d",             action = "remove" },
        { key = "R",             action = "rename" },  -- 类似 mv
        { key = "r",             action = "refresh" },
        { key = "y",             action = "copy_absolute_path" },
        { key = "W",             action = "collapse_all" },
        { key = "I",             action = "toggle_git_ignored" },
        { key = "H",             action = "toggle_dotfiles" },
        { key = "q",             action = "close" },
        { key = "?",             action = "toggle_help" },
      },
    },
  },
  renderer = {
    highlight_git = false,
    highlight_opened_files = "all",  -- NOTE: "none" | "icon" | "name" | "all"
    indent_markers = {
      enable = true,
      icons = {
        corner = "└ ",
        edge = "│ ",
        none = "  ",
      },
    },
    icons = {
      webdev_colors = false,
      symlink_arrow = " → ",
      show = {
        git = false,
        folder = true, -- VVI: 只显示 folder icon
        file = false,
        folder_arrow = false,
      },
      glyphs = {
        default = '',
        symlink = '',
        folder = {
          default = '▶︎',
          open = '▽',
          empty = '-',
          empty_open = '-',
          symlink = '',
          symlink_open = ''
        },
      },
    },
    special_files = {
      "Cargo.toml", "Makefile", "MAKEFILE", "README.md", "readme.md",
      ".editorconfig", ".gitignore", "go.mod", "go.sum",
      "package-lock.json", "package.json", "tsconfig.json"
    },
  },
  update_focused_file = {
    enable = false,
    update_cwd = false,
    ignore_list = {},
  },
  ignore_ft_on_setup = {},
  system_open = {
    cmd = nil,  -- Mac 中可以改为 "open"
    args = {},
  },
  diagnostics = {    -- VVI: 显示 vim diagnostics result
    enable = true,
    show_on_dirs = true,
    icons = {
      hint    = "⚑ ",
      info    = "𝖎 ",
      warning = "⚠️ ",
      error   = "❌",
    },
  },
  filters = {
    dotfiles = false,  -- true:不显示隐藏文件, false:显示隐藏文件.
    custom = { '^\\.DS_Store$', '^\\.git$', '.*\\.swp$' },    -- 不显示指定文件
    exclude = {},
  },
  git = {
    enable = false, -- 不开启
    ignore = true,  -- ignore gitignore files
    timeout = 400,
  },
  actions = {
    use_system_clipboard = true,
    change_dir = {
      enable = true,
      global = false,
    },
    open_file = {
      quit_on_open = false,  -- VVI: 打开文件后自动关闭 Nvimtree
      resize_window = true,  -- VVI: 重新渲染 nvimtree 窗口大小.
      window_picker = {
        enable = true,       -- VVI: false:总在 vsplit 窗口中打开新文件.
        chars = "ABCDEFGHIJKLMNOPQRSTUVWXYZ1234567890",
        exclude = {
          filetype = { "notify", "packer", "qf", "diff", "fugitive", "fugitiveblame" },
          buftype = { "nofile", "terminal", "help" },
        },
      },
    },
  },
  trash = {
    cmd = "trash",  -- Mac 没有 trash cmd
    require_confirm = true,
  },

  -- 日志 --
  log = {
    enable = false,
    truncate = false,
    types = {
      all = false,
      config = false,
      copy_paste = false,
      diagnostics = false,
      git = false,
      profile = false,
    },
  },
} -- END_DEFAULT_OPTS

--- automatically close the tab/vim when nvim-tree is the last window in the tab
vim.cmd [[autocmd BufEnter * ++nested if winnr('$') == 1 && bufname() == 'NvimTree_' . tabpagenr() | quit | endif]]

--- `:help nvim_tree_highlight` -------------------------------------------------------------------- {{{
vim.cmd('hi NvimTreeFolderIcon ctermfg=81 cterm=bold')
vim.cmd('hi NvimTreeFolderName ctermfg=81 cterm=bold')
vim.cmd('hi NvimTreeEmptyFolderName ctermfg=81 cterm=bold')
vim.cmd('hi NvimTreeOpenedFolderName ctermfg=81 cterm=bold')  -- 已打开文件夹的颜色
vim.cmd('hi NvimTreeOpenedFile ctermbg=238')   -- 已经打开文件的颜色
vim.cmd('hi NvimTreeSymlink ctermfg=207')      -- 链接文件, magenta
vim.cmd('hi NvimTreeExecFile ctermfg=167')     -- 可执行文件, red
vim.cmd('hi NvimTreeSpecialFile ctermfg=179')  -- 自定义 Sepcial 文件, orange
vim.cmd('hi NvimTreeIndentMarker ctermfg=242')
-- -- }}}

